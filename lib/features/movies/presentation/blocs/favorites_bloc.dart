import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/local/hive_movie_model.dart';
import '../../../../core/local/hive_service.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class RemoveFavorite extends FavoritesEvent {
  final int movieId;

  const RemoveFavorite(this.movieId);

  @override
  List<Object> get props => [movieId];
}

// States
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<HiveMovieModel> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object> get props => [favorites];
}

class FavoritesEmpty extends FavoritesState {}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final HiveService hiveService;

  FavoritesBloc({required this.hiveService}) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFavorite>(_onRemoveFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());

    try {
      final favorites = hiveService.getAllFavorites();

      if (favorites.isEmpty) {
        emit(FavoritesEmpty());
      } else {
        emit(FavoritesLoaded(favorites));
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await hiveService.removeFavoriteMovie(event.movieId);

      // Reload favorites
      add(LoadFavorites());
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
