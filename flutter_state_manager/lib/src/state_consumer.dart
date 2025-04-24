import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';

class StateConsumer<T> extends StatefulWidget {
  final String stateKey;
  final Widget Function(BuildContext context, T value, void Function(T) updateState) builder;
  final T? initialValue;

  const StateConsumer({
    Key? key,
    required this.stateKey,
    required this.builder,
    this.initialValue,
  }) : super(key: key);

  @override
  StateConsumerState<T> createState() => StateConsumerState<T>();
}

class StateConsumerState<T> extends State<StateConsumer<T>> {
  late Stream<T> _stream;
  late T _currentValue;
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    try {
      final stateNotifier = StateStore.instance.getState<T>(widget.stateKey);
      _stream = stateNotifier.stream;
      _currentValue = stateNotifier.value;
    } catch (e) {
      if (widget.initialValue != null) {
        StateStore.instance.register<T>(widget.stateKey, widget.initialValue as T);
        final stateNotifier = StateStore.instance.getState<T>(widget.stateKey);
        _stream = stateNotifier.stream;
        _currentValue = stateNotifier.value;
      } else {
        debugPrint('Error in StateConsumer: $e');
        rethrow;
      }
    }
    
    _subscription = _stream.listen((data) {
      if (mounted) {
        setState(() {
          _currentValue = data;
        });
      }
    });
  }

  @override
  void didUpdateWidget(StateConsumer<T> oldWidget) {
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

  void _updateState(T newValue) {
    try {
      StateStore.instance.setValue<T>(widget.stateKey, newValue);
    } catch (e) {
      debugPrint('Error updating state in StateConsumer: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue, _updateState);
  }
}
