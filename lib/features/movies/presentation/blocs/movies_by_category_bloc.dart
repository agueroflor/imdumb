import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

// Events
abstract class MoviesByCategoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadMoviesByCategory extends MoviesByCategoryEvent {
  final String category;

  LoadMoviesByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class LoadMoreMovies extends MoviesByCategoryEvent {}

// States
abstract class MoviesByCategoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class MoviesByCategoryLoading extends MoviesByCategoryState {}

class MoviesByCategoryLoaded extends MoviesByCategoryState {
  final List<MovieModel> movies;
  final bool hasReachedMax;
  final bool isLoadingMore;

  MoviesByCategoryLoaded({
    required this.movies,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  MoviesByCategoryLoaded copyWith({
    List<MovieModel>? movies,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return MoviesByCategoryLoaded(
      movies: movies ?? this.movies,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [movies, hasReachedMax, isLoadingMore];
}

class MoviesByCategoryError extends MoviesByCategoryState {
  final String message;

  MoviesByCategoryError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class MoviesByCategoryBloc extends Bloc<MoviesByCategoryEvent, MoviesByCategoryState> {
  final MovieRepository repository;
  String _currentCategory = '';
  int _currentPage = 1;

  MoviesByCategoryBloc({required this.repository}) : super(MoviesByCategoryLoading()) {
    on<LoadMoviesByCategory>(_onLoadMoviesByCategory);
    on<LoadMoreMovies>(_onLoadMoreMovies);
  }

  Future<void> _onLoadMoviesByCategory(
    LoadMoviesByCategory event,
    Emitter<MoviesByCategoryState> emit,
  ) async {
    emit(MoviesByCategoryLoading());
    _currentCategory = event.category;
    _currentPage = 1;

    try {
      final movies = await repository.fetchMovies(event.category, page: 1);
      emit(MoviesByCategoryLoaded(
        movies: movies,
        hasReachedMax: movies.isEmpty,
      ));
    } on AppException catch (e) {
      emit(MoviesByCategoryError(e.userFriendlyMessage));
    } catch (e) {
      emit(MoviesByCategoryError('Ocurrió un error inesperado. Por favor, intenta nuevamente.'));
    }
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMovies event,
    Emitter<MoviesByCategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MoviesByCategoryLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));
    _currentPage++;

    try {
      final newMovies = await repository.fetchMovies(_currentCategory, page: _currentPage);

      emit(
        newMovies.isEmpty
            ? currentState.copyWith(hasReachedMax: true, isLoadingMore: false)
            : currentState.copyWith(
                movies: List.of(currentState.movies)..addAll(newMovies),
                hasReachedMax: false,
                isLoadingMore: false,
              ),
      );
    } on AppException catch (e) {
      emit(MoviesByCategoryError(e.userFriendlyMessage));
    } catch (e) {
      emit(MoviesByCategoryError('Ocurrió un error inesperado. Por favor, intenta nuevamente.'));
    }
  }
}
