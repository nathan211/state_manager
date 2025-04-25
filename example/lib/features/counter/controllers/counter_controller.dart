import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../states/counter_state.dart';

/// Controller class for the counter feature
/// Handles business logic and state interactions
class CounterController {
  /// The store to use for state management
  StateStore _store = StateStore.instance;
  
  /// Set the store to use
  void setStore(StateStore store) {
    _store = store;
  }

  /// Get the current counter value
  int getValue() {
    return _store.getValue<int>(CounterState.stateKey);
  }
  
  /// Update the counter value
  void setValue(int value) {
    try {
      _store.setValue<int>(CounterState.stateKey, value);
    } catch (e) {
      debugPrint('Error updating counter value: $e');
    }
  }
  
  /// Increment the counter value
  void incrementCounter() {
    try {
      final currentValue = getValue();
      setValue(currentValue + 1);
    } catch (e) {
      debugPrint('Error incrementing counter: $e');
    }
  }
  
  /// Decrement the counter value
  void decrementCounter() {
    try {
      final currentValue = getValue();
      setValue(currentValue - 1);
    } catch (e) {
      debugPrint('Error decrementing counter: $e');
    }
  }
  
  /// Reset the counter to zero
  void resetCounter() {
    try {
      setValue(0);
    } catch (e) {
      debugPrint('Error resetting counter: $e');
    }
  }
}
