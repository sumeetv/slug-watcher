import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slug_watcher/controllers/slug_watcher_controller.dart';
import 'package:slug_watcher/models/tracked_source.dart';
import 'package:slug_watcher/services/auth_service.dart';
import 'package:slug_watcher/services/local_source_repository.dart';
import 'package:slug_watcher/services/sync_service.dart';
import 'package:slug_watcher/widgets/source_card.dart';
import 'package:slug_watcher/widgets/source_editor_dialog.dart';
import 'package:slug_watcher/widgets/status_panel.dart';

const String _googleWebClientId =
    String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');
const String _googleServerClientId =
    String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SlugWatcherController controller = SlugWatcherController(
    repository: await LocalSourceRepository.create(),
    authService: GoogleAuthService(
      clientId: _googleWebClientId,
      serverClientId: _googleServerClientId,
    ),
    syncService: StubDriveSyncService(),
  );

  runApp(SlugWatcherApp(controller: controller));
}

enum AppThemeOption {
  system,
  light,
  dark,
}

class SlugWatcherApp extends StatefulWidget {
  const SlugWatcherApp({super.key, required this.controller});

  final SlugWatcherController controller;

  @override
  State<SlugWatcherApp> createState() => _SlugWatcherAppState();
}

class _SlugWatcherAppState extends State<SlugWatcherApp> {
  AppThemeOption _themeOption = AppThemeOption.system;

  @override
  void initState() {
    super.initState();
    widget.controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slug Watcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF345C49)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF345C49),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeOption.themeMode,
      home: SlugWatcherHome(
        controller: widget.controller,
        themeOption: _themeOption,
        onThemeSelected: (AppThemeOption option) {
          setState(() {
            _themeOption = option;
          });
        },
      ),
    );
  }
}

class SlugWatcherHome extends StatelessWidget {
  const SlugWatcherHome({
    super.key,
    required this.controller,
    required this.themeOption,
    required this.onThemeSelected,
  });

  final SlugWatcherController controller;
  final AppThemeOption themeOption;
  final ValueChanged<AppThemeOption> onThemeSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Slug Watcher'),
            actions: <Widget>[
              PopupMenuButton<AppThemeOption>(
                initialValue: themeOption,
                tooltip: 'Theme options',
                onSelected: onThemeSelected,
                itemBuilder: (BuildContext context) => AppThemeOption.values
                    .map(
                      (AppThemeOption option) =>
                          CheckedPopupMenuItem<AppThemeOption>(
                        value: option,
                        checked: option == themeOption,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                icon: const Icon(Icons.color_lens_outlined),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddSourceDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add source'),
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: controller.initialize,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      const _HeroPanel(),
                      const SizedBox(height: 16),
                      StatusPanel(
                        authState: controller.authState,
                        syncStatus: controller.syncStatus,
                        isAuthBusy: controller.isAuthBusy,
                        onAuthAction: () => _handleAuthAction(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tracked sources',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (controller.sources.isEmpty)
                        const _EmptyState()
                      else
                        ...controller.sources.map(
                          (TrackedSource source) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SourceCard(
                              source: source,
                              onCopyUrl: () => _copyUrl(context, source.url),
                              onMenuSelected: (SourceMenuAction action) =>
                                  _handleSourceAction(context, source, action),
                            ),
                          ),
                        ),
                      const SizedBox(height: 96),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Future<void> _handleAuthAction(BuildContext context) async {
    if (controller.authState?.isSignedIn == true) {
      await controller.signOutFromGoogle();
    } else {
      await controller.signInWithGoogle();
    }

    if (!context.mounted || controller.authState == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(controller.authState!.label)),
    );
  }

  Future<void> _showAddSourceDialog(BuildContext context) async {
    final SourceEditorResult? result = await showDialog<SourceEditorResult>(
      context: context,
      builder: (BuildContext context) => const SourceEditorDialog(
        title: 'Add source',
        confirmLabel: 'Save',
      ),
    );

    if (result == null) {
      return;
    }

    await controller.addSource(
      name: result.name,
      url: result.url,
      currentChapter: result.currentChapter,
    );
  }

  Future<void> _handleSourceAction(
    BuildContext context,
    TrackedSource source,
    SourceMenuAction action,
  ) async {
    switch (action) {
      case SourceMenuAction.editProgress:
        final SourceEditorResult? progressResult =
            await showDialog<SourceEditorResult>(
          context: context,
          builder: (BuildContext context) => SourceEditorDialog(
            title: 'Update progress',
            confirmLabel: 'Update',
            initialName: source.name,
            initialChapter: source.currentChapter,
            editName: false,
            editUrl: false,
          ),
        );
        if (progressResult != null) {
          await controller.updateChapter(
            source.id,
            progressResult.currentChapter,
          );
        }
        return;
      case SourceMenuAction.editDate:
        final DateTime now = DateTime.now();
        final DateTime? selected = await showDatePicker(
          context: context,
          initialDate: source.lastReadDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(now.year + 2),
        );
        if (selected != null) {
          await controller.updateLastReadDate(source.id, selected);
        }
        return;
      case SourceMenuAction.editUrl:
        final SourceEditorResult? urlResult =
            await showDialog<SourceEditorResult>(
          context: context,
          builder: (BuildContext context) => SourceEditorDialog(
            title: 'Update URL',
            confirmLabel: 'Update',
            initialName: source.name,
            initialUrl: source.url,
            editName: false,
            editChapter: false,
          ),
        );
        if (urlResult != null) {
          await controller.updateUrl(source.id, urlResult.url);
        }
        return;
      case SourceMenuAction.delete:
        final bool? confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Delete source?'),
            content: Text('Remove ${source.name} from your tracker.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await controller.deleteSource(source.id);
        }
        return;
    }
  }

  Future<void> _copyUrl(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL copied to clipboard')),
    );
  }
}

extension on AppThemeOption {
  String get label {
    switch (this) {
      case AppThemeOption.system:
        return 'System default';
      case AppThemeOption.light:
        return 'Light';
      case AppThemeOption.dark:
        return 'Dark';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeOption.system:
        return ThemeMode.system;
      case AppThemeOption.light:
        return ThemeMode.light;
      case AppThemeOption.dark:
        return ThemeMode.dark;
    }
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF345C49), Color(0xFF84A98C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Keep every serial in one place',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track the latest chapter, fix dates when needed, and copy a source URL in one tap.',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.menu_book_outlined,
            size: 36,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No sources yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a publication to start keeping your reading progress in syncable shape.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
