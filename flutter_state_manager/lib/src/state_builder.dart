import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';

class StateBuilder<T> extends StatefulWidget {
  final String stateKey;
  final Widget Function(BuildContext context, T value) builder;
  final T? initialValue;

  const StateBuilder({
    super.key,
    required this.stateKey,
    required this.builder,
    this.initialValue,
  });

  @override
  StateBuilderState<T> createState() => StateBuilderState<T>();
}

class StateBuilderState<T> extends State<StateBuilder<T>> {
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
        debugPrint('Error in StateBuilder: $e');
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
  void didUpdateWidget(StateBuilder<T> oldWidget) {
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
    return widget.builder(context, _currentValue);
  }
}
