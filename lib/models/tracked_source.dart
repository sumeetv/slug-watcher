class TrackedSource {
  const TrackedSource({
    required this.id,
    required this.name,
    required this.url,
    required this.currentChapter,
    required this.lastReadDate,
  });

  final String id;
  final String name;
  final String url;
  final String currentChapter;
  final DateTime lastReadDate;

  TrackedSource copyWith({
    String? id,
    String? name,
    String? url,
    String? currentChapter,
    DateTime? lastReadDate,
  }) {
    return TrackedSource(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      currentChapter: currentChapter ?? this.currentChapter,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'currentChapter': currentChapter,
      'lastReadDate': lastReadDate.toIso8601String(),
    };
  }

  factory TrackedSource.fromJson(Map<String, dynamic> json) {
    return TrackedSource(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      currentChapter: json['currentChapter'] as String,
      lastReadDate: DateTime.parse(json['lastReadDate'] as String),
    );
  }
}
