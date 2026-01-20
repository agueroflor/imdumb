import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/local/hive_service.dart';
import '../../data/repositories/movie_repository.dart';
import '../blocs/movie_detail_bloc.dart';
import '../widgets/actors_list.dart';
import '../widgets/error_view.dart';
import '../widgets/image_carousel.dart';
import '../widgets/movie_info_card.dart';
import '../widgets/recommend_dialog.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final _analyticsService = serviceLocator<AnalyticsService>();
  final _hiveService = serviceLocator<HiveService>();
  bool _hasTracked = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovieDetailBloc(
        repository: serviceLocator<MovieRepository>(),
      )..add(LoadMovieDetail(widget.movieId)),
      child: Scaffold(
        body: BlocConsumer<MovieDetailBloc, MovieDetailState>(
          listener: (context, state) {
            if (state is MovieDetailLoaded && !_hasTracked) {
              _hasTracked = true;
              _analyticsService.logEvent(
                name: 'movie_viewed',
                parameters: {
                  'movie_id': state.movie.id,
                  'movie_title': state.movie.title,
                },
              );
              _analyticsService.logScreenView(screenName: 'movie_detail');

              setState(() {
                _isFavorite = _hiveService.isFavorite(state.movie.id);
              });
            }
          },
          builder: (context, state) {
            if (state is MovieDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MovieDetailError) {
              return ErrorView(
                message: state.message,
                onRetry: () => Navigator.pop(context),
              );
            }

            if (state is MovieDetailLoaded) {
              final movie = state.movie;

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              children: [
                                ImageCarousel(images: movie.images),
                              ],
                            ),
                            Positioned(
                              top: 16,
                              left: 16,
                              child: SafeArea(
                                child: CircleAvatar(
                                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -60,
                              left: 0,
                              right: 0,
                              child: MovieInfoCard(
                                movie: movie,
                                isFavorite: _isFavorite,
                                onBookmark: () async {
                                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                                  setState(() {
                                    _isFavorite = !_isFavorite;
                                  });

                                  if (_isFavorite) {
                                    await _hiveService.saveFavoriteMovie(
                                      id: movie.id,
                                      title: movie.title,
                                      posterPath: movie.posterPath,
                                      voteAverage: movie.voteAverage,
                                      releaseDate: movie.releaseDate,
                                    );

                                    _analyticsService.logEvent(
                                      name: 'movie_added_to_favorites',
                                      parameters: {
                                        'movie_id': movie.id,
                                        'movie_title': movie.title,
                                      },
                                    );

                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Agregado a favoritos'),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    await _hiveService.removeFavoriteMovie(movie.id);

                                    _analyticsService.logEvent(
                                      name: 'movie_removed_from_favorites',
                                      parameters: {
                                        'movie_id': movie.id,
                                        'movie_title': movie.title,
                                      },
                                    );

                                    scaffoldMessenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Eliminado de favoritos'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Description',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: movie.overview.isNotEmpty
                              ? Html(
                                  data: movie.overview,
                                  style: {
                                    "body": Style(
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      fontSize: FontSize.medium,
                                      color: Colors.grey[700],
                                    ),
                                  },
                                )
                              : Text(
                                  'Sin descripción disponible',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        if (movie.cast.isNotEmpty) ActorsList(actors: movie.cast),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => RecommendDialog(
                                  movieId: movie.id,
                                  movieTitle: movie.title,
                                  movieOverview: movie.overview,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Recomendar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
