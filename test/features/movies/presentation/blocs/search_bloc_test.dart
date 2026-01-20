import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imdumb/features/movies/data/models/movie_model.dart';
import 'package:imdumb/features/movies/data/repositories/movie_repository.dart';
import 'package:imdumb/features/movies/presentation/blocs/search_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MovieRepository mockRepository;
  late SearchBloc bloc;

  setUp(() {
    mockRepository = MockMovieRepository();
    bloc = SearchBloc(
      repository: mockRepository,
      debounceMilliseconds: 100,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final List<MovieModel> tMovies = [
    MovieModel(
      id: 1,
      title: 'Test Movie 1',
      posterPath: '/test1.jpg',
      voteAverage: 8.0,
      releaseDate: '2024-01-01',
      genreIds: const [28],
    ),
    MovieModel(
      id: 2,
      title: 'Test Movie 2',
      posterPath: '/test2.jpg',
      voteAverage: 7.5,
      releaseDate: '2024-01-02',
      genreIds: const [12],
    ),
  ];

  group('SearchBloc', () {
    test('initial state is SearchInitial', () {
      expect(bloc.state, isA<SearchInitial>());
    });

    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial when query is empty',
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchQueryChanged('')),
      expect: () => [isA<SearchInitial>()],
      verify: (_) {
        verifyNever(() => mockRepository.searchMovies(any()));
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial when query is only whitespace',
      build: () => bloc,
      act: (bloc) => bloc.add(const SearchQueryChanged('   ')),
      expect: () => [isA<SearchInitial>()],
      verify: (_) {
        verifyNever(() => mockRepository.searchMovies(any()));
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [Loading, Loaded] when search succeeds',
      build: () {
        when(() => mockRepository.searchMovies('batman'))
            .thenAnswer((_) async => tMovies);
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('batman')),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>()
            .having((s) => s.movies, 'movies', tMovies)
            .having((s) => s.query, 'query', 'batman'),
      ],
      verify: (_) {
        verify(() => mockRepository.searchMovies('batman')).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [Loading, Empty] when search returns no results',
      build: () {
        when(() => mockRepository.searchMovies('nonexistent'))
            .thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('nonexistent')),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchEmpty>()
            .having((s) => s.query, 'query', 'nonexistent'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [Loading, Error] when search fails',
      build: () {
        when(() => mockRepository.searchMovies(any()))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('query')),
      wait: const Duration(milliseconds: 200),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchError>()
            .having((s) => s.message, 'message', contains('Network error')),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial when SearchCleared is called',
      build: () => bloc,
      seed: () => SearchLoaded(tMovies, 'batman'),
      act: (bloc) => bloc.add(SearchCleared()),
      expect: () => [isA<SearchInitial>()],
    );
  });
}
