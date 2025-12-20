import 'dart:async';
import 'package:flutter/material.dart';

/// Base class for StatefulWidget that automatically manages
/// Timer and StreamSubscription lifecycle
abstract class BaseStatefulWidget<T extends StatefulWidget> extends State<T> {
  final List<Timer> _timers = [];
  final List<StreamSubscription> _subscriptions = [];

  /// Register a timer to be automatically cancelled on dispose
  void registerTimer(Timer timer) {
    _timers.add(timer);
  }

  /// Register a StreamSubscription to be automatically cancelled on dispose
  void registerSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Cancel all timers (useful for restarting polling)
  void cancelAllTimers() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Check if any timer is active
  bool hasActiveTimers() {
    return _timers.any((timer) => timer.isActive);
  }

  /// Safe setState that checks if widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  void dispose() {
    // Cancel all timers
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();

    // Cancel all subscriptions
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }
}

