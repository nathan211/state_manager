import 'package:flutter/foundation.dart';
import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Defines the state and operations for the async data feature
class AsyncDataState {
  /// The key used to access the async data state in the StateStore
  static const String stateKey = 'asyncData';
  
  /// Register the async data state in the StateStore
  static void register() {
    if (!StateStore.instance.hasState(stateKey)) {
      StateStore.instance.register<AsyncState<List<String>>>(
        stateKey, 
        const AsyncState<List<String>>(),
      );
    }
  }
  
  /// Get the state notifier for the async data
  static StateNotifier<AsyncState<List<String>>> getNotifier() {
    try {
      return StateStore.instance.getState<AsyncState<List<String>>>(stateKey);
    } catch (e) {
      debugPrint('Error getting async data notifier: $e');
      register();
      return StateStore.instance.getState<AsyncState<List<String>>>(stateKey);
    }
  }
}
