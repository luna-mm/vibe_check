/// This data type holds an ID, in the form of a DateTime, an emoji, and a sentence.
/// When a user "checks in", they create an Entry. The database stores all of the user's
/// Entries, which widgets can interact with by subscribing to Data().
library;

class Entry {
  final DateTime id; // This is the timestamp of the entry
  final String emoji;
  final String sentence;

  Entry({
    required this.id,
    required this.emoji,
    required this.sentence,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.millisecondsSinceEpoch,
      'emoji': emoji,
      'sentence': sentence,
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: DateTime.fromMillisecondsSinceEpoch(map['id']),
      emoji: map['emoji'],
      sentence: map['sentence'],
    );
  }

  @override
  String toString() {
    return 'Check in Time (id): $id \nemoji: $emoji \nsentence: $sentence';
  }
}
