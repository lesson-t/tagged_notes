import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/presentation/note_notifier.dart';
import 'package:tagged_notes/screens/note_detail_screen.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';
import 'package:tagged_notes/widgets/note_list_item.dart';
import 'package:tagged_notes/widgets/tag_filter_chips.dart';

class NoteListScreen extends ConsumerStatefulWidget {
  const NoteListScreen({super.key});

  @override
  ConsumerState<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends ConsumerState<NoteListScreen> {
  // タグフィルタ用の状態（初期値は すべて ）
  String _selectedTag = 'すべて';

  // 検索用キーワード　空文字なら検索なし
  String _searchQuery = '';

  // 表示するタグ一覧
  final List<String> _tags = ['すべて', '仕事', 'プライベート', 'その他'];

  Future<void> _openSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('検索キーワード'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'タイトルや本文を検索'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // キャンセル
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('検索'),
            ),
          ],
        );
      },
    );

    // result が null　ならキャンセル
    if (result == null) return;

    setState(() {
      _searchQuery = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(noteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tagged Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearchDialog,
          ),
        ],
      ),
      body: notesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
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
        data: (state) {
          final notes = state.notes;
          final isBusy = state.busy;

          final filteredNotes = _applyFilters(notes);

          return Column(
            children: [
              const SizedBox(height: 8),

              TagFilterChips(
                tags: _tags,
                selectedTag: _selectedTag,
                onTagSelected: (tag) {
                  setState(() {
                    _selectedTag = tag;
                  });
                },
              ),

              const Divider(height: 1),

              // フィルタ済みのリスト表示
              Expanded(
                child: filteredNotes.isEmpty
                    ? _buildEmptyState(notes)
                    : ListView.builder(
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];

                          return NoteListItem(
                            note: note,
                            onTap: isBusy
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            NoteDetailScreen(noteId: note.id),
                                      ),
                                    );
                                  },
                            onLongPress: isBusy
                                ? null
                                : () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('削除しますか？'),
                                        content: Text(note.title),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('キャンセル'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context); // 先に閉じる

                                              // ダイアログ閉じたあとに削除（context を使わない）
                                              await ref
                                                  .read(
                                                    noteListProvider.notifier,
                                                  )
                                                  .deleteNote(id: note.id);
                                            },
                                            child: const Text('削除'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            onTogglePin: isBusy
                                ? null
                                : () async {
                                    await ref
                                        .read(noteListProvider.notifier)
                                        .togglePin(id: note.id);
                                  },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: notesAsync.maybeWhen(
        data: (s) => FloatingActionButton(
          onPressed: s.busy
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NoteEditScreen()),
                  );
                },
          child: const Icon(Icons.add),
        ),
        orElse: () =>
            FloatingActionButton(onPressed: null, child: const Icon(Icons.add)),
      ),
    );
  }

  // タグに応じて絞り込んだリスト
  List<Note> _applyFilters(List<Note> notes) {
    final filteredByTag = _selectedTag == 'すべて'
        ? notes
        : notes.where((n) => n.tag == _selectedTag).toList();

    if (_searchQuery.isEmpty) return filteredByTag;

    // 検索キーワードでさらに絞り込む

    final q = _searchQuery.toLowerCase();
    return filteredByTag.where((note) {
      final title = note.title.toLowerCase();
      final body = note.body.toLowerCase();
      return title.contains(q) || body.contains(q);
    }).toList();
  }

  Widget _buildEmptyState(List<Note> allNotes) {
    // 1件もメモがない場合
    if (allNotes.isEmpty) {
      return const Center(child: Text('まだメモがありません。\n右下の「＋」から作成できます。'));
    }

    // メモはあるが、絞り込み条件で0件になっている場合
    return const Center(
      child: Text('条件に一致するメモがありません。', textAlign: TextAlign.center),
    );
  }
}
