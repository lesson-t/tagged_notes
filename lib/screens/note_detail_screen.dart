import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

const NoteDetailScreen({
  super.key,
  required this.note,
});

String _formatDate(DateTime dateTime) {
  // 作成日時の表示フォーマット
  return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
}

@override
Widget build(BuildContext context) {
  final createdAtText = _formatDate(note.createdAt);

  return Scaffold(
    appBar: AppBar(
      title: const Text('メモ詳細'),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NoteEditScreen(note: note),
              ),
            );
          },
        )
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル　＋　ピン
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (note.isPinned)
                      const Icon(
                        Icons.push_pin,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // タグ　＋　作成日時
                Row(
                  children: [
                    Chip(
                      label: Text(note.tag)
                    ),
                    const SizedBox(width: 12),
                    Text(
                      createdAtText,
                      style:  Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Divider(),

                const SizedBox(height: 8),

                // 本文
                Text(
                  note.body.isEmpty ? '（本文はありません）' : note.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
  

}