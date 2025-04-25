import 'package:flutter/material.dart';
import 'state_store.dart';

/// A widget that provides state management with automatic lifecycle handling
class StateProvider<T> extends StatefulWidget {
  /// The key used to access the state in the [StateStore]
  final String stateKey;
  
  /// The initial value of the state
  final T initialValue;
  
  /// The child widget
  final Widget child;
  
  /// The store to use for this provider
  /// If null, the nearest StateStoreProvider's store will be used,
  /// or the global instance if no provider is found
  final StateStore? store;

  /// Creates a StateProvider widget
  ///
  /// The [stateKey], [initialValue], and [child] parameters must not be null.
  const StateProvider({
    super.key,
    required this.stateKey,
    required this.initialValue,
    required this.child,
    this.store,
  });

  @override
  StateProviderState<T> createState() => StateProviderState<T>();
}

class StateProviderState<T> extends State<StateProvider<T>> {
  late StateStore _store;
  
  @override
  void initState() {
    super.initState();
    // Initialize store with the global instance until didChangeDependencies is called
    _store = widget.store ?? StateStore.instance;
    _initializeState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the store from the widget or from the nearest provider
    final newStore = widget.store ?? StateStoreProvider.of(context);
    if (_store != newStore) {
      // Unregister from the old store
      _store.unregister(widget.stateKey);
      
      // Update to the new store
      _store = newStore;
      _initializeState();
    }
  }
  
  void _initializeState() {
    if (!_store.hasState(widget.stateKey)) {
      _store.register<T>(widget.stateKey, widget.initialValue);
    } else {
      // If the state already exists, increment the reference count
      _store.register<T>(widget.stateKey, widget.initialValue);
    }
  }
  
  @override
  void dispose() {
    // Decrement the reference count
    _store.unregister(widget.stateKey);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// A widget that provides complex state management with automatic lifecycle handling
class ComplexStateProvider<T> extends StatefulWidget {
  /// The key used to access the state in the [StateStore]
  final String stateKey;
  
  /// The initial value of the state
  final T initialValue;
  
  /// The child widget
  final Widget child;
  
  /// The store to use for this provider
  /// If null, the nearest StateStoreProvider's store will be used,
  /// or the global instance if no provider is found
  final StateStore? store;

  /// Creates a ComplexStateProvider widget
  ///
  /// The [stateKey], [initialValue], and [child] parameters must not be null.
  const ComplexStateProvider({
    super.key,
    required this.stateKey,
    required this.initialValue,
    required this.child,
    this.store,
  });

  @override
  ComplexStateProviderState<T> createState() => ComplexStateProviderState<T>();
}

class ComplexStateProviderState<T> extends State<ComplexStateProvider<T>> {
  late StateStore _store;
  
  @override
  void initState() {
    super.initState();
    // Initialize store with the global instance until didChangeDependencies is called
    _store = widget.store ?? StateStore.instance;
    _initializeState();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the store from the widget or from the nearest provider
    final newStore = widget.store ?? StateStoreProvider.of(context);
    if (_store != newStore) {
      // Unregister from the old store
      _store.unregisterComplex(widget.stateKey);
      
      // Update to the new store
      _store = newStore;
      _initializeState();
    }
  }
  
  void _initializeState() {
    if (!_store.hasComplexState(widget.stateKey)) {
      _store.registerComplex<T>(widget.stateKey, widget.initialValue);
    } else {
      // If the state already exists, increment the reference count
      _store.registerComplex<T>(widget.stateKey, widget.initialValue);
    }
  }
  
  @override
  void dispose() {
    // Decrement the reference count
    _store.unregisterComplex(widget.stateKey);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
