import 'package:flutter_test/flutter_test.dart';
import 'package:slug_watcher/models/tracked_source.dart';

void main() {
  test('TrackedSource serializes and deserializes', () {
    final TrackedSource source = TrackedSource(
      id: 'source-1',
      name: 'Example Story',
      url: 'https://example.com/story',
      currentChapter: '17',
      lastReadDate: DateTime(2026, 3, 13),
    );

    final Map<String, dynamic> json = source.toJson();
    final TrackedSource restored = TrackedSource.fromJson(json);

    expect(restored.id, source.id);
    expect(restored.name, source.name);
    expect(restored.url, source.url);
    expect(restored.currentChapter, source.currentChapter);
    expect(restored.lastReadDate, source.lastReadDate);
  });
}
