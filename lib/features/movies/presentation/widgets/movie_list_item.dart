import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar un item de película en listas verticales
///
/// Componente desacoplado que muestra información de una película:
/// - Poster (con fallback)
/// - Título
/// - Géneros (chips opcionales)
/// - Rating
/// - Duración (opcional)
/// - Información adicional opcional
///
/// Sigue el principio de Composición sobre Herencia,
/// aceptando datos primitivos en lugar de modelos específicos.
class MovieListItem extends StatelessWidget {
  final int movieId;
  final String title;
  final String? posterUrl;
  final double voteAverage;
  final VoidCallback onTap;
  final Widget? trailing;
  final Widget? subtitle;
  final List<String>? genres;
  final String? duration;

  const MovieListItem({
    super.key,
    required this.movieId,
    required this.title,
    this.posterUrl,
    required this.voteAverage,
    required this.onTap,
    this.trailing,
    this.subtitle,
    this.genres,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 120,
                child: posterUrl != null && posterUrl!.isNotEmpty
                    ? Image.network(
                        posterUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPosterPlaceholder();
                        },
                      )
                    : _buildPosterPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${voteAverage.toStringAsFixed(1)}/10 IMDb',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (genres != null && genres!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: genres!.map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            genre.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (duration != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          duration!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ],
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    subtitle!,
                  ],
                ],
              ),
            ),

            // Trailing widget (opcional)
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildPosterPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(Icons.movie, size: 32),
    );
  }
}
