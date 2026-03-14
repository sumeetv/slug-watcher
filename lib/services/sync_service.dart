class SyncStatus {
  const SyncStatus({
    required this.label,
    required this.lastSyncedAt,
  });

  final String label;
  final DateTime? lastSyncedAt;
}

abstract class SyncService {
  Future<SyncStatus> loadStatus();
}

class StubDriveSyncService implements SyncService {
  @override
  Future<SyncStatus> loadStatus() async {
    return const SyncStatus(
      label: 'Google Drive appDataFolder backup pending setup',
      lastSyncedAt: null,
    );
  }
}
