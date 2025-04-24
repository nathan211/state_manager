import 'dart:async';
import 'state_store.dart';

/// Status of an asynchronous operation
enum AsyncStatus {
  initial,
  loading,
  success,
  error,
}

/// Class to hold the state of an asynchronous operation
class AsyncState<T> {
  final AsyncStatus status;
  final T? data;
  final Object? error;
  
  const AsyncState({
    this.status = AsyncStatus.initial,
    this.data,
    this.error,
  });
  
  AsyncState<T> copyWith({
    AsyncStatus? status,
    T? data,
    Object? error,
  }) {
    return AsyncState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      error: error,
    );
  }
  
  bool get isInitial => status == AsyncStatus.initial;
  bool get isLoading => status == AsyncStatus.loading;
  bool get isSuccess => status == AsyncStatus.success;
  bool get isError => status == AsyncStatus.error;
}

/// Helper class to handle asynchronous operations
class AsyncStateHandler {
  /// Execute an asynchronous operation and update the state accordingly
  static Future<void> execute<T>({
    required String stateKey,
    required Future<T> Function() asyncFunction,
    void Function(T data)? onSuccess,
    void Function(Object error)? onError,
  }) async {
    final store = StateStore.instance;
    
    // Try to get the state, register it if it doesn't exist
    try {
      store.getState<AsyncState<T>>(stateKey);
    } catch (e) {
      // State doesn't exist, register it
      store.register<AsyncState<T>>(stateKey, AsyncState<T>());
    }
    
    // Set loading state
    store.setValue<AsyncState<T>>(
      stateKey,
      AsyncState<T>(status: AsyncStatus.loading),
    );
    
    try {
      // Execute the async function
      final result = await asyncFunction();
      
      // Set success state
      store.setValue<AsyncState<T>>(
        stateKey,
        AsyncState<T>(
          status: AsyncStatus.success,
          data: result,
        ),
      );
      
      // Call onSuccess callback if provided
      if (onSuccess != null) {
        onSuccess(result);
      }
    } catch (e) {
      // Set error state
      store.setValue<AsyncState<T>>(
        stateKey,
        AsyncState<T>(
          status: AsyncStatus.error,
          error: e,
        ),
      );
      
      // Call onError callback if provided
      if (onError != null) {
        onError(e);
      }
    }
  }
}
