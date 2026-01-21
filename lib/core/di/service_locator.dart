import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/movies/data/repositories/movie_repository.dart';
import '../../features/movies/presentation/blocs/home_bloc.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../analytics/analytics_service.dart';
import '../analytics/firebase_analytics_service.dart';
import '../config/app_initializer.dart';
import '../local/hive_service.dart';
import '../local/shared_prefs_service.dart';
import '../remote_config/firebase_remote_config_service.dart';

final serviceLocator = GetIt.instance;

// SOLID: DIP — Inyección de dependencias centralizada, registra abstracciones
Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  serviceLocator.registerLazySingleton(() => dio);

  // Infrastructure layer - Storage & Remote Config
  serviceLocator.registerLazySingleton(
    () => SharedPrefsService(serviceLocator()),
  );

  final hiveService = HiveService();
  await hiveService.init();
  serviceLocator.registerLazySingleton(() => hiveService);

  serviceLocator.registerLazySingleton(
    () => FirebaseRemoteConfigService(),
  );

  // SOLID: DIP — Registro de interfaz → implementación permite cambiar providers sin modificar consumidores
  final analyticsService = FirebaseAnalyticsService();
  serviceLocator.registerLazySingleton<AnalyticsService>(() => analyticsService);
  serviceLocator.registerLazySingleton<FirebaseAnalyticsService>(() => analyticsService);

  // App Initializer
  serviceLocator.registerLazySingleton(
    () => AppInitializer(
      remoteConfig: serviceLocator<FirebaseRemoteConfigService>(),
      hiveService: serviceLocator<HiveService>(),
    ),
  );

  // Repository layer
  serviceLocator.registerLazySingleton(
    () => MovieRepository(
      dio: serviceLocator(),
      apiKey: dotenv.env['TMDB_API_KEY'] ?? '',
      baseUrl: dotenv.env['TMDB_BASE_URL'] ?? '',
    ),
  );

  // Presentation layer - BLoCs (factories)
  serviceLocator.registerFactory(
    () => SplashBloc(appInitializer: serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => HomeBloc(repository: serviceLocator()),
  );
}
