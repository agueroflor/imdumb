import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

class SearchCleared extends SearchEvent {}

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<MovieModel> movies;
  final String query;

  const SearchLoaded(this.movies, this.query);

  @override
  List<Object> get props => [movies, query];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);

  @override
  List<Object> get props => [query];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MovieRepository repository;
  final int debounceMilliseconds;

  SearchBloc({
    required this.repository,
    this.debounceMilliseconds = 500,
  }) : super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) {
        return events
            .distinct((prev, next) => prev.query == next.query)
            .asyncExpand((event) async* {
              await Future.delayed(Duration(milliseconds: debounceMilliseconds));
              yield* mapper(event);
            });
      },
    );
    on<SearchCleared>(_onSearchCleared);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final movies = await repository.searchMovies(query);

      if (emit.isDone) return;

      if (movies.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchLoaded(movies, query));
      }
    } catch (e) {
      if (emit.isDone) return;
      emit(SearchError(e.toString()));
    }
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}
