import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'models/app_config.dart';
import 'models/remote_config_snapshot.dart';
import 'remote_config_service.dart';

class FirebaseRemoteConfigService implements RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;
  RemoteConfigSnapshot _snapshot = RemoteConfigSnapshot.initial();

  FirebaseRemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  RemoteConfigSnapshot get snapshot => _snapshot;

  @override
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );

    await setDefaults(_getDefaultValues());

    _snapshot = _snapshot.copyWith(isInitialized: true);
  }

  @override
  Future<bool> fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();

      _snapshot = _snapshot.copyWith(
        appConfig: _buildAppConfig(),
        lastFetchTime: DateTime.now(),
      );

      return activated;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await _remoteConfig.setDefaults(defaults);

    _snapshot = _snapshot.copyWith(
      appConfig: _buildAppConfig(),
    );
  }

  @override
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  @override
  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  @override
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  @override
  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  @override
  Map<String, dynamic> getAll() {
    final allKeys = _remoteConfig.getAll();
    return allKeys.map((key, value) => MapEntry(key, value.asString()));
  }

  AppConfig _buildAppConfig() {
    return AppConfig(
      searchEnabled: getBool('search_enabled'),
      searchMinCharacters: getInt('search_min_characters'),
      searchDebounceMs: getInt('search_debounce_ms'),
      searchPlaceholder: getString('search_placeholder'),
      minAppVersion: getInt('min_app_version'),
      maintenanceMode: getBool('maintenance_mode'),
      maintenanceMessage: getString('maintenance_message'),
    );
  }

  Map<String, dynamic> _getDefaultValues() {
    return {
      'search_enabled': false,
      'search_min_characters': 3,
      'search_debounce_ms': 500,
      'search_placeholder': 'Buscar películas...',
      'min_app_version': 1,
      'maintenance_mode': false,
      'maintenance_message': '',
    };
  }

  FirebaseRemoteConfig get instance => _remoteConfig;
}
