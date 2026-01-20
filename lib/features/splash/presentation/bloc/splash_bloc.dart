import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_initializer.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AppInitializer appInitializer;

  SplashBloc({
    required this.appInitializer,
  }) : super(const SplashLoading()) {
    on<InitializeApp>(_onInitializeApp);
  }

  Future<void> _onInitializeApp(
    InitializeApp event,
    Emitter<SplashState> emit,
  ) async {
    try {
      await appInitializer.initialize();
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const SplashLoaded());
    } catch (e) {
      emit(SplashError(e.toString()));
    }
  }
}
