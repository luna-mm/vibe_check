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

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'actualTime': actualTime.millisecondsSinceEpoch,
      'emoji': emoji,
      'sentence': sentence,
    };
  }

  factory Entry.fromMap(Map<String, Object?> map) {
    return Entry(
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    actualTime: DateTime.fromMillisecondsSinceEpoch(map['actualTime'] as int),
    emoji: map['emoji'] as String,
    sentence: map['sentence'] as String,
    );
  }

  @override
  String toString() {
    return 'Entry{timestamp: $timestamp, actualTime: $actualTime, emoji: $emoji, sentence: $sentence}';
  }
}