import 'dart:async';

class ComplexStateNotifier<T> {
  ComplexStateNotifier(T initialValue) : _value = initialValue;
  
  T _value;
  final _controller = StreamController<T>.broadcast();
  final Map<String, StreamController<dynamic>> _fieldControllers = {};
  final Map<String, int> _fieldListenerCount = {}; // Track listener count for each field
  
  // Get current value
  T get value => _value;
  
  // Get stream of values
  Stream<T> get stream => _controller.stream;
  
  // Get a stream for a specific field
  Stream<R> fieldStream<R>(String fieldPath, R Function(T) selector) {
    if (!_fieldControllers.containsKey(fieldPath)) {
      final controller = StreamController<R>.broadcast(
        onListen: () {
          // Increment listener count when someone listens
          _fieldListenerCount[fieldPath] = (_fieldListenerCount[fieldPath] ?? 0) + 1;
        },
        onCancel: () {
          // Decrement listener count when a listener cancels
          final count = (_fieldListenerCount[fieldPath] ?? 1) - 1;
          _fieldListenerCount[fieldPath] = count;
          
          // If no more listeners, close and remove the controller
          if (count <= 0) {
            _cleanupFieldController(fieldPath);
          }
        }
      );
      _fieldControllers[fieldPath] = controller;
      _fieldListenerCount[fieldPath] = 0; // Initialize count
    }
    
    return (_fieldControllers[fieldPath] as StreamController<R>).stream;
  }
  
  // Clean up a field controller
  void _cleanupFieldController(String fieldPath) {
    final controller = _fieldControllers[fieldPath];
    if (controller != null && !controller.hasListener) {
      controller.close();
      _fieldControllers.remove(fieldPath);
      _fieldListenerCount.remove(fieldPath);
    }
  }
  
  // Update value
  void update(T newValue) {
    if (!_areEqual(_value, newValue)) {
      final oldValue = _value;
      _value = newValue;
      _controller.add(_value);
      
      // Notify field listeners if their values changed
      for (final entry in _fieldControllers.entries) {
        final fieldPath = entry.key;
        final parts = fieldPath.split('.');
        
        dynamic oldFieldValue = oldValue;
        dynamic newFieldValue = newValue;
        
        bool pathValid = true;
        for (final part in parts) {
          if (oldFieldValue is Map) {
            oldFieldValue = oldFieldValue[part];
            newFieldValue = newFieldValue[part];
          } else if (oldFieldValue is List && newFieldValue is List) {
            final index = int.tryParse(part);
            if (index != null && index >= 0) {
              if (index < oldFieldValue.length) {
                oldFieldValue = oldFieldValue[index];
              } else {
                pathValid = false;
                break;
              }
              
              if (index < newFieldValue.length) {
                newFieldValue = newFieldValue[index];
              } else {
                pathValid = false;
                break;
              }
            } else {
              pathValid = false;
              break;
            }
          } else {
            pathValid = false;
            break;
          }
        }
        
        if (pathValid && !_areEqual(oldFieldValue, newFieldValue)) {
          try {
            entry.value.add(newFieldValue);
          } catch (e) {
            // Handle case where controller might be closed
            print('Error updating field $fieldPath: $e');
          }
        }
      }
    }
  }
  
  // Update value using a function
  void updateWith(T Function(T currentValue) updater) {
    final newValue = updater(_value);
    update(newValue);
  }
  
  // Update a specific field
  void updateField<R>(String fieldPath, R newValue) {
    final parts = fieldPath.split('.');
    final newState = _deepCopy(_value);
    
    dynamic current = newState;
    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (current is Map) {
        if (!current.containsKey(part)) {
          current[part] = {};
        }
        current = current[part];
      } else if (current is List) {
        final index = int.tryParse(part);
        if (index != null && index >= 0 && index < current.length) {
          current = current[index];
        } else {
          throw Exception('Invalid path: $fieldPath');
        }
      } else {
        throw Exception('Cannot navigate path: $fieldPath');
      }
    }
    
    final lastPart = parts.last;
    if (current is Map) {
      current[lastPart] = newValue;
    } else if (current is List) {
      final index = int.tryParse(lastPart);
      if (index != null && index >= 0 && index < current.length) {
        current[index] = newValue;
      } else {
        throw Exception('Invalid list index in path: $fieldPath');
      }
    } else {
      throw Exception('Cannot set value at path: $fieldPath');
    }
    
    update(newState as T);
  }
  
  // Deep copy an object
  dynamic _deepCopy(dynamic value) {
    if (value is Map) {
      return Map<dynamic, dynamic>.from(
        value.map((k, v) => MapEntry(k, _deepCopy(v)))
      );
    } else if (value is List) {
      return value.map(_deepCopy).toList();
    } else {
      return value;
    }
  }
  
  // Compare two values for equality
  bool _areEqual(dynamic a, dynamic b) {
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_areEqual(a[key], b[key])) {
          return false;
        }
      }
      return true;
    } else if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_areEqual(a[i], b[i])) return false;
      }
      return true;
    } else {
      return a == b;
    }
  }
  
  // Dispose resources
  void dispose() {
    _controller.close();
    
    // Close all field controllers
    for (final controller in _fieldControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _fieldControllers.clear();
    _fieldListenerCount.clear();
  }
}
