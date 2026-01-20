import 'package:hive_flutter/hive_flutter.dart';
import 'hive_movie_model.dart';

// SOLID: SRP, ISP — Solo gestiona favoritos con Hive, no mezcla otros storages
class HiveService {
  static const String _movieBoxName = 'favorite_movies';
  Box<HiveMovieModel>? _movieBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HiveMovieModelAdapter());
    _movieBox = await Hive.openBox<HiveMovieModel>(_movieBoxName);
  }

  Box<HiveMovieModel> get _box {
    if (_movieBox == null || !_movieBox!.isOpen) {
      throw Exception('Hive box is not initialized. Call init() first.');
    }
    return _movieBox!;
  }

  Future<void> saveFavoriteMovie({
    required int id,
    required String title,
    String? posterPath,
    required double voteAverage,
    String? releaseDate,
  }) async {
    final movie = HiveMovieModel(
      id: id,
      title: title,
      posterPath: posterPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      savedAt: DateTime.now(),
    );
    await _box.put(id, movie);
  }

  Future<void> removeFavoriteMovie(int id) async {
    await _box.delete(id);
  }

  bool isFavorite(int id) {
    return _box.containsKey(id);
  }

  List<HiveMovieModel> getAllFavorites() {
    return _box.values.toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  HiveMovieModel? getFavorite(int id) {
    return _box.get(id);
  }

  int get favoritesCount => _box.length;

  Future<void> clearAllFavorites() async {
    await _box.clear();
  }
}
