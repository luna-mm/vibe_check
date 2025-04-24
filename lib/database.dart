import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:word_cloud/word_cloud_data.dart';
import 'entry.dart';

// This class is used by Widgets who display and access data in the database.
// This class is a ChangeNotifier, so any time there was a change to the dataset
// it will update any already built widgets to display the new data.
class Data extends ChangeNotifier {
  final _DatabaseHelper _dbHelper = _DatabaseHelper.instance;

  /// Variables holding the current states of the database,
  /// to prevent excessive read and writes to the SQL db.
  List<Entry> _entries = [];
  int streak = 0;
  WordCloudData? wcData;

  Data() {
    _initializeData();
  }

  // Asks the database helper for all data this class holds, and updates them.
  // This is meant to be run once.
  Future<void> _initializeData() async {
    final entryMap = await _DatabaseHelper.instance.queryAllEntries();
    _entries = entryMap.map((entryMap) => Entry.fromMap(entryMap)).toList();
    await _updateStreak();
    await _updateWcData();
    notifyListeners();
  }

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
      _entries.add(entry);
      await _updateAndNotify(); // If adding the entry to database fails, nothing is notified.
    }
    return result;
  }

  // Removes the specified entry from the database.
  Future<int> removeEntry(Entry entry) async {
    if (_entries.contains(entry)) return 0;

    int result = await _dbHelper.deleteEntry(entry.id); 
    if (result != 0) {
      _entries.remove(entry); // Local copy
      await _updateAndNotify(); // If adding the entry to database fails, nothing is notified.
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
      await _updateAndNotify(); // If adding the entry to database fails, nothing is notified.
    }
    return result;
  }

  /// Helper functions are below.

  // Updates variables for extras, and notifies listeners.
  Future<void> _updateAndNotify() async {
    streak = await _updateStreak();
    wcData = await _updateWcData();
    notifyListeners();
  }

  Future<int> _updateStreak() async {
    if (_entries.isEmpty) return 0;

    int streak = 1;
    DateTime now = DateTime.now();
    DateTime lastEntryDate = _entries.last.id;

    now = DateTime(now.year, now.month, now.day);
    lastEntryDate = DateTime(
      lastEntryDate.year,
      lastEntryDate.month,
      lastEntryDate.day,
    );

    int difference = now.difference(lastEntryDate).inDays;

    if (difference > 1) {
      return 0;
    }

    for (int i = _entries.length - 1; i > 0; i--) {
      DateTime current = DateTime(
        _entries[i].id.year,
        _entries[i].id.month,
        _entries[i].id.day,
      );
      DateTime previous = DateTime(
        _entries[i - 1].id.year,
        _entries[i - 1].id.month,
        _entries[i - 1].id.day,
      );

      if (current.difference(previous).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
  
  Future<WordCloudData?> _updateWcData() async {
      DateTime now = DateTime.now();
      if (_entries.isEmpty) return null;
      List<String> sentences =
        getEntries(day: now).map((entry) => entry.sentence).toList() +
        getEntries(
          day: now.subtract(const Duration(days: 1)),
        ).map((entry) => entry.sentence).toList() +
        getEntries(
          day: now.subtract(const Duration(days: 2)),
        ).map((entry) => entry.sentence).toList() +
        getEntries(
          day: now.subtract(const Duration(days: 3)),
        ).map((entry) => entry.sentence).toList() +
        getEntries(
          day: now.subtract(const Duration(days: 4)),
        ).map((entry) => entry.sentence).toList();

      List<String> words = [];
      for (String s in sentences) {
        final re = RegExp("(?!')[^a-zA-Z]+");
        words.addAll(s.toLowerCase().split(re).where((s) => s.isNotEmpty).toList());
      }

      Map<String, int> wordMap = {};
      for (var x in words) {
        wordMap[x] = !wordMap.containsKey(x) ? (1) : (wordMap[x]! + 1);
      }

      List<Map> dataMap = [];
      wordMap.forEach((key, value) {
        dataMap.add({'word': key, 'value': value});
      });

      WordCloudData data = WordCloudData(data: dataMap);
      // Widget cloud = WordCloudView(
      //   data: data,
      //   mapwidth: 2000,
      //   mapheight: 1200,
      // );

      return data;
  }

  // For development purposes only.
  // Adds 7 sample entries to the database.
  void addSampleEntries() {
    List<Entry> sampleEntries = [
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
    for (Entry e in sampleEntries) {
      addEntry(e);
    }
  }
}


// Helper class that interacts with the SQLite Database.
class _DatabaseHelper {
  static final _DatabaseHelper instance = _DatabaseHelper._instance();
  static Database? _database;

  _DatabaseHelper._instance();

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
}
