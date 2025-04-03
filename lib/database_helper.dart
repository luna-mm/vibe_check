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
        id INTEGER PRIMARY KEY,
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
    return await db.update('entries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id.millisecondsSinceEpoch]);
  }

  Future<int> deleteEntry(DateTime id) async {
    Database db = await instance.db;
    return await db.delete('entries', where: 'id = ?', whereArgs: [id.millisecondsSinceEpoch]);
  }

  /// For development purposes only
  /// This function initializes the database with some sample entries.
  Future<void> initializeSampleEntries() async {
    List<Entry> entriesToAdd = [
      Entry(id: DateTime.now().subtract(Duration(days: 1)), emoji: '😊', sentence: 'Finally got the database working!'),
      Entry(id: DateTime.now().subtract(Duration(days: 2)), emoji: '😔', sentence: 'The database isn\'t working! This sucks :('),
      Entry(id: DateTime.now().subtract(Duration(days: 3)), emoji: '🫠', sentence: 'Cafe Mac was so bad today.'),
      Entry(id: DateTime.now().subtract(Duration(days: 4)), emoji: '😒', sentence: 'smh'),
      Entry(id: DateTime.now().subtract(Duration(days: 5)), emoji: '😡', sentence: 'My computer decided to break down for no reason ugh'),
      Entry(id: DateTime.now().subtract(Duration(days: 6)), emoji: '🫢', sentence: 'Oops I think I totally got overheard lol'),
      Entry(id: DateTime.now().subtract(Duration(days: 7)), emoji: '😊', sentence: 'First entry wooh hooooo yayayayyy'),
    ];

    for (Entry entry in entriesToAdd) {
      await insertEntry(entry);
    }
  }
}
