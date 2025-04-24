import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import 'counter_page.dart';
import 'todo_page.dart';
import 'user_profile_page.dart';
import 'async_data_page.dart';

void main() {
  // Register all states at app startup
  _registerAllStates();
  runApp(const MyApp());
}

void _registerAllStates() {
  final store = StateStore.instance;
  
  // Register counter state if it doesn't exist
  if (!store.hasState('counter')) {
    store.register<int>('counter', 0);
  }
  
  // Register todos state if it doesn't exist
  if (!store.hasComplexState('todos')) {
    final initialTodos = [
      {'id': 1, 'title': 'Learn Flutter', 'completed': true},
      {'id': 2, 'title': 'Master State Management', 'completed': false},
      {'id': 3, 'title': 'Build Amazing Apps', 'completed': false},
    ];
    store.registerComplex<List<Map<String, dynamic>>>('todos', initialTodos);
  }
  
  // Register user state if it doesn't exist
  if (!store.hasComplexState('user')) {
    final initialUser = {
      'name': 'John Doe',
      'email': 'john@example.com',
      'preferences': {
        'darkMode': false,
        'notifications': true,
      }
    };
    store.registerComplex<Map<String, dynamic>>('user', initialUser);
  }
  
  // Register async data state if it doesn't exist
  if (!store.hasState('users_data')) {
    store.register<AsyncState<List<Map<String, dynamic>>>>(
      'users_data', 
      const AsyncState<List<Map<String, dynamic>>>()
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter State Manager Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter State Manager Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select an example:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CounterPage()),
                  );
                },
                child: const Text('Counter Example'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TodoPage()),
                  );
                },
                child: const Text('Todo List Example'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UserProfilePage()),
                  );
                },
                child: const Text('User Profile Example'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AsyncDataPage()),
                  );
                },
                child: const Text('Async Data Example'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
