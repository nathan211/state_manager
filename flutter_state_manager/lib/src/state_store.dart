import 'state_notifier.dart';
import 'complex_state_notifier.dart';

class StateStore {
  StateStore._();
  static final StateStore instance = StateStore._();
  
  final Map<String, StateNotifier<dynamic>> _states = {};
  final Map<String, ComplexStateNotifier<dynamic>> _complexStates = {};
  
  // Register a new state
  void register<T>(String key, T initialValue) {
    if (!_states.containsKey(key)) {
      _states[key] = StateNotifier<T>(initialValue);
    }
  }
  
  // Register a complex state
  void registerComplex<T>(String key, T initialValue) {
    if (!_complexStates.containsKey(key)) {
      _complexStates[key] = ComplexStateNotifier<T>(initialValue);
    }
  }
  
  // Check if a state exists
  bool hasState(String key) {
    return _states.containsKey(key);
  }
  
  // Check if a complex state exists
  bool hasComplexState(String key) {
    return _complexStates.containsKey(key);
  }
  
  // Get a state notifier
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
  
  // Get a complex state notifier
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
  
  // Get current value of a state
  T getValue<T>(String key) {
    return getState<T>(key).value;
  }
  
  // Get current value of a complex state
  T getComplexValue<T>(String key) {
    return getComplexState<T>(key).value;
  }
  
  // Update a state
  void setValue<T>(String key, T value) {
    getState<T>(key).update(value);
  }
  
  // Update a complex state
  void setComplexValue<T>(String key, T value) {
    getComplexState<T>(key).update(value);
  }
  
  // Update a state using a function
  void updateValue<T>(String key, T Function(T currentValue) updater) {
    getState<T>(key).updateWith(updater);
  }
  
  // Update a complex state using a function
  void updateComplexValue<T>(String key, T Function(T currentValue) updater) {
    getComplexState<T>(key).updateWith(updater);
  }
  
  // Update a field in a complex state
  void updateField<T, R>(String stateKey, String fieldPath, R newValue) {
    getComplexState<T>(stateKey).updateField(fieldPath, newValue);
  }
  
  // Reset or remove a state
  void resetState(String key) {
    if (_states.containsKey(key)) {
      _states[key]?.dispose();
      _states.remove(key);
    }
  }
  
  // Reset or remove a complex state
  void resetComplexState(String key) {
    if (_complexStates.containsKey(key)) {
      _complexStates[key]?.dispose();
      _complexStates.remove(key);
    }
  }
  
  // Clear all states
  void clearAllStates() {
    for (final notifier in _states.values) {
      notifier.dispose();
    }
    _states.clear();
    
    for (final notifier in _complexStates.values) {
      notifier.dispose();
    }
    _complexStates.clear();
  }
}
