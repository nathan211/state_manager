import 'package:flutter/material.dart';

// Import feature states for centralized registration
import 'features/counter/states/counter_state.dart';
import 'features/todo/states/todo_state.dart';
import 'features/user_profile/states/user_profile_state.dart';
import 'features/async_data/states/async_data_state.dart';

// Import feature pages
import 'features/counter/pages/counter_page.dart';
import 'features/todo/pages/todo_page.dart';
import 'features/user_profile/pages/user_profile_page.dart';
import 'features/async_data/pages/async_data_page.dart';

void main() {
  // Register all states at app startup
  _registerAllStates();
  runApp(const MyApp());
}

/// Register all application states in a centralized location
void _registerAllStates() {
  // Register counter state
  CounterState.register();
  
  // Register todos state
  TodoState.register();
  
  // Register user profile state
  UserProfileState.register();
  
  // Register async data state
  AsyncDataState.register();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter State Manager Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
