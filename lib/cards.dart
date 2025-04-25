import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:word_cloud/word_cloud.dart';
import 'database.dart';
import 'entry.dart';

/// This file contains various "cards", widgets displayed on the Analysis page
/// that display the user's statistics in varying ways.

/// Card that displays the user's current and longest streaks
class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    int streak = context.watch<Data>().streak;
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text("Current Streak"),
            subtitle: (streak == 1)
            ? Text("$streak day")
            : Text("$streak days")
          ),
        ],
      ),
    );
  }
}

/// Card that displays the user's emojis the past x (currently 5) days
class RecapCard extends StatelessWidget {
  const RecapCard({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Generate list for the last x days
    final int x = 5;
    final days = List.generate(x, (i) {
      final date = now.subtract(Duration(days: x - 1 - i));
      final emojis = context.watch<Data>().getEntries(day: date).map((entry) => entry.emoji).toList();
      return _RecapColumn(
        date: date,
        emojis: (emojis.isEmpty) ? ["🫥"] : emojis,
      );
    });

    return Card(
      child: ListTile(
        title: Text("Recap - Last $x days"),
        subtitle: Row(
          spacing: 5,
          children: days.map((widget) => Expanded(child: widget)).toList(),
        ),
      ),
    );
  }
}

// Helper widget for the Recap card.
class _RecapColumn extends StatelessWidget {
  final DateTime date;
  final List<String> emojis;

  const _RecapColumn({required this.date, required this.emojis});

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
            child: Text(DateFormat('EEE').format(date)),
          ),
          Container(
            padding: EdgeInsets.all(10),
            height: Theme.of(context).textTheme.headlineLarge!.fontSize! * 4 + 10,
            alignment: Alignment.topLeft,
            child: Text(
              emojis.join("\n"),
              style: Theme.of(context).textTheme.headlineLarge,
              maxLines: 3,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card that displays a wordcloud of the user's entries the last 7 days
class WordCloudCard extends StatelessWidget {
  const WordCloudCard({super.key});

  @override
  Widget build(BuildContext context) {
    WordCloudData? data = context.watch<Data>().wcData;
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text("Wordcloud - Last 5 Days"),
            subtitle: (data == null)
            ? CircularProgressIndicator()
            : FittedBox(
              fit: BoxFit.fitWidth,
              child: WordCloudView(
                data: data,
                mapwidth: 200,
                mapheight: 110,
                mintextsize: 10,
                maxtextsize: 16,
                colorlist: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// For development purposes only
// Widget that displays all entries in the database
class AllEntriesWidget extends StatelessWidget {
  const AllEntriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Iterable<Entry> entries = context.watch<Data>().getEntries();
    return Scaffold(
      appBar: AppBar(title: const Text("All Entries")),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Entry ${index + 1}'),
            subtitle: Text(entries.elementAt(index).toString()),
          );
        },
      ),
    );
  }
}