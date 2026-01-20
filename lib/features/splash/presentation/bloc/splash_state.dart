import 'package:equatable/equatable.dart';

/// Base class for Splash states
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial/Loading state while initialization is in progress
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// State when initialization is completed successfully
class SplashLoaded extends SplashState {
  const SplashLoaded();
}

/// State when initialization fails
class SplashError extends SplashState {
  final String message;

  const SplashError(this.message);

  @override
  List<Object?> get props => [message];
}
