import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../states/async_data_state.dart';

/// Controller class for the async data feature
/// Handles business logic and state interactions
class AsyncDataController {
  /// Get the current async data state
  AsyncState<List<String>> getState() {
    return AsyncDataState.getNotifier().value;
  }

  /// Load data asynchronously
  Future<void> loadData({required BuildContext context}) async {
    try {
      await AsyncStateHandler.execute<List<String>>(
        stateKey: AsyncDataState.stateKey,
        asyncFunction: () async {
          // Simulate API call
          await Future.delayed(const Duration(seconds: 2));
          return ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];
        },
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data loaded successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
  
  /// Load data with error (for demonstration)
  Future<void> loadDataWithError({required BuildContext context}) async {
    try {
      await AsyncStateHandler.execute<List<String>>(
        stateKey: AsyncDataState.stateKey,
        asyncFunction: () async {
          // Simulate API call with error
          await Future.delayed(const Duration(seconds: 2));
          throw Exception('Failed to load data');
        },
      );
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
  
  /// Reset the async data state to initial
  void resetState({required BuildContext context}) {
    try {
      AsyncDataState.getNotifier().update(AsyncState<List<String>>());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('State reset successfully')),
      );
    } catch (e) {
      debugPrint('Error resetting state: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting state: $e')),
      );
    }
  }
}
