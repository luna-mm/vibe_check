import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibe_check/entry.dart';
import 'package:word_cloud/word_cloud.dart';

/// This file contains various "cards", widgets displayed on the Analysis page
/// that display the user's statistics in varying ways.

/// For development purposes only
/// Card that displays all entries in the database
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
            /// TODO: Add text formatting (from theme)
            title: Text("Current Streak"),
            subtitle: Text("${getStreak(entries)} days"),
          )
        ],
      ),
    );
  }
}

/// Card that displays the user's emojis in the last 7 days
class RecapCard extends StatelessWidget {
  final List<Entry> entries;

  const RecapCard({
    required this.entries,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    List<String> todayEmojis = getDay(entries, now).map((entry) => entry.emoji).toList();
    List<String> yesterdayEmojis = getDay(entries, now.subtract(const Duration(days: 1))).map((entry) => entry.emoji).toList();
    List<String> twoDaysAgoEmojis = getDay(entries, now.subtract(const Duration(days: 2))).map((entry) => entry.emoji).toList();
    List<String> threeDaysAgoEmojis = getDay(entries, now.subtract(const Duration(days: 3))).map((entry) => entry.emoji).toList();
    List<String> fourDaysAgoEmojis = getDay(entries, now.subtract(const Duration(days: 4))).map((entry) => entry.emoji).toList();

    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text("Last 5 Days"),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Column(
                    children: [
                      Text(DateFormat('EEE').format(now.subtract(const Duration(days: 4)))),
                      if (fourDaysAgoEmojis.isNotEmpty)
                        Text(fourDaysAgoEmojis.join("\n"))
                      else Text(" - "),
                    ]
                  )
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Column(
                    children: [
                      Text(DateFormat('EEE').format(now.subtract(const Duration(days: 3)))),
                      if (threeDaysAgoEmojis.isNotEmpty)
                        Text(threeDaysAgoEmojis.join("\n"))
                      else Text(" - "),
                    ]
                  )
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Column(
                    children: [
                      Text(DateFormat('EEE').format(now.subtract(const Duration(days: 2)))),
                      if (twoDaysAgoEmojis.isNotEmpty)
                        Text(twoDaysAgoEmojis.join("\n"))
                      else Text(" - "),
                    ]
                  )
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Column(
                    children: [
                      Text(DateFormat('EEE').format(now.subtract(const Duration(days: 1)))),
                      if (yesterdayEmojis.isNotEmpty)
                        Text(yesterdayEmojis.join("\n"))
                      else Text(" - "),
                    ]
                  )
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Column(
                    children: [
                      Text(DateFormat('EEE').format(now)),
                      if (todayEmojis.isNotEmpty)
                        Text(todayEmojis.join("\n"))
                      else Text(" - "),
                    ]
                  )
                ),
              ]
            )
          )
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
  Widget? _wordcloud;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      _wordcloud = null;
    });
  }

  Future<void> makeWordcloud(List<Entry> entries) async {
    Widget out = await getWordcloudWidget(entries);
    setState(() {
      _wordcloud = out;
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
            title: Text("Wordcloud"),
            subtitle: FittedBox(
              child: (_wordcloud == null) 
              ? CircularProgressIndicator()
              : _wordcloud
            )
          )
        ]
      )
    );
  }
}


class RecapWidget extends StatelessWidget {
  final List<Entry> entries;
  final List<int> indexes;

  const RecapWidget({
    super.key,
    required this.entries,
    required this.indexes
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
    child: Container(
      color: Theme.of(context).colorScheme.primary,

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
Future<Widget> getWordcloudWidget(List<Entry> entries) async {
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
  Widget cloud = WordCloudView(
    data: data, 
    mapwidth: 2000, 
    mapheight: 1200,
  );

  return cloud;
}