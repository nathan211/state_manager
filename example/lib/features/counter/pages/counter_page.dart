import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../controllers/counter_controller.dart';
import '../states/counter_state.dart';

/// Counter example page demonstrating simple state management
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  /// Controller for handling business logic
  late CounterController _controller;
  late StateStore _store;

  @override
  void initState() {
    super.initState();
    // Initialize controller
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
      appBar: AppBar(
        title: const Text('Counter Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.resetCounter,
            tooltip: 'Reset Counter',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Current Count:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            // Using StateBuilder to reactively display the counter value
            StateBuilder<int>(
              stateKey: CounterState.stateKey,
              initialValue: CounterState.initialValue,
              store: _store,
              builder: (context, count) {
                return Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _controller.decrementCounter,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _controller.incrementCounter,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Using StateConsumer to both display and update the counter value
            StateConsumer<int>(
              stateKey: CounterState.stateKey,
              initialValue: CounterState.initialValue,
              store: _store,
              builder: (context, count, updateState) {
                return Column(
                  children: [
                    const Text(
                      'Alternative Counter Control:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => updateState(count - 1),
                          child: const Text('-1'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => updateState(count + 1),
                          child: const Text('+1'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
