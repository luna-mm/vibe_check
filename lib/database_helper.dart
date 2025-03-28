import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vibe_check/main.dart';

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
        timestamp DATETIME,
        actualTime DATETIME,
        inputSentence TEXT,
        inputEmoji TEXT
      )
    ''');
  }
}

Future<void> insertEntry(Entry entry) async {
  final db = await Db.get();

  await db.insert(
    'entries',
    entry.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

class Entry {
  final DateTime timestamp;
  final DateTime actualTime;
  final String emoji;
  final String sentence;

  Entry({
    required this.timestamp,
    required this.actualTime,
    required this.emoji,
    required this.sentence,
  });

  Map<String, Object?> toMap() {
    return {
      'timestamp': timestamp,
      'actualTime': actualTime,
      'emoji': emoji,
      'sentence': sentence,
    };
  }

  @override
  String toString() {
    return 'Entry{timestamp: $timestamp, actualTime: $actualTime, emoji: $emoji, sentence: $sentence}';
  }
}
