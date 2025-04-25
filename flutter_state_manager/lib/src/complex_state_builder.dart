import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';
import 'complex_state_notifier.dart';

/// A widget that builds itself based on the latest complex state value.
///
/// Similar to [StateBuilder] but specifically designed for complex state objects
/// like maps, lists, and arrays that are managed by [ComplexStateNotifier].
class ComplexStateBuilder<T> extends StatefulWidget {
  /// The key used to access the state in the [StateStore]
  final String stateKey;
  
  /// The builder function that builds the widget based on the current state value
  final Widget Function(BuildContext context, T value) builder;
  
  /// The initial value to register if the state doesn't exist yet
  final T? initialValue;
  
  /// The store to use for this builder
  /// If null, the nearest StateStoreProvider's store will be used,
  /// or the global instance if no provider is found
  final StateStore? store;

  /// Creates a ComplexStateBuilder widget.
  ///
  /// The [stateKey] and [builder] parameters must not be null.
  /// If the state with [stateKey] doesn't exist, it will be registered with [initialValue].
  const ComplexStateBuilder({
    super.key,
    required this.stateKey,
    required this.builder,
    this.initialValue,
    this.store,
  });

  @override
  ComplexStateBuilderState<T> createState() => ComplexStateBuilderState<T>();
}

class ComplexStateBuilderState<T> extends State<ComplexStateBuilder<T>> {
  late Stream<T> _stream;
  late T _currentValue;
  StreamSubscription<T>? _subscription;
  late StateStore _store;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize store with the widget's store or global instance
    // but don't access the context yet
    _store = widget.store ?? StateStore.instance;
    
    // Try to initialize with the current store, but don't access context
    _tryInitializeWithCurrentStore();
  }
  
  void _tryInitializeWithCurrentStore() {
    try {
      if (!_store.hasComplexState(widget.stateKey) && widget.initialValue != null) {
        _store.registerComplex<T>(widget.stateKey, widget.initialValue as T);
      }
      
      final stateNotifier = _store.getComplexState<T>(widget.stateKey);
      _stream = stateNotifier.stream;
      _currentValue = stateNotifier.value;
      
      _subscription = _stream.listen((data) {
        if (mounted) {
          setState(() {
            _currentValue = data;
          });
        }
      });
      
      _initialized = true;
    } catch (e) {
      // If initialization fails, we'll try again in didChangeDependencies
      debugPrint('ComplexStateBuilder: Initial setup deferred to didChangeDependencies: $e');
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Now it's safe to access context
    final newStore = widget.store ?? StateStoreProvider.of(context);
    
    // If store changed or we're not initialized yet, initialize
    if (!_initialized || _store != newStore) {
      // Clean up any existing subscription
      _subscription?.cancel();
      
      _store = newStore;
      _initializeState();
    }
  }

  void _initializeState() {
    try {
      // Register state if needed
      if (!_store.hasComplexState(widget.stateKey) && widget.initialValue != null) {
        _store.registerComplex<T>(widget.stateKey, widget.initialValue as T);
      } else if (_store.hasComplexState(widget.stateKey) && widget.initialValue != null) {
        // If state exists, increment reference count
        _store.registerComplex<T>(widget.stateKey, widget.initialValue as T);
      }
      
      final stateNotifier = _store.getComplexState<T>(widget.stateKey);
      _stream = stateNotifier.stream;
      _currentValue = stateNotifier.value;
      
      _subscription = _stream.listen((data) {
        if (mounted) {
          setState(() {
            _currentValue = data;
          });
        }
      });
      
      _initialized = true;
    } catch (e) {
      debugPrint('Error in ComplexStateBuilder: $e');
      rethrow;
    }
  }

  @override
  void didUpdateWidget(ComplexStateBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateKey != widget.stateKey || oldWidget.store != widget.store) {
      // Clean up old subscription
      _subscription?.cancel();
      _subscription = null;
      
      // If the key changed, unregister from the old key
      if (oldWidget.stateKey != widget.stateKey) {
        _store.unregisterComplex(oldWidget.stateKey);
      }
      
      // Re-initialize with new parameters
      _initializeState();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    
    // Unregister to decrement reference count
    if (_initialized) {
      _store.unregisterComplex(widget.stateKey);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}
