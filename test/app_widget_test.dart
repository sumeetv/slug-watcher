import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slug_watcher/controllers/slug_watcher_controller.dart';
import 'package:slug_watcher/main.dart';
import 'package:slug_watcher/services/in_memory_source_repository.dart';
import 'package:slug_watcher/services/sync_service.dart';

import 'test_helpers/fake_auth_service.dart';

void main() {
  testWidgets('renders app shell, auth action, and theme menu',
      (WidgetTester tester) async {
    final FakeAuthService authService = FakeAuthService();
    final SlugWatcherController controller = SlugWatcherController(
      repository: InMemorySourceRepository(),
      authService: authService,
      syncService: StubDriveSyncService(),
    );

    await tester.pumpWidget(SlugWatcherApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Slug Watcher'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Add source'), findsOneWidget);
    expect(find.text('Tracked sources'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    MaterialApp app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);

    await tester.tap(find.byTooltip('Theme options'));
    await tester.pumpAndSettle();

    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);

    await tester.tap(find.byTooltip('Theme options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);

    await tester.tap(find.byTooltip('Theme options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System default'));
    await tester.pumpAndSettle();

    app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Signed in as Reader'), findsWidgets);
    expect(authService.signInCallCount, 1);
  });
}
