import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartelera/services/api_config.dart';
import 'package:cartelera/database/database_helper.dart';

class SavedMoviesView extends StatefulWidget {
  @override
  _SavedMoviesViewState createState() => _SavedMoviesViewState();
}

class _SavedMoviesViewState extends State<SavedMoviesView> {
  late Future<List<Map<String, dynamic>>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = DatabaseHelper.instance.queryAll();
  }

  void _refreshMovies() {
    setState(() {
      _moviesFuture = DatabaseHelper.instance.queryAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Películas Guardadas'),
        shadowColor: Colors.amber,
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay películas guardadas en el Teléfono',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final savedMovie = snapshot.data![index];
                      return SavedMovieWidget(
                        savedMovie: savedMovie,
                        onMovieDeleted: _refreshMovies,
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _confirmDeleteAllMovies(context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black, // Cambiar el color de fondo a negro
                  ),
                  child: const Text(
                    'Borrar Todas',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteAllMovies(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text(
              '¿Estás seguro de que deseas borrar todas las películas?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar la eliminación
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllMovies(context); // Confirmar la eliminación
              },
              child: const Text('Borrar Todas'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllMovies(BuildContext context) {
    DatabaseHelper.instance.deleteAll();
    // Actualizar solo la lista
    _refreshMovies();
    Navigator.of(context).pop(); // Cerrar el diálogo de confirmación
  }
}

class SavedMovieWidget extends StatelessWidget {
  final Map<String, dynamic> savedMovie;
  final VoidCallback onMovieDeleted;

  const SavedMovieWidget({
    required this.savedMovie,
    required this.onMovieDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showMovieDetailsDialog(context);
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Póster de la película
              CachedNetworkImage(
                imageUrl: '${ApiConfig.imageBaseUrl}${savedMovie['imageUrl']}',
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(width: 10),
              // Información de la película
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de la película
                    Text(
                      savedMovie['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Género y fecha de lanzamiento
                    Text(
                      '${savedMovie['genres']} | ${savedMovie['releaseDate']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _confirmDeleteMovie(context, savedMovie['id']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteMovie(BuildContext context, int movieId) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content:
              const Text('¿Estás seguro de que deseas borrar esta película?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar la eliminación
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteMovie(context, movieId); // Confirmar la eliminación
              },
              child: const Text('Borrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMovieDetailsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(savedMovie['title']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar la imagen del póster
                Container(
                  width: double.infinity,
                  height: 200,
                  child: CachedNetworkImage(
                    imageUrl:
                        '${ApiConfig.imageBaseUrl}${savedMovie['imageUrl']}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 8),
                // Agrega más detalles según sea necesario
                Text('Géneros: ${savedMovie['genres']}'),
                Text('Fecha de lanzamiento: ${savedMovie['releaseDate']}'),
                Text('Descripción: ${savedMovie['overview']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMovie(BuildContext context, int movieId) {
    DatabaseHelper.instance.delete(movieId);
    // Actualizar solo la lista
    onMovieDeleted();
    Navigator.of(context).pop(); // Cerrar el diálogo de confirmación
  }
}
