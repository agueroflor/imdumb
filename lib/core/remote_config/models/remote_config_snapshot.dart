import 'app_config.dart';

class RemoteConfigSnapshot {
  final AppConfig appConfig;
  final DateTime lastFetchTime;
  final bool isInitialized;

  const RemoteConfigSnapshot({
    required this.appConfig,
    required this.lastFetchTime,
    required this.isInitialized,
  });

  factory RemoteConfigSnapshot.initial() {
    return RemoteConfigSnapshot(
      appConfig: AppConfig.defaultConfig(),
      lastFetchTime: DateTime.now(),
      isInitialized: false,
    );
  }

  RemoteConfigSnapshot copyWith({
    AppConfig? appConfig,
    DateTime? lastFetchTime,
    bool? isInitialized,
  }) {
    return RemoteConfigSnapshot(
      appConfig: appConfig ?? this.appConfig,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
