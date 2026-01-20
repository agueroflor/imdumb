import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../firebase_options.dart';

class RemoteConfigService {
  static const String _initialMessageKey = 'initial_message';
  static const String _enableExperimentalSearchKey = 'enable_experimental_search';
  static const String _defaultInitialMessage = 'Welcome to IMDUMB!';
  static const bool _defaultEnableExperimentalSearch = false;

  Future<Map<String, dynamic>> fetchAndActivate(String environment) async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setDefaults({
        _initialMessageKey: _defaultInitialMessage,
        _enableExperimentalSearchKey: _defaultEnableExperimentalSearch,
      });

      final fetchInterval = environment == 'development'
          ? Duration.zero
          : const Duration(hours: 12);

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: fetchInterval,
        ),
      );

      await remoteConfig.fetchAndActivate();

      return {
        'initial_message': remoteConfig.getString(_initialMessageKey),
        'enable_experimental_search': remoteConfig.getBool(_enableExperimentalSearchKey),
      };
    } catch (e) {
      throw Exception('Failed to fetch remote config: $e');
    }
  }
}
