import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'firebase_analytics_service.dart';

class AnalyticsNavigationObserver extends NavigatorObserver {
  final FirebaseAnalyticsObserver _observer;

  AnalyticsNavigationObserver({required FirebaseAnalyticsService analyticsService})
      : _observer = FirebaseAnalyticsObserver(analytics: analyticsService.instance);

  @override
  void didPush(Route route, Route? previousRoute) {
    _observer.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _observer.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _observer.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
