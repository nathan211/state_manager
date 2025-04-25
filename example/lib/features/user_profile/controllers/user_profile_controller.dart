import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../states/user_profile_state.dart';

/// Controller class for the user profile feature
/// Handles business logic and state interactions
class UserProfileController {
  /// The store to use for state management
  StateStore _store = StateStore.instance;
  
  /// Set the store to use
  void setStore(StateStore store) {
    _store = store;
  }

  /// Get the current user profile
  Map<String, dynamic> getUserProfile() {
    return _store.getComplexValue<Map<String, dynamic>>(UserProfileState.stateKey);
  }
  
  /// Create a deep copy of the user profile
  Map<String, dynamic> _deepCopyUserProfile(Map<String, dynamic> userProfile) {
    final result = Map<String, dynamic>.from(userProfile);
    
    // Deep copy nested maps
    if (result.containsKey('preferences') && result['preferences'] is Map) {
      result['preferences'] = Map<String, dynamic>.from(result['preferences'] as Map);
    }
    
    return result;
  }
  
  /// Update a field in the user profile
  void _updateField(String fieldPath, dynamic newValue, {required BuildContext context}) {
    try {
      final userProfile = _deepCopyUserProfile(getUserProfile());
      
      final parts = fieldPath.split('.');
      if (parts.length == 1) {
        // Simple field
        userProfile[fieldPath] = newValue;
      } else if (parts.length == 2) {
        // Nested field
        final section = parts[0];
        final field = parts[1];
        
        if (userProfile.containsKey(section) && userProfile[section] is Map) {
          final sectionMap = userProfile[section] as Map<String, dynamic>;
          sectionMap[field] = newValue;
        }
      }
      
      _store.setComplexValue<Map<String, dynamic>>(UserProfileState.stateKey, userProfile);
    } catch (e) {
      debugPrint('Error updating field $fieldPath: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating field: $e')),
      );
    }
  }
  
  /// Update the user's name
  /// Returns true if successful, false otherwise
  bool updateName(String name, {required BuildContext context}) {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return false;
    }
    
    try {
      _updateField('name', name, context: context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name updated successfully')),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating name: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating name: $e')),
      );
      return false;
    }
  }
  
  /// Update the user's email
  /// Returns true if successful, false otherwise
  bool updateEmail(String email, {required BuildContext context}) {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email cannot be empty')),
      );
      return false;
    }
    
    // Simple email validation
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return false;
    }
    
    try {
      _updateField('email', email, context: context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully')),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating email: $e')),
      );
      return false;
    }
  }
  
  /// Update the dark mode preference
  /// Returns true if successful, false otherwise
  bool updateDarkMode(bool enabled, {required BuildContext context}) {
    try {
      _updateField('preferences.darkMode', enabled, context: context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dark mode ${enabled ? 'enabled' : 'disabled'}')),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating dark mode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating dark mode: $e')),
      );
      return false;
    }
  }
  
  /// Update the notifications preference
  /// Returns true if successful, false otherwise
  bool updateNotifications(bool enabled, {required BuildContext context}) {
    try {
      _updateField('preferences.notifications', enabled, context: context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications ${enabled ? 'enabled' : 'disabled'}')),
      );
      return true;
    } catch (e) {
      debugPrint('Error updating notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating notifications: $e')),
      );
      return false;
    }
  }
}
