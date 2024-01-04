// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:cartelera/screens/saved_movies.dart';
import 'package:cartelera/services/api_config.dart';
import 'package:cartelera/widgets/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:cartelera/services/movie_service.dart';
import 'package:cartelera/models/movie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MovieExplorerHomePage extends StatefulWidget {
  const MovieExplorerHomePage({super.key});

  @override
  _MovieExplorerHomePageState createState() => _MovieExplorerHomePageState();
}

class _MovieExplorerHomePageState extends State<MovieExplorerHomePage> {
  List<Movie> movies = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    final isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('No hay conexión a internet'),
            content: const Text('Por favor, revisa tu conexión a internet.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      fetchMovies();
    }
  }

  Future<void> fetchMovies() async {
    try {
      final List<Movie> fetchedMovies = await MovieService.fetchMovies();
      setState(() {
        movies.addAll(fetchedMovies);
      });
    } catch (e) {
      print('Error fetching movies: $e');
      // Tratar el error aquí, puedes mostrar un mensaje al usuario si lo deseas.
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Llegaste al final, carga más películas
      fetchMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartelera'),
        shadowColor: Colors.amber,
        backgroundColor: Colors.black,
        actions: [
          // Usar un Row para colocar el icono y el texto lado a lado
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedMoviesView(),
                    ),
                  );
                },
              ),
              const Text('Mi Lista  '),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: movies.isEmpty
            ? const Center(
                child: Text('No se cargaron películas'),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailsWidget(movie: movie),
                        ),
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Póster de la película
                            CachedNetworkImage(
                              imageUrl:
                                  '${ApiConfig.imageBaseUrl}${movie.posterPath}',
                              width: 60,
                              height: 90,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            const SizedBox(width: 10),
                            // Información de la película
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nombre de la película
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // Género y fecha de lanzamiento
                                  Text(
                                    '${_getGenresString(movie.genres)} | ${movie.releaseDate}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _getGenresString(List<Genre> genres) {
    return genres.map((genre) => genre.name).join(", ");
  }
}
