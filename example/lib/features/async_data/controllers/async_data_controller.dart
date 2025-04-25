import 'package:flutter/material.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';
import '../states/async_data_state.dart';

/// Controller class for the async data feature
/// Handles business logic and state interactions
class AsyncDataController {
  /// The store to use for state management
  StateStore _store = StateStore.instance;
  
  /// Set the store to use
  void setStore(StateStore store) {
    _store = store;
  }

  /// Get the current async data state
  AsyncState<List<String>> getState() {
    return _store.getValue<AsyncState<List<String>>>(AsyncDataState.stateKey);
  }

  /// Load data asynchronously
  Future<void> loadData({required BuildContext context}) async {
    try {
      await _executeAsync(
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
      await _executeAsync(
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
  
  /// Execute an asynchronous operation and update the state
  Future<void> _executeAsync<T>({
    required Future<List<String>> Function() asyncFunction,
  }) async {
    // Set loading state
    _store.setValue<AsyncState<List<String>>>(
      AsyncDataState.stateKey,
      const AsyncState<List<String>>(status: AsyncStatus.loading),
    );
    
    try {
      // Execute the async function
      final result = await asyncFunction();
      
      // Set success state
      _store.setValue<AsyncState<List<String>>>(
        AsyncDataState.stateKey,
        AsyncState<List<String>>(
          status: AsyncStatus.success,
          data: result,
        ),
      );
    } catch (e) {
      // Set error state
      _store.setValue<AsyncState<List<String>>>(
        AsyncDataState.stateKey,
        AsyncState<List<String>>(
          status: AsyncStatus.error,
          error: e,
        ),
      );
      
      // Rethrow to allow caller to handle
      rethrow;
    }
  }
  
  /// Reset the async data state to initial
  void resetState({required BuildContext context}) {
    try {
      _store.setValue<AsyncState<List<String>>>(
        AsyncDataState.stateKey,
        const AsyncState<List<String>>(),
      );
      
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
