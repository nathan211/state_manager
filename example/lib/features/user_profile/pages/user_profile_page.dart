import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../controllers/user_profile_controller.dart';
import '../states/user_profile_state.dart';

/// User profile example page demonstrating field-specific state management
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  /// Controller for handling business logic
  late UserProfileController _controller;
  late StateStore _store;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    _controller = UserProfileController();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the store from the nearest provider
    _store = StateStoreProvider.of(context);
    // Set the store in the controller
    _controller.setStore(_store);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Using FieldBuilder to only rebuild when the name changes
            FieldBuilder<Map<String, dynamic>, String>(
              stateKey: UserProfileState.stateKey,
              fieldPath: 'name',
              selector: (user) => user['name'] as String,
              initialValue: UserProfileState.initialValue,
              store: _store,
              builder: (context, name) {
                return _EditableField(
                  label: 'Name',
                  value: name,
                  onSave: (newValue) => _controller.updateName(newValue, context: context),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Using FieldBuilder to only rebuild when the email changes
            FieldBuilder<Map<String, dynamic>, String>(
              stateKey: UserProfileState.stateKey,
              fieldPath: 'email',
              selector: (user) => user['email'] as String,
              initialValue: UserProfileState.initialValue,
              store: _store,
              builder: (context, email) {
                return _EditableField(
                  label: 'Email',
                  value: email,
                  onSave: (newValue) => _controller.updateEmail(newValue, context: context),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 16),
            
            // Using FieldBuilder for a nested field
            FieldBuilder<Map<String, dynamic>, bool>(
              stateKey: UserProfileState.stateKey,
              fieldPath: 'preferences.darkMode',
              selector: (user) => user['preferences']['darkMode'] as bool,
              initialValue: UserProfileState.initialValue,
              store: _store,
              builder: (context, darkMode) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: darkMode,
                  onChanged: (newValue) => _controller.updateDarkMode(newValue, context: context),
                );
              },
            ),
            
            // Using FieldBuilder for another nested field
            FieldBuilder<Map<String, dynamic>, bool>(
              stateKey: UserProfileState.stateKey,
              fieldPath: 'preferences.notifications',
              selector: (user) => user['preferences']['notifications'] as bool,
              initialValue: UserProfileState.initialValue,
              store: _store,
              builder: (context, notifications) {
                return SwitchListTile(
                  title: const Text('Notifications'),
                  value: notifications,
                  onChanged: (newValue) => _controller.updateNotifications(newValue, context: context),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Display complete user profile
            ComplexStateBuilder<Map<String, dynamic>>(
              stateKey: UserProfileState.stateKey,
              initialValue: UserProfileState.initialValue,
              store: _store,
              builder: (context, userProfile) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Profile Data:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Name: ${userProfile['name']}'),
                        Text('Email: ${userProfile['email']}'),
                        Text('Dark Mode: ${userProfile['preferences']['darkMode']}'),
                        Text('Notifications: ${userProfile['preferences']['notifications']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A reusable editable field component
class _EditableField extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onSave;

  const _EditableField({
    required this.label,
    required this.value,
    required this.onSave,
  });

  @override
  _EditableFieldState createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_EditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _isEditing
              ? TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    border: const OutlineInputBorder(),
                  ),
                )
              : ListTile(
                  title: Text(widget.label),
                  subtitle: Text(widget.value),
                  contentPadding: EdgeInsets.zero,
                ),
        ),
        IconButton(
          icon: Icon(_isEditing ? Icons.save : Icons.edit),
          onPressed: () {
            if (_isEditing) {
              widget.onSave(_controller.text);
            }
            setState(() {
              _isEditing = !_isEditing;
            });
          },
        ),
      ],
    );
  }
}
