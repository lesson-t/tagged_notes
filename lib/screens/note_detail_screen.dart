import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tagged_notes/presentation/note_notifier.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';

class NoteDetailScreen extends ConsumerWidget {
  final int noteId;

  const NoteDetailScreen({super.key, required this.noteId});

  String _formatDate(DateTime dateTime) {
    // 作成日時の表示フォーマット
    return DateFormat('yyyy/MM/dd HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final notesAsync = ref.watch(noteListProvider);

    return notesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('メモ詳細')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('メモ詳細')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('読み込みに失敗しました'),
                const SizedBox(height: 8),
                Text(e.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(noteListProvider.notifier).refresh();
                  },
                  child: const Text('再試行'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (notes) {
        final note = notes.where((n) => n.id == noteId).toList();
        if (note.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('メモ詳細')),
            body: const Center(child: Text('メモが見つかりませんでした。')),
          );
        }

        final n = note.first;
        final createdAtText = _formatDate(n.createdAt);

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
                    MaterialPageRoute(builder: (_) => NoteEditScreen(note: n)),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
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
                              n.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          Icon(
                            n.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            color: n.isPinned
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
                            label: Text(n.tag),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            createdAtText,
                            style: theme.textTheme.bodySmall?.copyWith(
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
                        n.body.isEmpty ? '（本文はありません）' : n.body,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
