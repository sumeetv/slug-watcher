import 'package:slug_watcher/models/tracked_source.dart';
import 'package:slug_watcher/services/source_repository.dart';

class InMemorySourceRepository implements SourceRepository {
  InMemorySourceRepository({List<TrackedSource>? initialSources})
    : _sources = List<TrackedSource>.from(initialSources ?? const <TrackedSource>[]);

  List<TrackedSource> _sources;

  @override
  Future<List<TrackedSource>> loadSources() async {
    return List<TrackedSource>.unmodifiable(_sources);
  }

  @override
  Future<List<TrackedSource>> saveSources(List<TrackedSource> sources) async {
    _sources = List<TrackedSource>.from(sources);
    return List<TrackedSource>.unmodifiable(_sources);
  }
}
