import 'actor_model.dart';

class MovieDetailModel {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final String? releaseDate;
  final List<String> genres;
  final int runtime;
  final List<String> images;
  final List<ActorModel> cast;
  final String originalLanguage;

  MovieDetailModel({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    this.releaseDate,
    required this.genres,
    required this.runtime,
    required this.images,
    required this.cast,
    required this.originalLanguage,
  });

  factory MovieDetailModel.fromJson(
    Map<String, dynamic> json, {
    List<String>? images,
    List<ActorModel>? cast,
  }) {
    final genresList = json['genres'] as List<dynamic>? ?? [];
    final genreNames = genresList
        .map((g) => g['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return MovieDetailModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String?,
      genres: genreNames,
      runtime: json['runtime'] as int? ?? 0,
      images: images ?? [],
      cast: cast ?? [],
      originalLanguage: json['original_language'] as String? ?? 'en',
    );
  }

  String get languageName {
    const languageMap = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ja': '日本語',
      'ko': '한국어',
      'zh': '中文',
      'ru': 'Русский',
      'ar': 'العربية',
      'hi': 'हिन्दी',
      'tr': 'Türkçe',
      'nl': 'Nederlands',
      'sv': 'Svenska',
      'pl': 'Polski',
      'da': 'Dansk',
      'fi': 'Suomi',
      'no': 'Norsk',
      'th': 'ไทย',
    };
    return languageMap[originalLanguage] ?? originalLanguage.toUpperCase();
  }

  String get posterUrl {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get backdropUrl {
    if (backdropPath == null) return '';
    return 'https://image.tmdb.org/t/p/original$backdropPath';
  }
}
