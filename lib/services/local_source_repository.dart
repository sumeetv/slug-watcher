import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:slug_watcher/models/tracked_source.dart';
import 'package:slug_watcher/services/source_repository.dart';

class LocalSourceRepository implements SourceRepository {
  LocalSourceRepository._(this._preferences);

  static const String _storageKey = 'tracked_sources';

  final SharedPreferences _preferences;

  static Future<LocalSourceRepository> create() async {
    return LocalSourceRepository._(await SharedPreferences.getInstance());
  }

  @override
  Future<List<TrackedSource>> loadSources() async {
    final String? rawSources = _preferences.getString(_storageKey);
    if (rawSources == null || rawSources.isEmpty) {
      return const <TrackedSource>[];
    }

    try {
      final List<dynamic> decoded = jsonDecode(rawSources) as List<dynamic>;
      return decoded
          .map(
            (dynamic source) =>
                TrackedSource.fromJson(source as Map<String, dynamic>),
          )
          .toList(growable: false);
    } on FormatException {
      await _preferences.remove(_storageKey);
      return const <TrackedSource>[];
    } on TypeError {
      await _preferences.remove(_storageKey);
      return const <TrackedSource>[];
    }
  }

  @override
  Future<List<TrackedSource>> saveSources(List<TrackedSource> sources) async {
    final String encoded = jsonEncode(
      sources
          .map((TrackedSource source) => source.toJson())
          .toList(growable: false),
    );
    await _preferences.setString(_storageKey, encoded);
    return List<TrackedSource>.unmodifiable(sources);
  }
}
