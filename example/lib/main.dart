import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

// Import feature pages
import 'features/counter/pages/counter_page.dart';
import 'features/todo/pages/todo_page.dart';
import 'features/user_profile/pages/user_profile_page.dart';
import 'features/async_data/pages/async_data_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a named store for the app
    final appStore = StateStore.named('app_store');
    
    return StateStoreProvider(
      store: appStore,
      child: MaterialApp(
        title: 'Flutter State Manager Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Manager Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select a demo:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Counter demo
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => StateProvider<int>(
                      key: UniqueKey(), 
                      stateKey: 'counter',
                      initialValue: 0,
                      child: const CounterPage(),
                    ),
                  ),
                );
              },
              child: const Text('Counter Demo'),
            ),
            
            const SizedBox(height: 10),
            
            // Todo list demo
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => ComplexStateProvider<List<Map<String, dynamic>>>(
                      key: UniqueKey(), 
                      stateKey: StateKey.forFeature('todo', 'items'),
                      initialValue: [
                        {'id': 1, 'title': 'Learn Flutter', 'completed': true},
                        {'id': 2, 'title': 'Master State Management', 'completed': false},
                        {'id': 3, 'title': 'Build Amazing Apps', 'completed': false},
                      ],
                      child: const TodoPage(),
                    ),
                  ),
                );
              },
              child: const Text('Todo List Demo'),
            ),
            
            const SizedBox(height: 10),
            
            // User profile demo
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => ComplexStateProvider<Map<String, dynamic>>(
                      key: UniqueKey(), 
                      stateKey: StateKey.forFeature('user_profile', 'data'),
                      initialValue: {
                        'name': 'John Doe',
                        'email': 'john.doe@example.com',
                        'preferences': {
                          'darkMode': false,
                          'notifications': true,
                        }
                      },
                      child: const UserProfilePage(),
                    ),
                  ),
                );
              },
              child: const Text('User Profile Demo'),
            ),
            
            const SizedBox(height: 10),
            
            // Async data demo
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => StateProvider<AsyncState<List<String>>>(
                      key: UniqueKey(), 
                      stateKey: StateKey.forFeature('async_data', 'state'),
                      initialValue: const AsyncState<List<String>>(),
                      child: const AsyncDataPage(),
                    ),
                  ),
                );
              },
              child: const Text('Async Data Demo'),
            ),
            
            const SizedBox(height: 30),
            
            // Information about the demo
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'This demo showcases the enhanced state management package with scoped stores and automatic lifecycle management.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
