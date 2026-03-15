import 'package:flutter_test/flutter_test.dart';
import 'package:slug_watcher/controllers/slug_watcher_controller.dart';
import 'package:slug_watcher/models/tracked_source.dart';
import 'package:slug_watcher/services/in_memory_source_repository.dart';
import 'package:slug_watcher/services/sync_service.dart';

import 'test_helpers/fake_auth_service.dart';

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
        authService: FakeAuthService(),
        syncService: StubDriveSyncService(),
      );

      await controller.initialize();

      expect(
        controller.sources.map((TrackedSource source) => source.id),
        <String>['newer', 'older'],
      );
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
        authService: FakeAuthService(),
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
        authService: FakeAuthService(),
        syncService: StubDriveSyncService(),
      );

      await controller.initialize();
      await controller.deleteSource('source-1');

      expect(controller.sources, isEmpty);
    });

    test('updates auth state when signing in and out', () async {
      final FakeAuthService authService = FakeAuthService();
      final SlugWatcherController controller = SlugWatcherController(
        repository: InMemorySourceRepository(),
        authService: authService,
        syncService: StubDriveSyncService(),
      );

      await controller.initialize();
      await controller.signInWithGoogle();

      expect(controller.authState?.isSignedIn, isTrue);
      expect(controller.authState?.label, 'Signed in as Reader');
      expect(authService.signInCallCount, 1);
      expect(controller.isAuthBusy, isFalse);

      await controller.signOutFromGoogle();

      expect(controller.authState?.isSignedIn, isFalse);
      expect(authService.signOutCallCount, 1);
      expect(controller.isAuthBusy, isFalse);
    });
  });
}
