import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';

class StateConsumer<T> extends StatefulWidget {
  final String stateKey;
  final Widget Function(BuildContext context, T value, void Function(T) updateState) builder;
  final T? initialValue;
  final StateStore? store;

  const StateConsumer({
    super.key,
    required this.stateKey,
    required this.builder,
    this.initialValue,
    this.store,
  });

  @override
  StateConsumerState<T> createState() => StateConsumerState<T>();
}

class StateConsumerState<T> extends State<StateConsumer<T>> {
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
      if (!_store.hasState(widget.stateKey) && widget.initialValue != null) {
        _store.register<T>(widget.stateKey, widget.initialValue as T);
      }
      
      final stateNotifier = _store.getState<T>(widget.stateKey);
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
      debugPrint('StateConsumer: Initial setup deferred to didChangeDependencies: $e');
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
      if (!_store.hasState(widget.stateKey) && widget.initialValue != null) {
        _store.register<T>(widget.stateKey, widget.initialValue as T);
      } else if (_store.hasState(widget.stateKey) && widget.initialValue != null) {
        // If state exists, increment reference count
        _store.register<T>(widget.stateKey, widget.initialValue as T);
      }
      
      final stateNotifier = _store.getState<T>(widget.stateKey);
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
      debugPrint('Error in StateConsumer: $e');
      rethrow;
    }
  }

  @override
  void didUpdateWidget(StateConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateKey != widget.stateKey || oldWidget.store != widget.store) {
      // Clean up old subscription
      _subscription?.cancel();
      _subscription = null;
      
      // If the key changed, unregister from the old key
      if (oldWidget.stateKey != widget.stateKey) {
        _store.unregister(oldWidget.stateKey);
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
      _store.unregister(widget.stateKey);
    }
    
    super.dispose();
  }

  void _updateState(T newValue) {
    _store.setValue<T>(widget.stateKey, newValue);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue, _updateState);
  }
}
