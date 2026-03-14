import 'package:flutter/foundation.dart';
import 'package:slug_watcher/models/tracked_source.dart';
import 'package:slug_watcher/services/auth_service.dart';
import 'package:slug_watcher/services/source_repository.dart';
import 'package:slug_watcher/services/sync_service.dart';

class SlugWatcherController extends ChangeNotifier {
  SlugWatcherController({
    required SourceRepository repository,
    required AuthService authService,
    required SyncService syncService,
  }) : _repository = repository,
       _authService = authService,
       _syncService = syncService;

  final SourceRepository _repository;
  final AuthService _authService;
  final SyncService _syncService;

  final List<TrackedSource> _sources = <TrackedSource>[];
  bool _isLoading = true;
  AuthState? _authState;
  SyncStatus? _syncStatus;

  bool get isLoading => _isLoading;
  List<TrackedSource> get sources => List<TrackedSource>.unmodifiable(_sources);
  AuthState? get authState => _authState;
  SyncStatus? get syncStatus => _syncStatus;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      _repository.loadSources(),
      _authService.loadState(),
      _syncService.loadStatus(),
    ]);

    _sources
      ..clear()
      ..addAll(_sortSources(results[0] as List<TrackedSource>));
    _authState = results[1] as AuthState;
    _syncStatus = results[2] as SyncStatus;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSource({
    required String name,
    required String url,
    required String currentChapter,
    DateTime? lastReadDate,
  }) async {
    _sources.add(
      TrackedSource(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        url: url.trim(),
        currentChapter: currentChapter.trim(),
        lastReadDate: _normalizeDate(lastReadDate ?? DateTime.now()),
      ),
    );
    await _persistSources();
  }

  Future<void> updateChapter(String id, String currentChapter) async {
    await _replaceSource(
      id,
      (TrackedSource source) => source.copyWith(
        currentChapter: currentChapter.trim(),
        lastReadDate: _normalizeDate(DateTime.now()),
      ),
    );
  }

  Future<void> updateUrl(String id, String url) async {
    await _replaceSource(
      id,
      (TrackedSource source) => source.copyWith(url: url.trim()),
    );
  }

  Future<void> updateLastReadDate(String id, DateTime date) async {
    await _replaceSource(
      id,
      (TrackedSource source) => source.copyWith(lastReadDate: _normalizeDate(date)),
    );
  }

  Future<void> deleteSource(String id) async {
    _sources.removeWhere((TrackedSource source) => source.id == id);
    await _persistSources();
  }

  Future<void> _replaceSource(
    String id,
    TrackedSource Function(TrackedSource source) transform,
  ) async {
    final int index = _sources.indexWhere((TrackedSource source) => source.id == id);
    if (index == -1) {
      return;
    }

    _sources[index] = transform(_sources[index]);
    await _persistSources();
  }

  Future<void> _persistSources() async {
    final List<TrackedSource> persisted = await _repository.saveSources(
      _sortSources(_sources),
    );
    _sources
      ..clear()
      ..addAll(persisted);
    notifyListeners();
  }

  List<TrackedSource> _sortSources(List<TrackedSource> sources) {
    final List<TrackedSource> sorted = List<TrackedSource>.from(sources);
    sorted.sort((TrackedSource a, TrackedSource b) {
      final int byDate = b.lastReadDate.compareTo(a.lastReadDate);
      if (byDate != 0) {
        return byDate;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
