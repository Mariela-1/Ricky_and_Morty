import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static int version = 1;
  static String databaseName = "rickymorty.db";
  static String tableName = "characters";
  static Database? _db;

  static Future<Database> openDb() async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), databaseName),
      version: version,
      onCreate: (db, version) {
        String query = "create table $tableName (id integer primary key, name text, status text, gender text, image text, species text)";
        db.execute(query);
      },
    );
    return _db as Database;
  }

}