import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/remote_config/firebase_remote_config_service.dart';
import '../../data/repositories/movie_repository.dart';
import '../blocs/search_bloc.dart';
import '../widgets/movie_vertical_list.dart';
import '../widgets/section_title.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final remoteConfig = serviceLocator<FirebaseRemoteConfigService>();
    final appConfig = remoteConfig.snapshot.appConfig;
    final minCharacters = appConfig.searchMinCharacters;
    final debounce = appConfig.searchDebounceMs;
    final placeholder = appConfig.searchPlaceholder;

    return BlocProvider(
      create: (context) => SearchBloc(
        repository: serviceLocator<MovieRepository>(),
        debounceMilliseconds: debounce,
      ),
      child: _SearchPageContent(
        minCharacters: minCharacters,
        placeholder: placeholder,
      ),
    );
  }
}

class _SearchPageContent extends StatefulWidget {
  final int minCharacters;
  final String placeholder;

  const _SearchPageContent({
    required this.minCharacters,
    required this.placeholder,
  });

  @override
  State<_SearchPageContent> createState() => _SearchPageContentState();
}

class _SearchPageContentState extends State<_SearchPageContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.grey[400],
            ),
          ),
          style: Theme.of(context).textTheme.titleMedium,
          onChanged: (query) {
            if (query.length >= widget.minCharacters) {
              context.read<SearchBloc>().add(SearchQueryChanged(query));
            } else if (query.isEmpty) {
              context.read<SearchBloc>().add(SearchCleared());
            }
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<SearchBloc>().add(SearchCleared());
              },
            ),
        ],
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Busca tus películas favoritas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ingresa al menos ${widget.minCharacters} caracteres',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SearchError) {
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
                    'Error al buscar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is SearchEmpty) {
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
                    'No se encontraron resultados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Intenta con otro término de búsqueda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            );
          }

          if (state is SearchLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  SectionTitle(
                    title: 'Resultados (${state.movies.length})',
                  ),
                  const SizedBox(height: 12),
                  MovieVerticalList(movies: state.movies),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
