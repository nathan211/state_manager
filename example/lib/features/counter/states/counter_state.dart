import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Defines the state key for the counter feature
class CounterState {
  /// The key used to access the counter state in the StateStore
  static const String stateKey = 'counter';
  
  /// The initial value for the counter state
  static const int initialValue = 0;
  
  /// Register the counter state in the StateStore
  static void register() {
    if (!StateStore.instance.hasState(stateKey)) {
      StateStore.instance.register<int>(stateKey, initialValue);
    }
  }
  
  /// Get the state notifier for the counter
  static StateNotifier<int> getNotifier() {
    return StateStore.instance.getState<int>(stateKey);
  }
}
