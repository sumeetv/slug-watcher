import 'package:flutter/material.dart';
import 'package:slug_watcher/services/auth_service.dart';
import 'package:slug_watcher/services/sync_service.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.authState,
    required this.syncStatus,
    required this.isAuthBusy,
    this.onAuthAction,
  });

  final AuthState? authState;
  final SyncStatus? syncStatus;
  final bool isAuthBusy;
  final VoidCallback? onAuthAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isSignedIn = authState?.isSignedIn == true;
    final String authButtonLabel = isSignedIn ? 'Sign out' : 'Sign in';
    final IconData authButtonIcon =
        isSignedIn ? Icons.logout_rounded : Icons.login_rounded;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Status', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatusRow(
              icon: isSignedIn ? Icons.verified_user : Icons.lock_outline,
              label: 'Account',
              value: authState?.label ?? 'Loading account status...',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed:
                    authState == null || isAuthBusy ? null : onAuthAction,
                icon: isAuthBusy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Icon(authButtonIcon),
                label: Text(authButtonLabel),
              ),
            ),
            const SizedBox(height: 12),
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
