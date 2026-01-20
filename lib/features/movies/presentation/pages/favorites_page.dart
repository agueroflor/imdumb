import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/local/hive_service.dart';
import '../blocs/favorites_bloc.dart';
import '../widgets/movie_list_item.dart';
import '../widgets/section_title.dart';
import 'movie_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesBloc(
        hiveService: serviceLocator<HiveService>(),
      )..add(LoadFavorites()),
      child: const _FavoritesPageContent(),
    );
  }
}

class _FavoritesPageContent extends StatefulWidget {
  const _FavoritesPageContent();

  @override
  State<_FavoritesPageContent> createState() => _FavoritesPageContentState();
}

class _FavoritesPageContentState extends State<_FavoritesPageContent> {
  final _analyticsService = serviceLocator<AnalyticsService>();

  @override
  void initState() {
    super.initState();
    _analyticsService.logScreenView(screenName: 'favorites');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        centerTitle: true,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FavoritesBloc>().add(LoadFavorites());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is FavoritesEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No hay favoritos guardados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Agrega películas a favoritos desde\nla página de detalles',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          if (state is FavoritesLoaded) {
            final favorites = state.favorites;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<FavoritesBloc>().add(LoadFavorites());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const SizedBox(height: 16),
                  SectionTitle(
                    title: 'Películas Guardadas (${favorites.length})',
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: favorites.map((movie) {
                      return MovieListItem(
                        movieId: movie.id,
                        title: movie.title,
                        posterUrl: movie.posterPath,
                        voteAverage: movie.voteAverage,
                        onTap: () async {
                          final bloc = context.read<FavoritesBloc>();

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailPage(
                                movieId: movie.id,
                              ),
                            ),
                          );

                          // Reload favorites when returning
                          if (mounted) {
                            bloc.add(LoadFavorites());
                          }
                        },
                        subtitle: Text(
                          'Guardado: ${_formatDate(movie.savedAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          onPressed: () {
                            _showDeleteConfirmation(context, movie.id, movie.title);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteConfirmation(BuildContext context, int movieId, String movieTitle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar favorito'),
        content: Text('¿Deseas eliminar "$movieTitle" de tus favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<FavoritesBloc>().add(RemoveFavorite(movieId));
              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Eliminado de favoritos'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
