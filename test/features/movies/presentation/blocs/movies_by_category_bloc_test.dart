import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imdumb/features/movies/data/models/movie_model.dart';
import 'package:imdumb/features/movies/data/repositories/movie_repository.dart';
import 'package:imdumb/features/movies/presentation/blocs/movies_by_category_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MovieRepository mockRepository;
  late MoviesByCategoryBloc bloc;

  setUp(() {
    mockRepository = MockMovieRepository();
    bloc = MoviesByCategoryBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final List<MovieModel> tMovies = [
    MovieModel(
      id: 1,
      title: 'Movie 1',
      posterPath: '/path1.jpg',
      voteAverage: 8.5,
      releaseDate: '2024-01-01',
      genreIds: const [28, 12],
    ),
    MovieModel(
      id: 2,
      title: 'Movie 2',
      posterPath: '/path2.jpg',
      voteAverage: 7.5,
      releaseDate: '2024-01-02',
      genreIds: const [35],
    ),
  ];

  group('MoviesByCategoryBloc', () {
    test('initial state is MoviesByCategoryLoading', () {
      expect(bloc.state, isA<MoviesByCategoryLoading>());
    });

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'emits [Loading, Loaded] when LoadMoviesByCategory succeeds',
      build: () {
        when(() => mockRepository.fetchMovies('popular', page: 1))
            .thenAnswer((_) async => tMovies);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadMoviesByCategory('popular')),
      expect: () => [
        isA<MoviesByCategoryLoading>(),
        isA<MoviesByCategoryLoaded>()
            .having((s) => s.movies, 'movies', tMovies)
            .having((s) => s.hasReachedMax, 'hasReachedMax', false)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchMovies('popular', page: 1)).called(1);
      },
    );

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'emits [Loading, Loaded] with hasReachedMax=true when no movies returned',
      build: () {
        when(() => mockRepository.fetchMovies('popular', page: 1))
            .thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadMoviesByCategory('popular')),
      expect: () => [
        isA<MoviesByCategoryLoading>(),
        isA<MoviesByCategoryLoaded>()
            .having((s) => s.movies, 'movies', isEmpty)
            .having((s) => s.hasReachedMax, 'hasReachedMax', true),
      ],
    );

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'emits [Loading, Error] when LoadMoviesByCategory fails',
      build: () {
        when(() => mockRepository.fetchMovies('popular', page: 1))
            .thenThrow(Exception('Failed to fetch'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadMoviesByCategory('popular')),
      expect: () => [
        isA<MoviesByCategoryLoading>(),
        isA<MoviesByCategoryError>()
            .having((s) => s.message, 'message', contains('error')),
      ],
    );

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'emits [Loaded with isLoadingMore=true, Loaded with new movies] when LoadMoreMovies succeeds',
      build: () {
        when(() => mockRepository.fetchMovies('popular', page: 1))
            .thenAnswer((_) async => tMovies);
        when(() => mockRepository.fetchMovies('popular', page: 2))
            .thenAnswer((_) async => [
          MovieModel(
            id: 3,
            title: 'Movie 3',
            posterPath: '/path3.jpg',
            voteAverage: 6.5,
            releaseDate: '2024-01-03',
            genreIds: const [18],
          ),
        ]);
        return bloc;
      },
      seed: () => MoviesByCategoryLoaded(
        movies: tMovies,
        hasReachedMax: false,
        isLoadingMore: false,
      ),
      act: (bloc) {
        bloc
          ..add(LoadMoviesByCategory('popular'))
          ..add(LoadMoreMovies());
      },
      skip: 2,
      expect: () => [
        isA<MoviesByCategoryLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.movies.length, 'movies length', 2),
        isA<MoviesByCategoryLoaded>()
            .having((s) => s.movies.length, 'movies length', 3)
            .having((s) => s.hasReachedMax, 'hasReachedMax', false)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false),
      ],
    );

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'emits [Loaded with isLoadingMore=true, Loaded with hasReachedMax=true] when LoadMoreMovies returns empty',
      build: () {
        when(() => mockRepository.fetchMovies('popular', page: 1))
            .thenAnswer((_) async => tMovies);
        when(() => mockRepository.fetchMovies('popular', page: 2))
            .thenAnswer((_) async => []);
        return bloc;
      },
      seed: () => MoviesByCategoryLoaded(
        movies: tMovies,
        hasReachedMax: false,
        isLoadingMore: false,
      ),
      act: (bloc) {
        bloc
          ..add(LoadMoviesByCategory('popular'))
          ..add(LoadMoreMovies());
      },
      skip: 2,
      expect: () => [
        isA<MoviesByCategoryLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<MoviesByCategoryLoaded>()
            .having((s) => s.hasReachedMax, 'hasReachedMax', true)
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.movies.length, 'movies length', 2),
      ],
    );

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'does not emit when LoadMoreMovies is called with hasReachedMax=true',
      build: () => bloc,
      seed: () => MoviesByCategoryLoaded(
        movies: tMovies,
        hasReachedMax: true,
        isLoadingMore: false,
      ),
      act: (bloc) => bloc.add(LoadMoreMovies()),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepository.fetchMovies(any(), page: any(named: 'page')));
      },
    );

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'does not emit when LoadMoreMovies is called with isLoadingMore=true',
      build: () => bloc,
      seed: () => MoviesByCategoryLoaded(
        movies: tMovies,
        hasReachedMax: false,
        isLoadingMore: true,
      ),
      act: (bloc) => bloc.add(LoadMoreMovies()),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockRepository.fetchMovies(any(), page: any(named: 'page')));
      },
    );

    blocTest<MoviesByCategoryBloc, MoviesByCategoryState>(
      'emits Error when LoadMoreMovies fails',
      build: () {
        when(() => mockRepository.fetchMovies('popular', page: 1))
            .thenAnswer((_) async => tMovies);
        when(() => mockRepository.fetchMovies('popular', page: 2))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      seed: () => MoviesByCategoryLoaded(
        movies: tMovies,
        hasReachedMax: false,
        isLoadingMore: false,
      ),
      act: (bloc) {
        bloc
          ..add(LoadMoviesByCategory('popular'))
          ..add(LoadMoreMovies());
      },
      skip: 2,
      expect: () => [
        isA<MoviesByCategoryLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<MoviesByCategoryError>()
            .having((s) => s.message, 'message', contains('error')),
      ],
    );
  });
}
