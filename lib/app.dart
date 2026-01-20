import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/analytics/analytics_navigation_observer.dart';
import 'core/analytics/firebase_analytics_service.dart';
import 'core/di/service_locator.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/splash/presentation/pages/splash_page.dart';

class MyApp extends StatelessWidget {
  final String env;
  const MyApp({super.key, required this.env});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMDUMB ($env)',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        AnalyticsNavigationObserver(
          analyticsService: serviceLocator<FirebaseAnalyticsService>(),
        ),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => serviceLocator<SplashBloc>(),
        child: SplashPage(environment: env),
      ),
    );
  }
}
