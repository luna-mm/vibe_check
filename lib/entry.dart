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
