import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagged_notes/models/note.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onTogglePin;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onTap,
    required this.onLongPress,
    required this.onTogglePin,
  });

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final preview = note.body.isEmpty ? '（本文なし）' :note.body.split('\n').first;
    final createdAtText = _formatDate(note.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      // elevation: 1,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左：情報ブロック
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1段目：タイトル（主）
                    Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 2段目：本文プレビュー（福）
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                
                    // 3段目：タグChip ＋ 日時（メタ）
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          label: Text(
                            note.tag,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          createdAtText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 右：ピン（アクション）
              IconButton(
                key: ValueKey('pin_button_${note.id}'),
                icon: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: note.isPinned ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                tooltip: note.isPinned ? 'ピン留め解除' : 'ピン留め',
                onPressed: onTogglePin,
              ),
            ],
          ),
        ),
      ),
    );
  }

}