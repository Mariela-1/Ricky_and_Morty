import 'package:ricky_and_morty/database/app_database.dart';
import 'package:ricky_and_morty/models/character.dart';
import 'package:sqflite/sqflite.dart';

class CharacterDao {
  insert(Character character) async {
    Database db = await AppDatabase.openDb();
    await db.insert(AppDatabase.tableName, character.toMap());
  }

  delete(Character character) async {
    Database db = await AppDatabase.openDb();
    await db.delete(
      AppDatabase.tableName,
      where: "id = ?",
      whereArgs: [character.id],
    );
  }

  isFavorite(Character character) async {
    Database db = await AppDatabase.openDb();
    final List<Map<String, dynamic>> maps = await db.query(
      AppDatabase.tableName,
      where: "id = ?",
      whereArgs: [character.id],
    );
    return maps.isNotEmpty;
  }

  Future<List<Character>> fetchFavorites() async {
    Database db = await AppDatabase.openDb();
    final List<Map<String, dynamic>> maps =
        await db.query(AppDatabase.tableName);
    return maps.map((map) => Character.fromMap(map)).toList();
  }
}
