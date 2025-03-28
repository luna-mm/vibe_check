import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'entry.dart';

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
    String path = join(databasesPath, 'vibe_check.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entries (
        timestamp INTEGER PRIMARY KEY,
        actualTime INTEGER,
        emoji TEXT,
        sentence TEXT
      )
    ''');
  }

  Future<int> insertEntry(Entry entry) async {
    Database db = await instance.db;
    return await db.insert('entries', entry.toMap());
  }

  Future<List<Map<String, dynamic>>> queryAllEntries() async {
    Database db = await instance.db;
    return await db.query('entries');
  }

  Future<int> updateEntry(Entry entry) async {
    Database db = await instance.db;
    return await db.update('entries', entry.toMap(), where: 'timestamp = ?', whereArgs: [entry.timestamp]);
  }

  Future<int> deleteEntry(DateTime timestamp) async {
    Database db = await instance.db;
    return await db.delete('entries', where: 'timestamp = ?', whereArgs: [timestamp]);
  }

  /// For development purposes only
  /// This function initializes the database with some sample entries.
  Future<void> initializeSampleEntries() async {
    List<Entry> entriesToAdd = [
      Entry(actualTime: DateTime.now(), timestamp: DateTime.now().subtract(Duration(days: 1)), emoji: '😊', sentence: 'Finally got the database working!'),
      Entry(actualTime: DateTime.now(), timestamp: DateTime.now().subtract(Duration(days: 2)), emoji: '😐', sentence: 'Just okay.'),
      Entry(actualTime: DateTime.now(), timestamp: DateTime.now().subtract(Duration(days: 3)), emoji: '😢', sentence: 'Feeling sad.'),
      Entry(actualTime: DateTime.now(), timestamp: DateTime.now().subtract(Duration(days: 4)), emoji: '😠', sentence: 'Feeling angry.'),
      Entry(actualTime: DateTime.now(), timestamp: DateTime.now().subtract(Duration(days: 5)), emoji: '😱', sentence: 'Feeling scared.'),
      Entry(actualTime: DateTime.now(), timestamp: DateTime.now().subtract(Duration(days: 6)), emoji: '😴', sentence: 'Feeling sleepy.'),
      Entry(actualTime: DateTime.now(), timestamp: DateTime.now().subtract(Duration(days: 7)), emoji: '😎', sentence: 'Feeling cool.'),
    ];

    for (Entry entry in entriesToAdd) {
      await insertEntry(entry);
    }
  }
}
