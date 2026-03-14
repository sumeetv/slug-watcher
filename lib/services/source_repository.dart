import 'package:slug_watcher/models/tracked_source.dart';

abstract class SourceRepository {
  Future<List<TrackedSource>> loadSources();

  Future<List<TrackedSource>> saveSources(List<TrackedSource> sources);
}
