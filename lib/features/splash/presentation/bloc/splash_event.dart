import 'package:equatable/equatable.dart';

/// Base class for Splash events
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event to trigger app initialization
class InitializeApp extends SplashEvent {
  final String environment;

  const InitializeApp(this.environment);

  @override
  List<Object?> get props => [environment];
}
