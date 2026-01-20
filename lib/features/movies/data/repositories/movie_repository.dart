import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../models/actor_model.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';

class MovieRepository {
  final Dio dio;
  final String apiKey;
  final String baseUrl;
  final Connectivity _connectivity;
  static const int _maxRetries = 2;

  MovieRepository({
    required this.dio,
    required this.apiKey,
    required this.baseUrl,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      throw const NoInternetException();
    }
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    await _checkConnectivity();

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        return await operation();
      } on DioException catch (e) {
        final exception = AppExceptionHandler.handleDioException(e);

        if (exception is NoInternetException) {
          throw exception;
        }

        if (attempt == _maxRetries) {
          throw exception;
        }

        if (exception is TimeoutException || exception is NetworkException) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }

        throw exception;
      } catch (e) {
        if (attempt == _maxRetries) {
          throw AppExceptionHandler.handleException(e);
        }
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }

    throw const UnknownException();
  }

  Future<List<MovieModel>> fetchMovies(String category, {int page = 1}) async {
    return _executeWithRetry(() async {
      final endpoint = _getCategoryEndpoint(category);
      final response = await dio.get(
        '$baseUrl$endpoint',
        queryParameters: {
          'api_key': apiKey,
          'language': 'es-ES',
          'page': page,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    });
  }

  Future<MovieDetailModel> fetchMovieDetail(int movieId) async {
    return _executeWithRetry(() async {
      final results = await Future.wait([
        dio.get(
          '$baseUrl/movie/$movieId',
          queryParameters: {
            'api_key': apiKey,
            'language': 'es-ES',
          },
        ),
        dio.get(
          '$baseUrl/movie/$movieId/images',
          queryParameters: {
            'api_key': apiKey,
          },
        ),
        dio.get(
          '$baseUrl/movie/$movieId/credits',
          queryParameters: {
            'api_key': apiKey,
            'language': 'es-ES',
          },
        ),
      ]);

      final detailResponse = results[0];
      final imagesResponse = results[1];
      final creditsResponse = results[2];

      final backdropsList = imagesResponse.data['backdrops'] as List<dynamic>? ?? [];
      final imageUrls = backdropsList
          .take(10)
          .map((img) {
            final path = img['file_path'] as String?;
            if (path == null) return '';
            return 'https://image.tmdb.org/t/p/original$path';
          })
          .where((url) => url.isNotEmpty)
          .toList();

      final castList = creditsResponse.data['cast'] as List<dynamic>? ?? [];
      final actors = castList
          .take(10)
          .map((json) => ActorModel.fromJson(json))
          .toList();

      return MovieDetailModel.fromJson(
        detailResponse.data,
        images: imageUrls,
        cast: actors,
      );
    });
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    return _executeWithRetry(() async {
      final response = await dio.get(
        '$baseUrl/search/movie',
        queryParameters: {
          'api_key': apiKey,
          'language': 'es-ES',
          'query': query,
        },
      );

      final results = response.data['results'] as List<dynamic>;
      return results.map((json) => MovieModel.fromJson(json)).toList();
    });
  }

  String _getCategoryEndpoint(String category) {
    switch (category.toLowerCase()) {
      case 'popular':
        return '/movie/popular';
      case 'top_rated':
      case 'top rated':
        return '/movie/top_rated';
      case 'upcoming':
        return '/movie/upcoming';
      default:
        return '/movie/popular';
    }
  }
}
