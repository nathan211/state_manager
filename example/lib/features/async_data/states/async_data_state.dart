import 'package:flutter_state_manager/flutter_state_manager.dart';

/// Defines the state and operations for the async data feature
class AsyncDataState {
  /// The key used to access the async data state in the StateStore
  static final String stateKey = StateKey.forFeature('async_data', 'state');
}
