import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'entry.dart';

// This class is used by Widgets who display and access data in the database.
// This class is a ChangeNotifier, so any time there was a change to the dataset
// it will update any already built widgets to display the new data.
class Data extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Variables holding the current states of the database,
  /// to prevent excessive read and writes.
  final List<Entry> _entries = [];

  /// The following commands do not change anything in the database,
  /// so no widgets will be notified.

  // Returns an immutable, iterable copy of the current entries in the database.
  // If a DateTime is specified, it will return all entries for the given day.
  Iterable<Entry> getEntries({DateTime? day}) {
    if (day != null) {
      return List.unmodifiable(_entries.where((entry) => DateUtils.isSameDay(day, entry.id)).toList());
    }
    
    return List.unmodifiable(_entries);
  }

  /// The following commands results in a change being called.
  /// Use responsibly ^_^

  // Adds the specified entry to the database.
  Future<int> addEntry(Entry entry) async {
    int result = await _dbHelper.insertEntry(entry); 
    if (result != 0) {
      _entries.add(entry); // Local copy
      notifyListeners(); // If adding the entry to database fails, nothing is notified.
    }
    return result;
  }

  // Removes the specified entry from the database.
  Future<int> removeEntry(Entry entry) async {
    if (_entries.contains(entry)) return 0;

    int result = await _dbHelper.deleteEntry(entry.id); 
    if (result != 0) {
      _entries.remove(entry); // Local copy
      notifyListeners(); // If adding the entry to database fails, nothing is notified.
    }
    return result;
  }
  
  // Replaces the entry in the database with the same id (DateTime) as the given entry.
  Future<int> modifyEntry(Entry entry) async {
    int toModify = _entries.indexWhere((e) => e.id.isAtSameMomentAs(entry.id));
    if (toModify == -1) return 0;

    int result = await _dbHelper.updateEntry(entry); 
    if (result != 0) {
      _entries[toModify] = entry;
      notifyListeners(); // If adding the entry to database fails, nothing is notified.
    }
    return result;
  }
}

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
    return await db.update(
      'entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id.millisecondsSinceEpoch],
    );
  }

  Future<int> deleteEntry(DateTime id) async {
    Database db = await instance.db;
    return await db.delete(
      'entries',
      where: 'id = ?',
      whereArgs: [id.millisecondsSinceEpoch],
    );
  }

  /// For development purposes only
  /// This function initializes the database with some sample entries.
  Future<void> initializeSampleEntries() async {
    List<Entry> entriesToAdd = [
      Entry(
        id: DateTime.now().subtract(Duration(days: 1)),
        emoji: '😊',
        sentence: 'Finally got the database working!',
      ),
      Entry(
        id: DateTime.now().subtract(Duration(days: 2)),
        emoji: '😔',
        sentence: 'The database isn\'t working! This sucks :(',
      ),
      Entry(
        id: DateTime.now().subtract(Duration(days: 3)),
        emoji: '🫠',
        sentence: 'Cafe Mac was so bad today.',
      ),
      Entry(
        id: DateTime.now().subtract(Duration(days: 4)),
        emoji: '😒',
        sentence: 'smh',
      ),
      Entry(
        id: DateTime.now().subtract(Duration(days: 5)),
        emoji: '😡',
        sentence: 'My computer decided to break down for no reason ugh',
      ),
      Entry(
        id: DateTime.now().subtract(Duration(days: 6)),
        emoji: '🫢',
        sentence: 'Oops I think I totally got overheard lol',
      ),
      Entry(
        id: DateTime.now().subtract(Duration(days: 7)),
        emoji: '😊',
        sentence: 'First entry wooh hooooo yayayayyy',
      ),
    ];

    for (Entry entry in entriesToAdd) {
      await insertEntry(entry);
    }
  }

  Future<List<Entry>> retrieveAllEntriesForDay(DateTime givenId) async {
    List<Entry> entries = [];
    List<Entry> allDays = [];

    final entryMap = await DatabaseHelper.instance.queryAllEntries();
    entries = entryMap.map((entryMap) => Entry.fromMap(entryMap)).toList();

    for (var entry in entries) {
      if (DateUtils.isSameDay(entry.id, givenId)) {
        allDays.add(entry);
        print(entry);
      }
    }

    return allDays;
  }
}
