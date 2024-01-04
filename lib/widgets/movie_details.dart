// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously, depend_on_referenced_packages

import 'package:cartelera/database/database_helper.dart';
import 'package:cartelera/services/api_config.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartelera/models/movie.dart';

class MovieDetailsWidget extends StatelessWidget {
  final Movie movie;

  const MovieDetailsWidget({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
        shadowColor: Colors.amber,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CachedNetworkImage(
              imageUrl: '${ApiConfig.imageBaseUrl}${movie.posterPath}',
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Release Date: ${movie.releaseDate}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Genres: ${_getGenresString(movie.genres)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Overview:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveMovieLocally(context, movie);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black, // Cambiar el color de fondo a negro
                    ),
                    child: const Text('Guardar Película'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGenresString(List<Genre> genres) {
    return genres.map((genre) => genre.name).join(', ');
  }

  Future<void> _saveMovieLocally(BuildContext context, Movie movie) async {
    final dbHelper = DatabaseHelper.instance;

    // Verificar si la película ya está guardada
    bool existingMovie = await dbHelper.getMovie(movie.title);

    if (existingMovie) {
      // La película ya está guardada
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta película ya está guardada'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // La película no está guardada, proceder a guardarla
      Map<String, dynamic> movieData = {
        'id': movie.id,
        'title': movie.title,
        'releaseDate': movie.releaseDate,
        'imageUrl': movie.posterPath,
        'genres': movie.genres.map((genre) => genre.name).join(', '),
        'overview': movie.overview,
        'vote': movie.voteAverage,
      };

      final id = await dbHelper.insert(movieData);
      if (id.isEven) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Película guardada localmente'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar la película'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
