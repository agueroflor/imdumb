abstract class AnalyticsService {
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  });

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  });

  Future<void> setUserId(String userId);

  Future<void> setUserProperty({
    required String name,
    required String value,
  });
}
