import 'remote_config_service.dart';
import '../local/shared_prefs_service.dart';

final class AppInitializer {
  final RemoteConfigService remoteConfig;
  final SharedPrefsService sharedPrefs;

  AppInitializer({
    required this.remoteConfig,
    required this.sharedPrefs,
  });

  Future<void> initialize(String environment) async {
    try {
      final config = await remoteConfig.fetchAndActivate(environment);
      await sharedPrefs.saveConfig(config);
    } catch (e) {
      final cachedConfig = sharedPrefs.getConfig();
      if (cachedConfig == null) {
        rethrow;
      }
    }
  }
}
