import 'package:hive/hive.dart';

part 'hive_movie_model.g.dart';

@HiveType(typeId: 0)
class HiveMovieModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? posterPath;

  @HiveField(3)
  final double voteAverage;

  @HiveField(4)
  final String? releaseDate;

  @HiveField(5)
  final DateTime savedAt;

  HiveMovieModel({
    required this.id,
    required this.title,
    this.posterPath,
    required this.voteAverage,
    this.releaseDate,
    required this.savedAt,
  });

  String get posterUrl {
    if (posterPath == null) return '';
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }
}
