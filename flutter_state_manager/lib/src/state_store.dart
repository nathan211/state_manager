import 'package:flutter/material.dart';
import 'state_notifier.dart';
import 'complex_state_notifier.dart';

/// A store for managing application state
class StateStore {
  /// The singleton instance of the StateStore
  static final StateStore _globalInstance = StateStore._internal('global');
  
  /// Get the global instance of the StateStore
  static StateStore get instance => _globalInstance;
  
  /// The name of this StateStore instance
  final String name;
  
  /// Map of simple state notifiers
  final Map<String, StateNotifier<dynamic>> _states = {};
  
  /// Map of complex state notifiers
  final Map<String, ComplexStateNotifier<dynamic>> _complexStates = {};
  
  /// Reference counters for simple states
  final Map<String, int> _stateRefCounts = {};
  
  /// Reference counters for complex states
  final Map<String, int> _complexStateRefCounts = {};
  
  /// Private constructor
  StateStore._internal(this.name);
  
  /// Create a new named StateStore instance
  factory StateStore.named(String name) {
    return StateStore._internal(name);
  }
  
  /// Register a simple state
  void register<T>(String key, T initialValue) {
    if (!_states.containsKey(key)) {
      _states[key] = StateNotifier<T>(initialValue);
      _stateRefCounts[key] = 0;
    }
    // Increment reference count
    _stateRefCounts[key] = (_stateRefCounts[key] ?? 0) + 1;
    debugPrint('StateStore: Registered state "$key", ref count: ${_stateRefCounts[key]}');
  }
  
  /// Register a complex state
  void registerComplex<T>(String key, T initialValue) {
    if (!_complexStates.containsKey(key)) {
      _complexStates[key] = ComplexStateNotifier<T>(initialValue);
      _complexStateRefCounts[key] = 0;
    }
    // Increment reference count
    _complexStateRefCounts[key] = (_complexStateRefCounts[key] ?? 0) + 1;
    debugPrint('StateStore: Registered complex state "$key", ref count: ${_complexStateRefCounts[key]}');
  }
  
  /// Check if a simple state exists
  bool hasState(String key) {
    return _states.containsKey(key);
  }
  
  /// Check if a complex state exists
  bool hasComplexState(String key) {
    return _complexStates.containsKey(key);
  }
  
  /// Get a simple state notifier
  StateNotifier<T> getState<T>(String key) {
    if (!_states.containsKey(key)) {
      throw Exception('State with key $key not found. Register it first.');
    }
    final notifier = _states[key];
    if (notifier is StateNotifier<T>) {
      return notifier;
    } else {
      throw Exception('Type mismatch for state with key $key');
    }
  }
  
  /// Get a complex state notifier
  ComplexStateNotifier<T> getComplexState<T>(String key) {
    if (!_complexStates.containsKey(key)) {
      throw Exception('Complex state with key $key not found. Register it first.');
    }
    final notifier = _complexStates[key];
    if (notifier is ComplexStateNotifier<T>) {
      return notifier;
    } else {
      throw Exception('Type mismatch for complex state with key $key');
    }
  }
  
  /// Get current value of a state
  T getValue<T>(String key) {
    return getState<T>(key).value;
  }
  
  /// Get current value of a complex state
  T getComplexValue<T>(String key) {
    return getComplexState<T>(key).value;
  }
  
  /// Update a state
  void setValue<T>(String key, T value) {
    getState<T>(key).update(value);
  }
  
  /// Update a complex state
  void setComplexValue<T>(String key, T value) {
    getComplexState<T>(key).update(value);
  }
  
  /// Update a state using a function
  void updateValue<T>(String key, T Function(T currentValue) updater) {
    getState<T>(key).updateWith(updater);
  }
  
  /// Update a complex state using a function
  void updateComplexValue<T>(String key, T Function(T currentValue) updater) {
    getComplexState<T>(key).updateWith(updater);
  }
  
  /// Update a field in a complex state
  void updateField<T, R>(String stateKey, String fieldPath, R newValue) {
    getComplexState<T>(stateKey).updateField(fieldPath, newValue);
  }
  
  /// Unregister a simple state
  void unregister(String key) {
    if (_states.containsKey(key)) {
      // Decrement reference count
      _stateRefCounts[key] = (_stateRefCounts[key] ?? 1) - 1;
      debugPrint('StateStore: Unregistered state "$key", ref count: ${_stateRefCounts[key]}');
      
      // Only dispose and remove if reference count is 0
      if (_stateRefCounts[key] == 0) {
        final notifier = _states[key];
        if (notifier != null) {
          notifier.dispose();
        }
        _states.remove(key);
        _stateRefCounts.remove(key);
        debugPrint('StateStore: Disposed state "$key"');
      }
    }
  }
  
  /// Unregister a complex state
  void unregisterComplex(String key) {
    if (_complexStates.containsKey(key)) {
      // Decrement reference count
      _complexStateRefCounts[key] = (_complexStateRefCounts[key] ?? 1) - 1;
      debugPrint('StateStore: Unregistered complex state "$key", ref count: ${_complexStateRefCounts[key]}');
      
      // Only dispose and remove if reference count is 0
      if (_complexStateRefCounts[key] == 0) {
        final notifier = _complexStates[key];
        if (notifier != null) {
          notifier.dispose();
        }
        _complexStates.remove(key);
        _complexStateRefCounts.remove(key);
        debugPrint('StateStore: Disposed complex state "$key"');
      }
    }
  }
  
  /// Reset or remove a state (alias for unregister)
  void resetState(String key) {
    unregister(key);
  }
  
  /// Reset or remove a complex state (alias for unregisterComplex)
  void resetComplexState(String key) {
    unregisterComplex(key);
  }
  
  /// Clear all states (alias for dispose)
  void clearAllStates() {
    dispose();
  }
  
  /// Dispose all states in this store
  void dispose() {
    for (final notifier in _states.values) {
      notifier.dispose();
    }
    _states.clear();
    _stateRefCounts.clear();
    
    for (final notifier in _complexStates.values) {
      notifier.dispose();
    }
    _complexStates.clear();
    _complexStateRefCounts.clear();
  }
}

/// A widget that provides a StateStore to its descendants
class StateStoreProvider extends InheritedWidget {
  /// The StateStore instance to provide
  final StateStore store;
  
  /// Creates a StateStoreProvider
  const StateStoreProvider({
    super.key,
    required this.store,
    required super.child,
  });
  
  /// Get the nearest StateStore from the context
  static StateStore of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StateStoreProvider>();
    return provider?.store ?? StateStore.instance;
  }
  
  @override
  bool updateShouldNotify(StateStoreProvider oldWidget) {
    return store != oldWidget.store;
  }
}
