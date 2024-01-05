
// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cartelera/models/movie.dart';
import 'package:cartelera/services/api_config.dart';

class MovieService {
  static int _currentPage = 1;
  static bool _isLoading = false;

  static Future<List<Movie>> fetchMovies() async {
    if (_isLoading) {
      return []; // Si ya se está cargando, no hacer nada
    }

    try {
      _isLoading = true;
      final response = await http.get(Uri.parse(
        '${ApiConfig.baseUrl}/movie/popular?api_key=${ApiConfig.apiKey}&page=$_currentPage',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        _currentPage++;
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch movies');
      }
    } finally {
      _isLoading = false;
    }
  }
  
  
}


