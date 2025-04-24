import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

void main() {
  group('StateNotifier tests', () {
    test('StateNotifier initializes with correct value', () {
      final notifier = StateNotifier<int>(10);
      expect(notifier.value, 10);
    });

    test('StateNotifier updates value correctly', () {
      final notifier = StateNotifier<int>(10);
      notifier.update(20);
      expect(notifier.value, 20);
    });

    test('StateNotifier updateWith works correctly', () {
      final notifier = StateNotifier<int>(10);
      notifier.updateWith((value) => value * 2);
      expect(notifier.value, 20);
    });

    test('StateNotifier stream emits updated values', () async {
      final notifier = StateNotifier<int>(10);
      
      // Listen to the stream and collect values
      final values = <int>[];
      final subscription = notifier.stream.listen(values.add);
      
      // Update the value multiple times
      notifier.update(20);
      notifier.update(30);
      
      // Wait for stream events to be processed
      await Future.delayed(Duration.zero);
      
      // Clean up
      await subscription.cancel();
      notifier.dispose();
      
      // Check that the stream emitted the updated values
      expect(values, [20, 30]);
    });
  });

  group('StateStore tests', () {
    test('StateStore registers and retrieves state correctly', () {
      final store = StateStore.instance;
      
      // Clear any existing states
      store.clearAllStates();
      
      // Register a new state
      store.register<int>('counter', 0);
      
      // Get the state
      final value = store.getValue<int>('counter');
      expect(value, 0);
    });

    test('StateStore updates state correctly', () {
      final store = StateStore.instance;
      
      // Clear any existing states
      store.clearAllStates();
      
      // Register a new state
      store.register<int>('counter', 0);
      
      // Update the state
      store.setValue<int>('counter', 10);
      
      // Get the updated state
      final value = store.getValue<int>('counter');
      expect(value, 10);
    });

    test('StateStore updateValue works correctly', () {
      final store = StateStore.instance;
      
      // Clear any existing states
      store.clearAllStates();
      
      // Register a new state
      store.register<int>('counter', 5);
      
      // Update the state using a function
      store.updateValue<int>('counter', (value) => value * 2);
      
      // Get the updated state
      final value = store.getValue<int>('counter');
      expect(value, 10);
    });

    test('StateStore resetState removes state correctly', () {
      final store = StateStore.instance;
      
      // Clear any existing states
      store.clearAllStates();
      
      // Register a new state
      store.register<int>('counter', 0);
      
      // Reset the state
      store.resetState('counter');
      
      // Check that accessing the state throws an exception
      expect(() => store.getValue<int>('counter'), throwsException);
    });
  });

  group('ComplexStateNotifier tests', () {
    test('ComplexStateNotifier initializes with correct value', () {
      final notifier = ComplexStateNotifier<Map<dynamic, dynamic>>({
        'user': {
          'name': 'John',
          'age': 30,
        }
      });
      
      expect(notifier.value['user']['name'], 'John');
      expect(notifier.value['user']['age'], 30);
    });

    test('ComplexStateNotifier updates value correctly', () {
      final notifier = ComplexStateNotifier<Map<dynamic, dynamic>>({
        'user': {
          'name': 'John',
          'age': 30,
        }
      });
      
      notifier.update({
        'user': {
          'name': 'Jane',
          'age': 25,
        }
      });
      
      expect(notifier.value['user']['name'], 'Jane');
      expect(notifier.value['user']['age'], 25);
    });

    test('ComplexStateNotifier updateField works correctly', () {
      final notifier = ComplexStateNotifier<Map<dynamic, dynamic>>({
        'user': {
          'name': 'John',
          'age': 30,
        }
      });
      
      notifier.updateField('user.name', 'Jane');
      
      expect(notifier.value['user']['name'], 'Jane');
      expect(notifier.value['user']['age'], 30);
    });

    test('ComplexStateNotifier handles nested updates correctly', () {
      final notifier = ComplexStateNotifier<Map<dynamic, dynamic>>({
        'users': [
          {'name': 'John', 'age': 30},
          {'name': 'Jane', 'age': 25},
        ]
      });
      
      notifier.updateField('users.0.age', 31);
      
      expect(notifier.value['users'][0]['name'], 'John');
      expect(notifier.value['users'][0]['age'], 31);
      expect(notifier.value['users'][1]['name'], 'Jane');
      expect(notifier.value['users'][1]['age'], 25);
    });
  });

  group('AsyncStateHandler tests', () {
    test('AsyncStateHandler handles successful async operations', () async {
      final store = StateStore.instance;
      store.clearAllStates();
      
      // Define a simple async function that returns a value after a delay
      Future<String> fetchData() async {
        await Future.delayed(Duration(milliseconds: 50));
        return 'Data loaded';
      }
      
      // Execute the async operation
      await AsyncStateHandler.execute<String>(
        stateKey: 'asyncData',
        asyncFunction: fetchData,
      );
      
      // Get the async state
      final asyncState = store.getValue<AsyncState<String>>('asyncData');
      
      // Check the state
      expect(asyncState.status, AsyncStatus.success);
      expect(asyncState.data, 'Data loaded');
      expect(asyncState.error, null);
    });

    test('AsyncStateHandler handles failed async operations', () async {
      final store = StateStore.instance;
      store.clearAllStates();
      
      // Define a simple async function that throws an error
      Future<String> fetchData() async {
        await Future.delayed(Duration(milliseconds: 50));
        throw Exception('Failed to load data');
      }
      
      // Execute the async operation
      await AsyncStateHandler.execute<String>(
        stateKey: 'asyncData',
        asyncFunction: fetchData,
      );
      
      // Get the async state
      final asyncState = store.getValue<AsyncState<String>>('asyncData');
      
      // Check the state
      expect(asyncState.status, AsyncStatus.error);
      expect(asyncState.data, null);
      expect(asyncState.error, isA<Exception>());
      expect((asyncState.error as Exception).toString(), 'Exception: Failed to load data');
    });

    test('AsyncStateHandler sets loading state during execution', () async {
      final store = StateStore.instance;
      store.clearAllStates();
      
      // Create a completer to control when the async function completes
      final completer = Completer<String>();
      
      // Define a simple async function that returns a value when the completer completes
      Future<String> fetchData() => completer.future;
      
      // Start the async operation but don't await it
      final future = AsyncStateHandler.execute<String>(
        stateKey: 'asyncData',
        asyncFunction: fetchData,
      );
      
      // Check that the state is loading
      final loadingState = store.getValue<AsyncState<String>>('asyncData');
      expect(loadingState.status, AsyncStatus.loading);
      
      // Complete the async operation
      completer.complete('Data loaded');
      
      // Wait for the async operation to complete
      await future;
      
      // Check that the state is success
      final successState = store.getValue<AsyncState<String>>('asyncData');
      expect(successState.status, AsyncStatus.success);
      expect(successState.data, 'Data loaded');
    });
  });
}
