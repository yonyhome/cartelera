// ignore_for_file: depend_on_referenced_packages

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHelper {
  static const _databaseName = 'movies_database.db';
  static const _databaseVersion = 1;

  static const tableMovies = 'movies';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnReleaseDate = 'releaseDate';
  static const columnImageUrl = 'imageUrl';
  static const columnGenres = 'genres';
  static const columnOverview = 'overview';
  static const columnVoteAverage = 'voteAverage';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    create table $tableMovies (
      $columnId integer primary key autoincrement,
      $columnTitle text not null,
      $columnReleaseDate text not null,
      $columnImageUrl text not null,
      $columnGenres text not null,
      $columnOverview text not null,
      $columnVoteAverage real not null
    )
  ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableMovies, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(tableMovies);
  }

  Future<void> deleteAll() async {
    Database db = await instance.database;
    await db.delete(tableMovies);
  }

  Future<void> delete(int movieId) async {
    Database db = await instance.database;
    await db.delete(
      tableMovies,
      where: '$columnId = ?',
      whereArgs: [movieId],
    );
  }

  Future<bool> getMovie(String title) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      tableMovies,
      where: '$columnTitle = ?',
      whereArgs: [title],
    );

    if (result.isNotEmpty) {
     
      return true;
    } else {
      return false;
    }
  }


}
