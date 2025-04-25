import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';

class FieldBuilder<T, R> extends StatefulWidget {
  final String stateKey;
  final String fieldPath;
  final R Function(T) selector;
  final Widget Function(BuildContext context, R value) builder;
  final T? initialValue;
  final StateStore? store;

  const FieldBuilder({
    super.key,
    required this.stateKey,
    required this.fieldPath,
    required this.selector,
    required this.builder,
    this.initialValue,
    this.store,
  });

  @override
  FieldBuilderState<T, R> createState() => FieldBuilderState<T, R>();
}

class FieldBuilderState<T, R> extends State<FieldBuilder<T, R>> {
  late Stream<R> _stream;
  late R _currentValue;
  StreamSubscription<R>? _subscription;
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
      final fieldStream = stateNotifier.fieldStream<R>(widget.fieldPath, widget.selector);
      _stream = fieldStream;
      _currentValue = widget.selector(stateNotifier.value);
      
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
      debugPrint('FieldBuilder: Initial setup deferred to didChangeDependencies: $e');
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
      final fieldStream = stateNotifier.fieldStream<R>(widget.fieldPath, widget.selector);
      _stream = fieldStream;
      _currentValue = widget.selector(stateNotifier.value);
      
      _subscription = _stream.listen((data) {
        if (mounted) {
          setState(() {
            _currentValue = data;
          });
        }
      });
      
      _initialized = true;
    } catch (e) {
      debugPrint('Error in FieldBuilder: $e');
      rethrow;
    }
  }

  @override
  void didUpdateWidget(FieldBuilder<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateKey != widget.stateKey || 
        oldWidget.fieldPath != widget.fieldPath || 
        oldWidget.store != widget.store) {
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
