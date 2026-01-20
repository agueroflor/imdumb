import '../remote_config/firebase_remote_config_service.dart';
import '../local/hive_service.dart';

final class AppInitializer {
  final FirebaseRemoteConfigService remoteConfig;
  final HiveService hiveService;

  AppInitializer({
    required this.remoteConfig,
    required this.hiveService,
  });

  Future<void> initialize() async {
    // Initialize Hive
    await hiveService.init();

    // Initialize and fetch Remote Config
    await remoteConfig.initialize();
    await remoteConfig.fetchAndActivate();
  }
}
