import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slug_watcher/controllers/slug_watcher_controller.dart';
import 'package:slug_watcher/main.dart';
import 'package:slug_watcher/services/auth_service.dart';
import 'package:slug_watcher/services/in_memory_source_repository.dart';
import 'package:slug_watcher/services/sync_service.dart';

void main() {
  testWidgets('renders app shell and add source action',
      (WidgetTester tester) async {
    final SlugWatcherController controller = SlugWatcherController(
      repository: InMemorySourceRepository(),
      authService: StubGoogleAuthService(),
      syncService: StubDriveSyncService(),
    );

    await tester.pumpWidget(SlugWatcherApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Slug Watcher'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Add source'), findsOneWidget);
    expect(find.text('Tracked sources'), findsOneWidget);
  });
}
