class MovieModel {
  final int id;
  final String title;
  final String? posterPath;
  final double voteAverage;
  final String? releaseDate;
  final List<int> genreIds;

  MovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    this.genreIds = const [],
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final genreIdsList = json['genre_ids'] as List<dynamic>?;

    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String?,
      genreIds: genreIdsList?.map((e) => e as int).toList() ?? [],
    );
  }

  String get posterUrl {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  List<String> get genres {
    return genreIds.take(3).map((id) => _getGenreName(id)).toList();
  }

  static String _getGenreName(int id) {
    const genreMap = {
      28: 'Acción',
      12: 'Aventura',
      16: 'Animación',
      35: 'Comedia',
      80: 'Crimen',
      99: 'Documental',
      18: 'Drama',
      10751: 'Familiar',
      14: 'Fantasía',
      36: 'Historia',
      27: 'Terror',
      10402: 'Música',
      9648: 'Misterio',
      10749: 'Romance',
      878: 'Ciencia ficción',
      10770: 'Película de TV',
      53: 'Thriller',
      10752: 'Bélica',
      37: 'Western',
    };
    return genreMap[id] ?? 'Otro';
  }
}
