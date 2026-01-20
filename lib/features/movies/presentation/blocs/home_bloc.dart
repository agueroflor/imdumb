import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

abstract class HomeEvent {}

class LoadHomeMovies extends HomeEvent {}

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<MovieModel> popularMovies;
  final List<MovieModel> topRatedMovies;
  final List<MovieModel> upcomingMovies;

  HomeLoaded({
    required this.popularMovies,
    required this.topRatedMovies,
    required this.upcomingMovies,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MovieRepository repository;

  HomeBloc({required this.repository}) : super(HomeInitial()) {
    on<LoadHomeMovies>(_onLoadHomeMovies);
  }

  Future<void> _onLoadHomeMovies(
    LoadHomeMovies event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        repository.fetchMovies('popular'),
        repository.fetchMovies('top_rated'),
        repository.fetchMovies('upcoming'),
      ]);

      emit(HomeLoaded(
        popularMovies: results[0].take(6).toList(),
        topRatedMovies: results[1].take(3).toList(),
        upcomingMovies: results[2].take(3).toList(),
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
