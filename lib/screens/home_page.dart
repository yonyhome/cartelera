// ignore_for_file: depend_on_referenced_packages, use_build_context_synchronously
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cartelera/screens/saved_movies.dart';
import 'package:cartelera/services/api_config.dart';
import 'package:cartelera/widgets/movie_details.dart';
import 'package:flutter/material.dart';
import 'package:cartelera/services/movie_service.dart';
import 'package:cartelera/models/movie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MovieExplorerHomePage extends StatefulWidget {
  @override
  _MovieExplorerHomePageState createState() => _MovieExplorerHomePageState();
}

class _MovieExplorerHomePageState extends State<MovieExplorerHomePage> {
  List<Movie> movies = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _searchMovies(String query) async {
    if (query == null || query == "" || query.isEmpty || query == " ") {
      // No realizar búsqueda si la consulta es nula o vacía
      return;
    }

    try {
      final url = Uri.https('api.themoviedb.org', '/3/search/movie', {
        'api_key': ApiConfig.apiKey,
        'language': 'es-ES', // Puedes ajustar el idioma según tus necesidades
        'page': '1',
        'query': query,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('results') && data['results'] is List) {
          final List<dynamic> results = data['results'];
          final List<Movie> searchedMovies =
              results.map((json) => Movie.fromJson(json)).toList();

          setState(() {
            movies.clear(); // Limpiar la lista actual de películas
            movies
                .addAll(searchedMovies); // Agregar las películas de la búsqueda
          });
        } else {
          // El formato de respuesta no es el esperado
          print('Error: Formato de respuesta inesperado');
        }
      } else {
        // La solicitud no fue exitosa
        print('Error: ${response.statusCode}, ${response.reasonPhrase}');
      }
    } catch (e) {
      // Error general durante la búsqueda
      print('Error searching movies: $e');
      // También puedes mostrar un mensaje al usuario si lo deseas.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AppBar(
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
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: SearchBar(
                controller: _searchController,
                padding: const MaterialStatePropertyAll<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0)),
                onTap: () {
                  _searchMovies(_searchController.text);
                },
                onChanged: (_) {
                  _searchMovies(_searchController.text);
                },
                leading: const Icon(Icons.search),
              )),
          Expanded(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
        ],
      ),
    );
  }

  String _getGenresString(List<Genre> genres) {
    return genres.map((genre) => genre.name).join(", ");
  }
}
