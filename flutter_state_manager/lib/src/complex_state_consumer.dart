import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';
import 'complex_state_notifier.dart';

/// A widget that both consumes and allows updating complex state.
///
/// Similar to [StateConsumer] but specifically designed for complex state objects
/// like maps, lists, and arrays that are managed by [ComplexStateNotifier].
class ComplexStateConsumer<T> extends StatefulWidget {
  /// The key used to access the state in the [StateStore]
  final String stateKey;
  
  /// The builder function that builds the widget based on the current state value
  /// and provides a function to update the state
  final Widget Function(BuildContext context, T value, void Function(T) updateState, void Function(T Function(T)) updateStateWithUpdater) builder;
  
  /// The initial value to register if the state doesn't exist yet
  final T? initialValue;
  
  /// The store to use for this consumer
  /// If null, the nearest StateStoreProvider's store will be used,
  /// or the global instance if no provider is found
  final StateStore? store;

  /// Creates a ComplexStateConsumer widget.
  ///
  /// The [stateKey] and [builder] parameters must not be null.
  /// If the state with [stateKey] doesn't exist, it will be registered with [initialValue].
  const ComplexStateConsumer({
    super.key,
    required this.stateKey,
    required this.builder,
    this.initialValue,
    this.store,
  });

  @override
  ComplexStateConsumerState<T> createState() => ComplexStateConsumerState<T>();
}

class ComplexStateConsumerState<T> extends State<ComplexStateConsumer<T>> {
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
      debugPrint('ComplexStateConsumer: Initial setup deferred to didChangeDependencies: $e');
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
      debugPrint('Error in ComplexStateConsumer: $e');
      rethrow;
    }
  }

  @override
  void didUpdateWidget(ComplexStateConsumer<T> oldWidget) {
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
    return widget.builder(
      context, 
      _currentValue,
      (T newValue) => _store.setComplexValue<T>(widget.stateKey, newValue),
      (T Function(T) updater) => _store.updateComplexValue<T>(widget.stateKey, updater),
    );
  }
}
