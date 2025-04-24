import 'package:flutter/material.dart';
import '../states/counter_state.dart';

/// Controller class for the counter feature
/// Handles business logic and state interactions
class CounterController {
  /// Get the current counter value
  int getValue() {
    return CounterState.getNotifier().value;
  }
  
  /// Update the counter value
  void setValue(int value) {
    try {
      CounterState.getNotifier().update(value);
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
