import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You have pushed the button this many times:',
            ),
            // Using StateBuilder to display the counter value
            StateBuilder<int>(
              stateKey: 'counter',
              builder: (context, count) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Using StateConsumer to both read and update the counter
                StateConsumer<int>(
                  stateKey: 'counter',
                  builder: (context, count, updateState) {
                    return ElevatedButton(
                      onPressed: () {
                        try {
                          updateState(count - 1);
                        } catch (e) {
                          debugPrint('Error decrementing counter: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error decrementing counter: $e')),
                          );
                        }
                      },
                      child: const Icon(Icons.remove),
                    );
                  },
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Directly update the state through StateStore
                    try {
                      StateStore.instance.updateValue<int>(
                        'counter',
                        (currentValue) => currentValue + 1,
                      );
                    } catch (e) {
                      debugPrint('Error incrementing counter: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error incrementing counter: $e')),
                      );
                    }
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Reset the counter to 0
                try {
                  StateStore.instance.setValue<int>('counter', 0);
                } catch (e) {
                  debugPrint('Error resetting counter: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error resetting counter: $e')),
                  );
                }
              },
              child: const Text('Reset Counter'),
            ),
          ],
        ),
      ),
    );
  }
}
