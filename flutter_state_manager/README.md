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
- **Scoped State**: Multiple state stores with provider-based access
- **Hierarchical Keys**: Prevent naming conflicts with feature-scoped state keys
- **Automatic Lifecycle Management**: Reference counting for proper state cleanup
- **Provider Pattern**: Familiar provider-based API for state registration and access

## Core Components

- **StateStore**: Central repository for all application states, with support for multiple named instances
- **StateStoreProvider**: InheritedWidget for accessing state stores in the widget tree
- **StateNotifier**: Manages individual state objects and notifies listeners of changes
- **ComplexStateNotifier**: Handles nested state with efficient field-specific updates
- **StateBuilder**: Widget that rebuilds when specific states change
- **ComplexStateBuilder**: Widget for complex state that rebuilds when state changes
- **StateConsumer**: Widget that both consumes state and provides update functions
- **ComplexStateConsumer**: Widget for complex state that provides update functions
- **FieldBuilder**: Widget that rebuilds when specific fields in a complex state change
- **StateProvider**: Widget that registers and provides simple state to its descendants
- **ComplexStateProvider**: Widget that registers and provides complex state to its descendants
- **StateKey**: Utility for creating hierarchical state keys to prevent naming conflicts
- **AsyncStateHandler**: Helper for managing asynchronous operations with proper state handling

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_state_manager: ^0.1.0
```

Run `flutter pub get` to install the package.

## Usage

### 1. Setting Up State Stores

Create a global state store or multiple scoped stores:

```dart
void main() {
  // Global store (singleton)
  final globalStore = StateStore.instance;
  
  // Named store for feature isolation
  final featureStore = StateStore.named('feature_store');
  
  runApp(
    StateStoreProvider(
      store: globalStore,
      child: MyApp(),
    ),
  );
}
```

### 2. Using Provider Widgets for State Registration

Register states using provider widgets:

```dart
// Simple state
StateProvider<int>(
  stateKey: StateKey.forFeature('counter', 'value'),
  initialValue: 0,
  child: CounterScreen(),
),

// Complex state
ComplexStateProvider<Map<String, dynamic>>(
  stateKey: StateKey.forFeature('user_profile', 'data'),
  initialValue: {
    'name': 'John Doe',
    'email': 'john@example.com',
    'preferences': {
      'darkMode': false,
      'notifications': true,
    }
  },
  child: UserProfileScreen(),
),
```

### 3. Accessing State in Widgets

Use builder widgets to access and display state:

```dart
class CounterDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the nearest store from the provider
    final store = StateStoreProvider.of(context);
    
    return StateBuilder<int>(
      stateKey: StateKey.forFeature('counter', 'value'),
      store: store, // Use the scoped store
      initialValue: 0, // Fallback initial value
      builder: (context, value) {
        return Text('Count: $value');
      },
    );
  }
}
```

### 4. Updating State with Controllers

Create controllers to handle business logic:

```dart
class CounterController {
  // Store to use for state access
  StateStore _store = StateStore.instance;
  
  // Set the store to use (for dependency injection)
  void setStore(StateStore store) {
    _store = store;
  }
  
  // Get the current counter value
  int getValue() {
    return _store.getValue<int>(StateKey.forFeature('counter', 'value'));
  }
  
  // Increment the counter
  void incrementCounter() {
    final currentValue = getValue();
    _store.setValue<int>(StateKey.forFeature('counter', 'value'), currentValue + 1);
  }
}
```

### 5. Connecting Controllers to Widgets

Connect controllers to widgets:

```dart
class CounterScreen extends StatefulWidget {
  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  late CounterController _controller;
  late StateStore _store;
  
  @override
  void initState() {
    super.initState();
    _controller = CounterController();
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
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: StateBuilder<int>(
          stateKey: StateKey.forFeature('counter', 'value'),
          store: _store,
          initialValue: 0,
          builder: (context, count) {
            return Text('Count: $count', style: TextStyle(fontSize: 24));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.incrementCounter,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 6. Working with Complex State and Field-Specific Updates

Use FieldBuilder for efficient field-specific updates:

```dart
FieldBuilder<Map<String, dynamic>, bool>(
  stateKey: StateKey.forFeature('user_profile', 'data'),
  fieldPath: 'preferences.darkMode',
  selector: (user) => user['preferences']['darkMode'] as bool,
  store: _store,
  initialValue: initialUserData,
  builder: (context, darkMode) {
    return SwitchListTile(
      title: Text('Dark Mode'),
      value: darkMode,
      onChanged: (value) => _controller.updateDarkMode(value),
    );
  },
),
```

### 7. Handling Asynchronous Operations

Use AsyncState and AsyncStateHandler for async operations:

```dart
// Define async state
StateProvider<AsyncState<List<String>>>(
  stateKey: StateKey.forFeature('data', 'items'),
  initialValue: AsyncState<List<String>>(),
  child: DataScreen(),
),

// In your controller
Future<void> loadData() async {
  // Set loading state
  _store.setValue<AsyncState<List<String>>>(
    StateKey.forFeature('data', 'items'),
    AsyncState<List<String>>(status: AsyncStatus.loading),
  );
  
  try {
    // Execute async operation
    final result = await apiClient.fetchData();
    
    // Set success state
    _store.setValue<AsyncState<List<String>>>(
      StateKey.forFeature('data', 'items'),
      AsyncState<List<String>>(
        status: AsyncStatus.success,
        data: result,
      ),
    );
  } catch (e) {
    // Set error state
    _store.setValue<AsyncState<List<String>>>(
      StateKey.forFeature('data', 'items'),
      AsyncState<List<String>>(
        status: AsyncStatus.error,
        error: e,
      ),
    );
  }
}
```

## Benefits

- **Scalable Architecture**: Easily scale from small to large applications
- **Feature Isolation**: Scope state to specific features for better organization
- **Memory Efficiency**: Automatic cleanup of unused states
- **Navigation Support**: Reliable state management during navigation
- **Minimal Boilerplate**: Simple API with minimal setup required
- **Familiar Patterns**: Combines the best of Provider, BLoC, and Redux patterns

## Example

See the `example` directory for a complete sample application demonstrating all features.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
