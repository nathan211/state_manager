import 'package:flutter/foundation.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Defines the state and operations for the todo feature
class TodoState {
  /// The key used to access the todos state in the StateStore
  static const String stateKey = 'todos';
  
  /// The initial value for the todos state
  static final List<Map<String, dynamic>> initialValue = [
    {'id': 1, 'title': 'Learn Flutter', 'completed': true},
    {'id': 2, 'title': 'Master State Management', 'completed': false},
    {'id': 3, 'title': 'Build Amazing Apps', 'completed': false},
  ];
  
  /// Register the todos state in the StateStore
  static void register() {
    if (!StateStore.instance.hasComplexState(stateKey)) {
      StateStore.instance.registerComplex<List<Map<String, dynamic>>>(stateKey, initialValue);
    }
  }
  
  /// Get the ComplexStateNotifier for todos
  static ComplexStateNotifier<List<Map<String, dynamic>>> getNotifier() {
    try {
      return StateStore.instance.getComplexState<List<Map<String, dynamic>>>(stateKey);
    } catch (e) {
      debugPrint('Error getting todos notifier: $e');
      register();
      return StateStore.instance.getComplexState<List<Map<String, dynamic>>>(stateKey);
    }
  }
}
