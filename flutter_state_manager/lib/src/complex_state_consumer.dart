import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';
import 'complex_state_notifier.dart';

/// A widget that both consumes and allows updating complex state.
///
/// Similar to [StateConsumer] but specifically designed for complex state objects
/// like maps, lists, and arrays that are managed by [ComplexStateNotifier].
class ComplexStateConsumer<T> extends StatefulWidget {
  /// The key used to access the state in the [StateStore]
  final String stateKey;
  
  /// The builder function that builds the widget based on the current state value
  /// and provides a function to update the state
  final Widget Function(BuildContext context, T value, void Function(T) updateState) builder;
  
  /// The initial value to register if the state doesn't exist yet
  final T? initialValue;

  /// Creates a ComplexStateConsumer widget.
  ///
  /// The [stateKey] and [builder] parameters must not be null.
  /// If the state with [stateKey] doesn't exist, it will be registered with [initialValue].
  const ComplexStateConsumer({
    Key? key,
    required this.stateKey,
    required this.builder,
    this.initialValue,
  }) : super(key: key);

  @override
  ComplexStateConsumerState<T> createState() => ComplexStateConsumerState<T>();
}

class ComplexStateConsumerState<T> extends State<ComplexStateConsumer<T>> {
  /// The notifier for the complex state
  late ComplexStateNotifier<T> _notifier;
  
  /// The current value of the state
  late T _currentValue;
  
  /// The subscription to the state changes
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  /// Initialize the state and subscribe to changes
  void _initializeState() {
    try {
      _notifier = StateStore.instance.getComplexState<T>(widget.stateKey);
      _currentValue = _notifier.value;
    } catch (e) {
      if (widget.initialValue != null) {
        StateStore.instance.registerComplex<T>(widget.stateKey, widget.initialValue as T);
        _notifier = StateStore.instance.getComplexState<T>(widget.stateKey);
        _currentValue = _notifier.value;
      } else {
        debugPrint('Error in ComplexStateConsumer: $e');
        rethrow;
      }
    }
    
    _subscription = _notifier.stream.listen((data) {
      if (mounted) {
        setState(() {
          _currentValue = data;
        });
      }
    });
  }

  /// Update the state with a new value
  void _updateState(T newValue) {
    _notifier.update(newValue);
  }

  @override
  void didUpdateWidget(ComplexStateConsumer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateKey != widget.stateKey) {
      _subscription?.cancel();
      _subscription = null;
      _initializeState();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue, _updateState);
  }
}
