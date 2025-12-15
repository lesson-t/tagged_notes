import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';

class NoteDetailScreen extends StatelessWidget {
   // final Note note;
   final int noteId;

const NoteDetailScreen({
  super.key,
  required this.noteId,
});

String _formatDate(DateTime dateTime) {
  // 作成日時の表示フォーマット
  return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
}

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  // Provider から 最新のNote を取得
  final provider = context.watch<NoteProvider>();
  final note = provider.findById(noteId);

  // 
  if (note == null) {
    return Scaffold(
      appBar: AppBar(title: const Text('メモ詳細')),
      body: const Center(
        child: Text('メモが見つかりませんでした。'),
      ),
    );
  }
     
  final createdAtText = _formatDate(note.createdAt);

  return Scaffold(
    appBar: AppBar(
      title: const Text('メモ詳細'),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: '編集',
          onPressed: () {
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
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // if (note.isPinned)
                    //   const Icon(
                    //     Icons.push_pin,
                    //     size: 20,
                    //   ),
            
                    Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: note.isPinned 
                          ? colorScheme.primary 
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                
                const SizedBox(width: 12),
              
                // タグ　＋　作成日時
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(note.tag),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(
                      createdAtText,
                      style:  theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            
                const SizedBox(height: 16),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 16),
              
                // 本文
                Text(
                  note.body.isEmpty ? '（本文はありません）' : note.body,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5
                  ),
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