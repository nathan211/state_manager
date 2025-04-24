import 'dart:async';
import 'package:flutter/material.dart';
import 'state_store.dart';

class FieldBuilder<T, R> extends StatefulWidget {
  final String stateKey;
  final String fieldPath;
  final R Function(T) selector;
  final Widget Function(BuildContext context, R value) builder;
  final T? initialValue;

  const FieldBuilder({
    super.key,
    required this.stateKey,
    required this.fieldPath,
    required this.selector,
    required this.builder,
    this.initialValue,
  });

  @override
  FieldBuilderState<T, R> createState() => FieldBuilderState<T, R>();
}

class FieldBuilderState<T, R> extends State<FieldBuilder<T, R>> {
  late Stream<R> _stream;
  late R _currentValue;
  StreamSubscription<R>? _subscription;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    try {
      final complexNotifier = StateStore.instance.getComplexState<T>(widget.stateKey);
      _currentValue = widget.selector(complexNotifier.value);
      _stream = complexNotifier.fieldStream<R>(widget.fieldPath, widget.selector);
    } catch (e) {
      if (widget.initialValue != null) {
        StateStore.instance.registerComplex<T>(widget.stateKey, widget.initialValue as T);
        final complexNotifier = StateStore.instance.getComplexState<T>(widget.stateKey);
        _currentValue = widget.selector(complexNotifier.value);
        _stream = complexNotifier.fieldStream<R>(widget.fieldPath, widget.selector);
      } else {
        debugPrint('Error initializing FieldBuilder: $e');
        rethrow;
      }
    }
    
    _subscription = _stream.listen((data) {
      if (!_isDisposed && mounted) {
        setState(() {
          _currentValue = data;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FieldBuilder<T, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateKey != widget.stateKey || 
        oldWidget.fieldPath != widget.fieldPath || 
        oldWidget.selector != widget.selector) {
      _subscription?.cancel();
      _subscription = null;
      
      _initializeState();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentValue);
  }
}
