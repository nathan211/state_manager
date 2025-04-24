import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

class AsyncDataPage extends StatefulWidget {
  const AsyncDataPage({super.key});

  @override
  _AsyncDataPageState createState() => _AsyncDataPageState();
}

class _AsyncDataPageState extends State<AsyncDataPage> {
  static const String _asyncStateKey = 'users_data';
  
  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate API response
    return [
      {'id': 1, 'name': 'John Doe', 'email': 'john@example.com'},
      {'id': 2, 'name': 'Jane Smith', 'email': 'jane@example.com'},
      {'id': 3, 'name': 'Bob Johnson', 'email': 'bob@example.com'},
    ];
  }
  
  Future<void> _loadUsers() async {
    try {
      // Use AsyncStateHandler to manage loading, error, and success states
      await AsyncStateHandler.execute<List<Map<String, dynamic>>>(
        stateKey: _asyncStateKey,
        asyncFunction: _fetchUsers,
        onSuccess: (data) {
          debugPrint('Successfully loaded ${data.length} users');
        },
        onError: (error) {
          debugPrint('Error loading users: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading users: $error')),
          );
        },
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Async Data Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Async Data Handling',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _loadUsers,
              child: const Text('Load Users'),
            ),
            
            const SizedBox(height: 20),
            
            // Using StateBuilder to display different UI based on async state
            Expanded(
              child: StateBuilder<AsyncState<List<Map<String, dynamic>>>>(
                stateKey: _asyncStateKey,
                builder: (context, asyncState) {
                  // Handle loading state
                  if (asyncState.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading users...'),
                        ],
                      ),
                    );
                  }
                  
                  // Handle error state
                  if (asyncState.isError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${asyncState.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUsers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Handle success state with data
                  if (asyncState.isSuccess && asyncState.data != null) {
                    final users = asyncState.data!;
                    if (users.isNotEmpty) {
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${user['id']}'),
                              ),
                              title: Text(user['name'] as String),
                              subtitle: Text(user['email'] as String),
                            ),
                          );
                        },
                      );
                    }
                  }
                  
                  // Handle empty or initial state
                  return const Center(
                    child: Text(
                      'No users loaded yet. Press the "Load Users" button to fetch data.',
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
