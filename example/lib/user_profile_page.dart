import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final Map<String, dynamic> _initialUserData = {
    'name': 'John Doe',
    'email': 'john@example.com',
    'preferences': {
      'darkMode': false,
      'notifications': true,
    }
  };

  @override
  void initState() {
    super.initState();
    // Ensure user state is registered
    if (!StateStore.instance.hasComplexState('user')) {
      StateStore.instance.registerComplex<Map<String, dynamic>>('user', _initialUserData);
    }
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
              stateKey: 'user',
              fieldPath: 'name',
              selector: (user) => user['name'] as String,
              initialValue: _initialUserData,
              builder: (context, name) {
                return _EditableField(
                  label: 'Name',
                  value: name,
                  onSave: (newValue) {
                    try {
                      final complexNotifier = StateStore.instance.getComplexState<Map<String, dynamic>>('user');
                      final currentUser = Map<String, dynamic>.from(complexNotifier.value);
                      currentUser['name'] = newValue;
                      complexNotifier.update(currentUser);
                    } catch (e) {
                      debugPrint('Error updating name: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating name: $e')),
                      );
                    }
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Using FieldBuilder to only rebuild when the email changes
            FieldBuilder<Map<String, dynamic>, String>(
              stateKey: 'user',
              fieldPath: 'email',
              selector: (user) => user['email'] as String,
              initialValue: _initialUserData,
              builder: (context, email) {
                return _EditableField(
                  label: 'Email',
                  value: email,
                  onSave: (newValue) {
                    try {
                      final complexNotifier = StateStore.instance.getComplexState<Map<String, dynamic>>('user');
                      final currentUser = Map<String, dynamic>.from(complexNotifier.value);
                      currentUser['email'] = newValue;
                      complexNotifier.update(currentUser);
                    } catch (e) {
                      debugPrint('Error updating email: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating email: $e')),
                      );
                    }
                  },
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
              stateKey: 'user',
              fieldPath: 'preferences.darkMode',
              selector: (user) => user['preferences']['darkMode'] as bool,
              initialValue: _initialUserData,
              builder: (context, darkMode) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: darkMode,
                  onChanged: (newValue) {
                    try {
                      final complexNotifier = StateStore.instance.getComplexState<Map<String, dynamic>>('user');
                      final currentUser = Map<String, dynamic>.from(complexNotifier.value);
                      final preferences = Map<String, dynamic>.from(currentUser['preferences'] as Map);
                      preferences['darkMode'] = newValue;
                      currentUser['preferences'] = preferences;
                      complexNotifier.update(currentUser);
                    } catch (e) {
                      debugPrint('Error updating dark mode: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating dark mode: $e')),
                      );
                    }
                  },
                );
              },
            ),
            
            // Using FieldBuilder for another nested field
            FieldBuilder<Map<String, dynamic>, bool>(
              stateKey: 'user',
              fieldPath: 'preferences.notifications',
              selector: (user) => user['preferences']['notifications'] as bool,
              initialValue: _initialUserData,
              builder: (context, notifications) {
                return SwitchListTile(
                  title: const Text('Enable Notifications'),
                  value: notifications,
                  onChanged: (newValue) {
                    try {
                      final complexNotifier = StateStore.instance.getComplexState<Map<String, dynamic>>('user');
                      final currentUser = Map<String, dynamic>.from(complexNotifier.value);
                      final preferences = Map<String, dynamic>.from(currentUser['preferences'] as Map);
                      preferences['notifications'] = newValue;
                      currentUser['preferences'] = preferences;
                      complexNotifier.update(currentUser);
                    } catch (e) {
                      debugPrint('Error updating notifications: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating notifications: $e')),
                      );
                    }
                  },
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Using StateConsumer to display the entire user object
            StateConsumer<Map<String, dynamic>>(
              stateKey: 'user',
              initialValue: _initialUserData,
              builder: (context, userData, updateState) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current User Data (JSON):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(userData.toString()),
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
