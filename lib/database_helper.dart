import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'vibecheck.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    // need entry for timestamp, input string (one sentence), emoticon
    await db.execute('''
      CREATE TABLE user_entries (
        actualCheckInTime DATETIME,
        timestamp DATETIME,
        inputSentence TEXT,
        inputEmoji TEXT
      )
    ''');
  }
}
