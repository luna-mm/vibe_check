import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_check/entry.dart';
import 'package:word_cloud/word_cloud.dart';

// This file contains various "cards", widgets displayed on the Analysis page
// that display the user's statistics in varying ways.

/// Card that displays the user's current and longest streaks
class StreakCard extends StatelessWidget {
  final List<Entry> entries;

  const StreakCard({
    required this.entries,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text("Current Streak"),
            subtitle: Text("${getStreak(entries)} days"),
          )
        ],
      ),
    );
  }
}

/// Card that displays the user's emojis the past x (currently 5) days
class RecapCard extends StatelessWidget {
  final List<Entry> entries;

  const RecapCard({
    required this.entries,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Generate list for the last x days
    final int x = 5;
    final days = List.generate(x, (i) {
      final date = now.subtract(Duration(days: x-1 - i));
      final emojis = getDay(entries, date).map((entry) => entry.emoji).toList();
      return _RecapColumn(date: date, emojis: (emojis.isEmpty) ? ["🫥"] : emojis);
    });

    return Card(
      child: ListTile(
        title: Text("Recap - Last $x days"),
        subtitle: Row(
          spacing: 5,
          children: days.map((widget) => Expanded(child: widget)).toList()
        )
      )
    );
  }
}

class _RecapColumn extends StatelessWidget {
  final DateTime date;
  final List<String> emojis;

  const _RecapColumn({
    required this.date,
    required this.emojis,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      clipBehavior: Clip.antiAliasWithSaveLayer, 
      child: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Text(DateFormat('EEE').format(date))
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              style: Theme.of(context).textTheme.headlineLarge,
              emojis.join("\n"))
          ),
        ],
      ),
    );
  }
}

/// Card that displays a wordcloud of the user's entries the last 7 days
class WordCloudCard extends StatefulWidget {
  final List<Entry> entries;
  
  const WordCloudCard({
    required this.entries,
    super.key
  });

  @override
  State<WordCloudCard> createState() => _WordCloudCardState();
}

class _WordCloudCardState extends State<WordCloudCard> {
  WordCloudData? _data;
  bool isDataReady = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      _data = null;
    });
  }

  Future<void> makeWordcloud(List<Entry> entries) async {
    WordCloudData out = await getWordcloudWidget(entries);
    setState(() {
      _data = out;
      isDataReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.entries.isNotEmpty) {
      makeWordcloud(widget.entries);
    }

    return Card (
      child: Column (
        children: <Widget>[
          ListTile(
            title: Text("Wordcloud - Last 5 Days"),
            subtitle: (_data == null) 
              ? CircularProgressIndicator()
              : FittedBox(
                fit: BoxFit.fitWidth,
                child: WordCloudView(
                    data: _data!,
                    mapwidth: 200,
                    mapheight: 110,
                    mintextsize: 10,
                    maxtextsize: 16,
                    colorlist: [Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                                Theme.of(context).colorScheme.tertiary],
                ),
              )
          )
        ]
      )
    );
  }
}

// Helper functions below
List<Entry> getDay(List<Entry> entries, DateTime date) {
  List<Entry> out = [];
  
  Iterable<Entry> rev = entries.reversed;

  for (Entry entry in rev) {
    if (DateUtils.isSameDay(entry.id, date)) {
      out.add(entry);
    }
  }

  return out;
}

int getStreak(List<Entry> entries) {
  int streak = 0;
  DateTime now = DateTime.now();

  if (entries.isEmpty) {
    return 0;
  }

  DateTime lastEntryDate = entries.last.id;

  if (now.difference(lastEntryDate).inDays == 1) {
    streak++;
  }

  for (int i = 1; i < entries.length; i++) {
    if (entries[i].id.difference(entries[i - 1].id).inDays == 1) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

// Returns words and their frequencies in the last 5 days
Future<WordCloudData> getWordcloudWidget(List<Entry> entries) async {
  DateTime now = DateTime.now();
  List<String> sentences = getDay(entries, now).map((entry) => entry.sentence).toList() + 
                           getDay(entries, now.subtract(const Duration(days: 1))).map((entry) => entry.sentence).toList() + 
                           getDay(entries, now.subtract(const Duration(days: 2))).map((entry) => entry.sentence).toList() +
                           getDay(entries, now.subtract(const Duration(days: 3))).map((entry) => entry.sentence).toList() +
                           getDay(entries, now.subtract(const Duration(days: 4))).map((entry) => entry.sentence).toList();

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
    dataMap.add({'word': key, 'value' : value});
  });

  WordCloudData data = WordCloudData(data: dataMap);
  // Widget cloud = WordCloudView(
  //   data: data, 
  //   mapwidth: 2000, 
  //   mapheight: 1200,
  // );

  return data;
}

/// For development purposes only
/// Widget that displays all entries in the database
class AllEntriesWidget extends StatelessWidget {
  final List<Entry> entries;
  
  const AllEntriesWidget({
    required this.entries,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Entries"),
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Entry ${index + 1}'),
            subtitle: Text(entries[index].toString())
          );
        },
      )
    );
  }
}