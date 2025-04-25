import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Defines the state and operations for the user profile feature
class UserProfileState {
  /// The key used to access the user profile state in the StateStore
  static final String stateKey = StateKey.forFeature('user_profile', 'data');
  
  /// The initial value for the user profile state
  static final Map<String, dynamic> initialValue = {
    'name': 'John Doe',
    'email': 'john@example.com',
    'preferences': {
      'darkMode': false,
      'notifications': true,
    }
  };
}
