import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slug_watcher/models/tracked_source.dart';
import 'package:slug_watcher/services/local_source_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalSourceRepository', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('persists and restores tracked sources', () async {
      final LocalSourceRepository repository =
          await LocalSourceRepository.create();
      final List<TrackedSource> sources = <TrackedSource>[
        TrackedSource(
          id: 'source-1',
          name: 'Example Story',
          url: 'https://example.com/story',
          currentChapter: '17',
          lastReadDate: DateTime(2026, 3, 13),
        ),
      ];

      await repository.saveSources(sources);

      final List<TrackedSource> restored = await repository.loadSources();
      expect(restored.length, 1);
      expect(restored.single.name, 'Example Story');
      expect(restored.single.url, 'https://example.com/story');
      expect(restored.single.currentChapter, '17');
      expect(restored.single.lastReadDate, DateTime(2026, 3, 13));
    });

    test('clears invalid stored data and falls back to empty', () async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      await preferences.setString('tracked_sources', 'not-json');

      final LocalSourceRepository repository =
          await LocalSourceRepository.create();

      expect(await repository.loadSources(), isEmpty);
      expect(preferences.getString('tracked_sources'), isNull);
    });
  });
}
