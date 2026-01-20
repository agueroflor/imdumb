import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/repositories/movie_repository.dart';
import '../blocs/movies_by_category_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/movie_list_item.dart';
import 'movie_detail_page.dart';

class MoviesPage extends StatelessWidget {
  final String category;
  final String categoryName;

  const MoviesPage({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoviesByCategoryBloc(
        repository: serviceLocator<MovieRepository>(),
      )..add(LoadMoviesByCategory(category)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(categoryName),
        ),
        body: _MoviesListView(category: category),
      ),
    );
  }
}

class _MoviesListView extends StatefulWidget {
  final String category;

  const _MoviesListView({required this.category});

  @override
  State<_MoviesListView> createState() => _MoviesListViewState();
}

class _MoviesListViewState extends State<_MoviesListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_shouldLoadMore) {
      context.read<MoviesByCategoryBloc>().add(LoadMoreMovies());
    }
  }

  bool get _shouldLoadMore {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    const threshold = 200.0;
    return currentScroll >= (maxScroll - threshold);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoviesByCategoryBloc, MoviesByCategoryState>(
      builder: (context, state) {
        if (state is MoviesByCategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MoviesByCategoryError) {
          return ErrorView(
            message: state.message,
            onRetry: () {
              context.read<MoviesByCategoryBloc>().add(LoadMoviesByCategory(widget.category));
            },
          );
        }

        if (state is MoviesByCategoryLoaded) {
          if (state.movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No hay películas disponibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MoviesByCategoryBloc>().add(LoadMoviesByCategory(widget.category));
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
              if (index >= state.movies.length) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final movie = state.movies[index];
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
            },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
