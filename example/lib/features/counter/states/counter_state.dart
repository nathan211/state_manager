import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Defines the state key for the counter feature
class CounterState {
  /// The key used to access the counter state in the StateStore
  static final String stateKey = StateKey.forFeature('counter', 'value');
  
  /// The initial value for the counter state
  static const int initialValue = 0;
}
