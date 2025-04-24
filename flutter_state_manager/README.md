# Flutter State Manager

A lightweight, reactive state management solution for Flutter applications using Dart's Stream API and the Observer pattern.

## Features

- **Reactive State Management**: UI components only rebuild when their specific state changes
- **Simple API**: Easy-to-use API for managing application state
- **Type-safe**: Fully typed state management
- **Efficient**: Minimal rebuilds for optimal performance
- **Decoupled**: Separate state logic from UI components
- **Complex State Support**: Handle nested state objects with field-specific updates
- **Asynchronous Operations**: Built-in handling for loading, success, and error states

## Core Components

- **StateNotifier**: Manages individual state objects and notifies listeners of changes
- **StateStore**: Central repository for all application states
- **StateBuilder**: Widget that rebuilds when specific states change
- **StateConsumer**: Widget that both consumes state and rebuilds when it changes
- **ComplexStateNotifier**: Handles nested state with efficient field-specific updates
- **FieldBuilder**: Widget that rebuilds when specific fields in a complex state change
- **AsyncStateHandler**: Helper for managing asynchronous operations with proper state handling

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_state_manager: ^0.0.1
```

Run `flutter pub get` to install the package.

## Usage

### 1. Basic State Management

First, register your states in the central `StateStore`:

```dart
void main() {
  // Register states
  StateStore.instance.register<int>('counter', 0);
  StateStore.instance.register<String>('username', '');
  StateStore.instance.register<bool>('isDarkMode', false);
  
  runApp(MyApp());
}
```

Use `StateBuilder` to consume state:

```dart
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder<int>(
      stateKey: 'counter',
      builder: (context, value) {
        return Text('Count: $value');
      },
    );
  }
}
```

Use `StateConsumer` to both consume and update state:

```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateConsumer<int>(
      stateKey: 'counter',
      builder: (context, value, updateState) {
        return Column(
          children: [
            Text('Count: $value'),
            ElevatedButton(
              onPressed: () => updateState(value + 1),
              child: Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}
```

### 2. Complex Nested State Management

Register a complex state with nested objects:

```dart
void main() {
  // Register a complex state
  StateStore.instance.registerComplex<Map<String, dynamic>>('user', {
    'personal': {
      'name': 'John Doe',
      'age': 30,
    },
    'address': {
      'street': '123 Main St',
      'city': 'New York',
      'zipCode': '10001',
    },
    'hobbies': ['Reading', 'Coding', 'Hiking'],
  });
  
  runApp(MyApp());
}
```

Use `FieldBuilder` to observe and update specific fields:

```dart
FieldBuilder<Map<String, dynamic>, String>(
  stateKey: 'user',
  fieldPath: 'personal.name',
  selector: (state) => state['personal']['name'] as String,
  builder: (context, name) {
    return Row(
      children: [
        Text('Name: $name'),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            // Update a specific field
            StateStore.instance.updateField<Map<String, dynamic>, String>(
              'user', 'personal.name', 'Jane Doe',
            );
          },
        ),
      ],
    );
  },
),
```

### 3. Async State Management

Handle asynchronous operations with built-in state management:

```dart
// Register the async state
StateStore.instance.register<AsyncState<List<String>>>(
  'users',
  AsyncState<List<String>>(),
);

// Use StateBuilder to display different UI based on async state
StateBuilder<AsyncState<List<String>>>(
  stateKey: 'users',
  builder: (context, state) {
    if (state.isInitial) {
      return Text('Press the button to load users');
    } else if (state.isLoading) {
      return CircularProgressIndicator();
    } else if (state.isError) {
      return Text('Error: ${state.error}');
    } else {
      return Column(
        children: [
          Text('Users:'),
          ...state.data!.map((user) => Text(user)).toList(),
        ],
      );
    }
  },
),

// Execute async operation with proper state handling
ElevatedButton(
  onPressed: () {
    AsyncStateHandler.execute<List<String>>(
      stateKey: 'users',
      asyncFunction: () async {
        // Simulate API call
        await Future.delayed(Duration(seconds: 2));
        return ['John', 'Jane', 'Bob', 'Alice'];
      },
    );
  },
  child: Text('Load Users'),
),
```

### 4. Direct State Access

You can also access and update states directly:

```dart
// Get a state value
final count = StateStore.instance.getValue<int>('counter');

// Update a state value
StateStore.instance.setValue<int>('counter', 10);

// Update a state using a function
StateStore.instance.updateValue<int>('counter', (value) => value + 1);

// Update a field in a complex state
StateStore.instance.updateField<Map<String, dynamic>, String>(
  'user', 'address.city', 'San Francisco',
);
```

## Performance Considerations

Our state management package is designed with performance in mind:

- **Selective Updates**: UI components only rebuild when their specific state changes
- **Memory Management**: Resources are properly disposed to prevent memory leaks
- **Efficient Change Detection**: The package uses equality checks to avoid unnecessary updates
- **Granular Subscriptions**: For complex states, components can subscribe to specific fields

## Complete Example

Here's a complete counter app example:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

void main() {
  // Register states
  StateStore.instance.register<int>('counter', 0);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter State Manager Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter Example'),
      ),
      body: Center(
        child: StateConsumer<int>(
          stateKey: 'counter',
          builder: (context, value, updateState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          StateStore.instance.updateValue<int>('counter', (value) => value + 1);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
