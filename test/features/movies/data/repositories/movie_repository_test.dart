import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imdumb/features/movies/data/models/movie_model.dart';
import 'package:imdumb/features/movies/data/repositories/movie_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late Dio mockDio;
  late Connectivity mockConnectivity;
  late MovieRepository repository;

  setUp(() {
    mockDio = MockDio();
    mockConnectivity = MockConnectivity();

    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    repository = MovieRepository(
      dio: mockDio,
      apiKey: 'test_api_key',
      baseUrl: 'https://api.test.com',
      connectivity: mockConnectivity,
    );
  });

  group('MovieRepository', () {
    group('fetchMovies', () {
      final tResponse = Response(
        data: {
          'results': [
            {
              'id': 1,
              'title': 'Test Movie 1',
              'poster_path': '/test1.jpg',
              'vote_average': 8.0,
              'release_date': '2024-01-01',
              'genre_ids': [28, 12],
            },
            {
              'id': 2,
              'title': 'Test Movie 2',
              'poster_path': '/test2.jpg',
              'vote_average': 7.5,
              'release_date': '2024-01-02',
              'genre_ids': [35],
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      test('returns list of movies when call is successful', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => tResponse);

        final result = await repository.fetchMovies('popular');

        expect(result, isA<List<MovieModel>>());
        expect(result.length, 2);
        expect(result[0].title, 'Test Movie 1');
        expect(result[1].title, 'Test Movie 2');
        verify(() => mockDio.get(
              'https://api.test.com/movie/popular',
              queryParameters: {
                'api_key': 'test_api_key',
                'language': 'es-ES',
                'page': 1,
              },
            )).called(1);
      });

      test('uses correct endpoint for top_rated category', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => tResponse);

        await repository.fetchMovies('top_rated');

        verify(() => mockDio.get(
              'https://api.test.com/movie/top_rated',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('uses correct endpoint for upcoming category', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => tResponse);

        await repository.fetchMovies('upcoming');

        verify(() => mockDio.get(
              'https://api.test.com/movie/upcoming',
              queryParameters: any(named: 'queryParameters'),
            )).called(1);
      });

      test('includes page parameter in query', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => tResponse);

        await repository.fetchMovies('popular', page: 3);

        verify(() => mockDio.get(
              any(),
              queryParameters: {
                'api_key': 'test_api_key',
                'language': 'es-ES',
                'page': 3,
              },
            )).called(1);
      });

      test('throws exception when call fails', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        expect(
          () => repository.fetchMovies('popular'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('searchMovies', () {
      final tResponse = Response(
        data: {
          'results': [
            {
              'id': 1,
              'title': 'Batman',
              'poster_path': '/batman.jpg',
              'vote_average': 8.5,
              'release_date': '2022-03-01',
              'genre_ids': [28],
            },
          ],
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );

      test('returns list of movies when search is successful', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => tResponse);

        final result = await repository.searchMovies('Batman');

        expect(result, isA<List<MovieModel>>());
        expect(result.length, 1);
        expect(result[0].title, 'Batman');
        verify(() => mockDio.get(
              'https://api.test.com/search/movie',
              queryParameters: {
                'api_key': 'test_api_key',
                'language': 'es-ES',
                'query': 'Batman',
              },
            )).called(1);
      });

      test('throws exception when search fails', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          message: 'Network error',
        ));

        expect(
          () => repository.searchMovies('query'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
