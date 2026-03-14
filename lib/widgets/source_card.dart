import 'package:flutter/material.dart';
import 'package:slug_watcher/models/tracked_source.dart';

enum SourceMenuAction {
  editProgress,
  editDate,
  editUrl,
  delete,
}

class SourceCard extends StatelessWidget {
  const SourceCard({
    super.key,
    required this.source,
    required this.onCopyUrl,
    required this.onMenuSelected,
  });

  final TrackedSource source;
  final VoidCallback onCopyUrl;
  final ValueChanged<SourceMenuAction> onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(source.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Chapter ${source.currentChapter}',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<SourceMenuAction>(
                  onSelected: onMenuSelected,
                  itemBuilder: (BuildContext context) =>
                      const <PopupMenuEntry<SourceMenuAction>>[
                        PopupMenuItem<SourceMenuAction>(
                          value: SourceMenuAction.editProgress,
                          child: Text('Edit chapter'),
                        ),
                        PopupMenuItem<SourceMenuAction>(
                          value: SourceMenuAction.editDate,
                          child: Text('Edit last read date'),
                        ),
                        PopupMenuItem<SourceMenuAction>(
                          value: SourceMenuAction.editUrl,
                          child: Text('Edit URL'),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem<SourceMenuAction>(
                          value: SourceMenuAction.delete,
                          child: Text('Delete'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: onCopyUrl,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.link, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        source.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy, size: 18),
                  ],
                ),
              ),
            ),
            const Divider(),
            Text(
              'Last read ${_formatDate(source.lastReadDate)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
