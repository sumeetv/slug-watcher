import 'package:flutter/material.dart';
import 'package:slug_watcher/services/auth_service.dart';
import 'package:slug_watcher/services/sync_service.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.authState,
    required this.syncStatus,
  });

  final AuthState? authState;
  final SyncStatus? syncStatus;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Status', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatusRow(
              icon: authState?.isSignedIn == true
                  ? Icons.verified_user
                  : Icons.lock_outline,
              label: 'Account',
              value: authState?.label ?? 'Loading account status...',
            ),
            const SizedBox(height: 8),
            _StatusRow(
              icon: Icons.cloud_outlined,
              label: 'Backup',
              value: syncStatus?.label ?? 'Loading sync status...',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: theme.textTheme.labelLarge),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
