import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/local/hive_service.dart';
import '../../../../core/remote_config/firebase_remote_config_service.dart';
import '../../data/repositories/movie_repository.dart';
import '../blocs/home_bloc.dart';
import '../widgets/movie_horizontal_list.dart';
import '../widgets/movie_vertical_list.dart';
import '../widgets/section_title.dart';
import 'favorites_page.dart';
import 'movies_page.dart';
import 'search_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        repository: serviceLocator<MovieRepository>(),
      )..add(LoadHomeMovies()),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  final _remoteConfigService = serviceLocator<FirebaseRemoteConfigService>();
  final _analyticsService = serviceLocator<AnalyticsService>();
  final _hiveService = serviceLocator<HiveService>();
  int _favoritesCount = 0;

  @override
  void initState() {
    super.initState();
    _trackScreenView();
    _loadFavoritesCount();
  }

  void _loadFavoritesCount() {
    setState(() {
      _favoritesCount = _hiveService.favoritesCount;
    });
  }

  void _trackScreenView() {
    _analyticsService.logScreenView(screenName: 'home');
    _analyticsService.logEvent(name: 'app_opened');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMDUMB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final isSearchEnabled = _remoteConfigService.snapshot.appConfig.searchEnabled;

              if (isSearchEnabled) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Búsqueda no disponible'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.movie,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'IMDUMB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu biblioteca de películas',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Favoritos'),
              trailing: _favoritesCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_favoritesCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
                // Reload favorites count when returning
                _loadFavoritesCount();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(LoadHomeMovies());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                    title: 'Popular',
                    onActionPressed: () {
                      _analyticsService.logEvent(
                        name: 'category_viewed',
                        parameters: {
                          'category_id': 'popular',
                          'category_name': 'Popular',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoviesPage(
                            category: 'popular',
                            categoryName: 'Popular',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  MovieHorizontalList(movies: state.popularMovies),
                  const SizedBox(height: 24),
                  SectionTitle(
                    title: 'Top Rated',
                    onActionPressed: () {
                      _analyticsService.logEvent(
                        name: 'category_viewed',
                        parameters: {
                          'category_id': 'top_rated',
                          'category_name': 'Top Rated',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoviesPage(
                            category: 'top_rated',
                            categoryName: 'Top Rated',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  MovieVerticalList(movies: state.topRatedMovies),
                  const SizedBox(height: 24),
                  SectionTitle(
                    title: 'Upcoming',
                    onActionPressed: () {
                      _analyticsService.logEvent(
                        name: 'category_viewed',
                        parameters: {
                          'category_id': 'upcoming',
                          'category_name': 'Upcoming',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoviesPage(
                            category: 'upcoming',
                            categoryName: 'Upcoming',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  MovieVerticalList(movies: state.upcomingMovies),
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de IMDUMB'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IMDUMB - Tu biblioteca personal de películas',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Versión: 1.0.0'),
            const SizedBox(height: 8),
            Text(
              'Explora, guarda y gestiona tus películas favoritas.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            const Text('Powered by TMDB API'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
