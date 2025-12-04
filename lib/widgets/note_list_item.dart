import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        note.body.isEmpty ? '' : note.body.split('\n').first,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
        onPressed: onTogglePin,
      ),
      onTap: onTap,
      // 長押しで削除
      onLongPress: onLongPress,
    );
  }

}