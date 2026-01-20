import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../pages/movie_detail_page.dart';
import 'movie_list_item.dart';

/// Widget reutilizable para mostrar una lista vertical de películas
///
/// Usa MovieListItem para renderizar cada película,
/// manteniendo la separación de responsabilidades.
class MovieVerticalList extends StatelessWidget {
  final List<MovieModel> movies;

  const MovieVerticalList({
    super.key,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: movies.map((movie) {
        return MovieListItem(
          movieId: movie.id,
          title: movie.title,
          posterUrl: movie.posterUrl,
          voteAverage: movie.voteAverage,
          genres: movie.genres,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPage(movieId: movie.id),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
