import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_detail_model.dart';
import '../../data/repositories/movie_repository.dart';

// Events
abstract class MovieDetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMovieDetail extends MovieDetailEvent {
  final int movieId;

  LoadMovieDetail(this.movieId);

  @override
  List<Object> get props => [movieId];
}

// States
abstract class MovieDetailState extends Equatable {
  @override
  List<Object> get props => [];
}

class MovieDetailLoading extends MovieDetailState {}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetailModel movie;

  MovieDetailLoaded(this.movie);

  @override
  List<Object> get props => [movie];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  MovieDetailError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final MovieRepository repository;

  MovieDetailBloc({required this.repository}) : super(MovieDetailLoading()) {
    on<LoadMovieDetail>(_onLoadMovieDetail);
  }

  Future<void> _onLoadMovieDetail(
    LoadMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(MovieDetailLoading());
    try {
      final movie = await repository.fetchMovieDetail(event.movieId);
      emit(MovieDetailLoaded(movie));
    } catch (e) {
      emit(MovieDetailError(e.toString()));
    }
  }
}
