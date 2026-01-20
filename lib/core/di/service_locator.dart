import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../config/app_initializer.dart';
import '../config/remote_config_service.dart';
import '../local/shared_prefs_service.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  // Services
  serviceLocator.registerLazySingleton(() => RemoteConfigService());
  serviceLocator.registerLazySingleton(() => SharedPrefsService(serviceLocator()));

  // App Initializer
  serviceLocator.registerLazySingleton(
    () => AppInitializer(
      remoteConfig: serviceLocator(),
      sharedPrefs: serviceLocator(),
    ),
  );

  // BLoC
  serviceLocator.registerFactory(
    () => SplashBloc(appInitializer: serviceLocator()),
  );
}
