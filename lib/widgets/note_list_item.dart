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
    final createdAtText = _formatDate(note.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1行目：タイトル＋ピンアイコン
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    ),
                    onPressed: onTogglePin,
                  )
                ],
              ),

              const SizedBox(height: 4),

              // 2行目：タグChip＋作業日時
              Row(
                children: [
                  Chip(
                    label: Text(
                      note.tag,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    createdAtText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              //  3行目：本文の1行目だけ
              Text(
                note.body.isEmpty ? '' : note.body.split('\n').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[800]),
              ),

            ],
          ),
        ),
        // child: ListTile(
        //   title: Text(note.title),
        //   subtitle: Text(
        //     note.body.isEmpty ? '' : note.body.split('\n').first,
        //     maxLines: 1,
        //     overflow: TextOverflow.ellipsis,
        //   ),
        //   trailing: IconButton(
        //     icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
        //     onPressed: onTogglePin,
        //   ),
        //   onTap: onTap,
        //   // 長押しで削除
        //   onLongPress: onLongPress,
        // ),
      ),
    );
  }

}