import 'dart:async';

class StateNotifier<T> {
  StateNotifier(T initialValue) : _value = initialValue;
  
  T _value;
  final _controller = StreamController<T>.broadcast();
  
  // Get current value
  T get value => _value;
  
  // Get stream of values
  Stream<T> get stream => _controller.stream;
  
  // Update value
  void update(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      _controller.add(_value);
    }
  }
  
  // Update value using a function
  void updateWith(T Function(T currentValue) updater) {
    final newValue = updater(_value);
    update(newValue);
  }
  
  // Dispose resources
  void dispose() {
    _controller.close();
  }
}
