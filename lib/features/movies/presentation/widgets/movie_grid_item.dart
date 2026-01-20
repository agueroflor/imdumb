import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';

class MovieGridItem extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback onTap;

  const MovieGridItem({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MoviePoster(posterUrl: movie.posterUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  _MovieRating(rating: movie.voteAverage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoviePoster extends StatelessWidget {
  final String posterUrl;

  const _MoviePoster({required this.posterUrl});

  @override
  Widget build(BuildContext context) {
    if (posterUrl.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.movie, size: 48),
      );
    }

    return Image.network(
      posterUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.movie, size: 48),
        );
      },
    );
  }
}

class _MovieRating extends StatelessWidget {
  final double rating;

  const _MovieRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
