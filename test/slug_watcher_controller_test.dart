import 'package:flutter_test/flutter_test.dart';
import 'package:slug_watcher/controllers/slug_watcher_controller.dart';
import 'package:slug_watcher/models/tracked_source.dart';
import 'package:slug_watcher/services/auth_service.dart';
import 'package:slug_watcher/services/in_memory_source_repository.dart';
import 'package:slug_watcher/services/sync_service.dart';

void main() {
  group('SlugWatcherController', () {
    test('loads sources sorted by last read date', () async {
      final SlugWatcherController controller = SlugWatcherController(
        repository: InMemorySourceRepository(
          initialSources: <TrackedSource>[
            TrackedSource(
              id: 'older',
              name: 'Older',
              url: 'https://example.com/older',
              currentChapter: '1',
              lastReadDate: DateTime(2026, 3, 1),
            ),
            TrackedSource(
              id: 'newer',
              name: 'Newer',
              url: 'https://example.com/newer',
              currentChapter: '5',
              lastReadDate: DateTime(2026, 3, 5),
            ),
          ],
        ),
        authService: StubGoogleAuthService(),
        syncService: StubDriveSyncService(),
      );

      await controller.initialize();

      expect(
          controller.sources.map((TrackedSource source) => source.id), <String>[
        'newer',
        'older',
      ]);
    });

    test('updating chapter refreshes the last read date', () async {
      final SlugWatcherController controller = SlugWatcherController(
        repository: InMemorySourceRepository(
          initialSources: <TrackedSource>[
            TrackedSource(
              id: 'source-1',
              name: 'Story',
              url: 'https://example.com/story',
              currentChapter: '5',
              lastReadDate: DateTime(2026, 3, 1),
            ),
          ],
        ),
        authService: StubGoogleAuthService(),
        syncService: StubDriveSyncService(),
      );

      await controller.initialize();
      await controller.updateChapter('source-1', '6');

      expect(controller.sources.single.currentChapter, '6');
      expect(
        controller.sources.single.lastReadDate,
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
      );
    });

    test('deletes sources', () async {
      final SlugWatcherController controller = SlugWatcherController(
        repository: InMemorySourceRepository(
          initialSources: <TrackedSource>[
            TrackedSource(
              id: 'source-1',
              name: 'Story',
              url: 'https://example.com/story',
              currentChapter: '5',
              lastReadDate: DateTime(2026, 3, 1),
            ),
          ],
        ),
        authService: StubGoogleAuthService(),
        syncService: StubDriveSyncService(),
      );

      await controller.initialize();
      await controller.deleteSource('source-1');

      expect(controller.sources, isEmpty);
    });
  });
}
