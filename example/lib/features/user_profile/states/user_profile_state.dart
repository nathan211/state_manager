import 'package:flutter/foundation.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Defines the state and operations for the user profile feature
class UserProfileState {
  /// The key used to access the user profile state in the StateStore
  static const String stateKey = 'user';
  
  /// The initial value for the user profile state
  static final Map<String, dynamic> initialValue = {
    'name': 'John Doe',
    'email': 'john@example.com',
    'preferences': {
      'darkMode': false,
      'notifications': true,
    }
  };
  
  /// Register the user profile state in the StateStore
  static void register() {
    if (!StateStore.instance.hasComplexState(stateKey)) {
      StateStore.instance.registerComplex<Map<String, dynamic>>(stateKey, initialValue);
    }
  }
  
  /// Get the ComplexStateNotifier for user profile
  static ComplexStateNotifier<Map<String, dynamic>> getNotifier() {
    try {
      return StateStore.instance.getComplexState<Map<String, dynamic>>(stateKey);
    } catch (e) {
      debugPrint('Error getting user profile notifier: $e');
      register();
      return StateStore.instance.getComplexState<Map<String, dynamic>>(stateKey);
    }
  }
}
