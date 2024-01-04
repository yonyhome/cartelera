class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final String releaseDate; // Corregido: Cambiado de relaseDate a releaseDate
  final List<Genre> genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genres,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<Genre> genreList = [];

    if (json['genre_ids'] != null) {
      // Mapeo de los géneros utilizando un Map de IDs a nombres
      final genreMap = {
        28: 'Action',
        12: 'Adventure',
        16: 'Animation',
        35: 'Comedy',
        80: 'Crime',
        99: 'Documentary',
        18: 'Drama',
        10751: 'Family',
        14: 'Fantasy',
        36: 'History',
        27: 'Horror',
        10402: 'Music',
        9648: 'Mystery',
        10749: 'Romance',
        878: 'Science Fiction',
        10770: 'TV Movie',
        53: 'Thriller',
        10752: 'War',
        37: 'Western',
      };

      genreList = (json['genre_ids'] as List)
          .map((genreId) =>
              Genre(id: genreId, name: genreMap[genreId] ?? 'Unknown'))
          .toList();
    }

    return Movie(
      id: json["id"],
      title: json["title"],
      overview: json["overview"],
      posterPath: json["poster_path"],
      voteAverage: json["vote_average"].toDouble(),
      releaseDate: json["release_date"],
      genres: genreList,
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});
}
