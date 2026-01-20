import 'package:firebase_analytics/firebase_analytics.dart';
import 'analytics_service.dart';

// SOLID: LSP, DIP — Implementa AnalyticsService, puede sustituir la abstracción sin romper contratos
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _analytics;

  // SOLID: DIP — Recibe dependencia por constructor, permite inyectar mocks en tests
  FirebaseAnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters?.cast<String, Object>(),
    );
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  FirebaseAnalytics get instance => _analytics;
}
