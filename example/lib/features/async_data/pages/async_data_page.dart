import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../controllers/async_data_controller.dart';
import '../states/async_data_state.dart';

/// Async data example page demonstrating async state management
class AsyncDataPage extends StatefulWidget {
  const AsyncDataPage({super.key});

  @override
  State<AsyncDataPage> createState() => _AsyncDataPageState();
}

class _AsyncDataPageState extends State<AsyncDataPage> {
  /// Controller for handling business logic
  final _controller = AsyncDataController();

  @override
  void initState() {
    super.initState();
    // Ensure async data state is registered
    AsyncDataState.register();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Async Data Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.resetState(context: context),
            tooltip: 'Reset State',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Async Data Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This example demonstrates how to handle asynchronous operations with proper state management.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.loadData(context: context),
                  child: const Text('Load Data'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.loadDataWithError(context: context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade300,
                  ),
                  child: const Text('Load with Error'),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Using StateBuilder to display different UI based on async state
            Expanded(
              child: StateBuilder<AsyncState<List<String>>>(
                stateKey: AsyncDataState.stateKey,
                builder: (context, state) {
                  if (state.isInitial) {
                    return const Center(
                      child: Text('Press one of the buttons above to load data'),
                    );
                  } else if (state.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading data...'),
                        ],
                      ),
                    );
                  } else if (state.isError) {
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
                            'Error: ${state.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _controller.loadData(context: context),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Success state
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Data loaded successfully:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.data!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(Icons.data_array),
                                  title: Text(state.data![index]),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
