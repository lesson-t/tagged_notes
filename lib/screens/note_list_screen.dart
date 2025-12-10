import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_detail_screen.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';
import 'package:tagged_notes/widgets/note_list_item.dart';
import 'package:tagged_notes/widgets/tag_filter_chips.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  // タグフィルタ用の状態（初期値は すべて ）
  String _selectedTag = 'すべて';

  // 検索用キーワード　空文字なら検索なし
  String _searchQuery = '';

  // 表示するタグ一覧
  final List<String> _tags = ['すべて', '仕事', 'プライベート', 'その他'];

  @override
  void initState() {
    super.initState();
    // 
    Future.microtask(() {
      context.read<NoteProvider>().init();
    });
  }

  // 
  Future<void> _openSearchDialog() async {
    final controller = TextEditingController(text: _searchQuery);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('検索キーワード'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'タイトルや本文を検索',
            ),
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
              child: const Text('検索')
            ),
          ],
        );
      }
    );

    // result が null　ならキャンセル
    if (result == null) return;

    setState(() {
      _searchQuery = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;

    // タグに応じて絞り込んだリスト
    final filteredByTag = _selectedTag == 'すべて' 
      ? notes 
      : notes.where((n) => n.tag == _selectedTag).toList();

    // 検索キーワードでさらに絞り込む
    final filteredNotes = _searchQuery.isEmpty
      ? filteredByTag
      : filteredByTag.where((note) {
        final q = _searchQuery.toLowerCase();
        final title = note.title.toLowerCase();
        final body = note.body.toLowerCase();
        return title.contains(q) || body.contains(q);
      }).toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text("Tagged Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openSearchDialog, 
          )
        ],
      ),
      body: Column(
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
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => NoteDetailScreen(noteId: note.id),
                      ),
                    );
                  }, 
                  onLongPress: () {
                    showDialog(
                      context: context, 
                      builder: (_) => AlertDialog(
                        title: const Text('削除しますか？'),
                        content: Text(note.title),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context), 
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () {
                              provider.deleteNote(note.id);
                              Navigator.pop(context);
                            }, 
                            child: const Text('削除')
                          )
                        ],
                      )
                    );
                  },
                  onTogglePin: () {
                    provider.togglePin(note.id);
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => const NoteEditScreen(),
            )
          );
        } ,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(List<Note> allNotes) {
    // 1件もメモがない場合
    if (allNotes.isEmpty) {
      return const Center(
        child: Text(
          'まだメモがありません。\n右下の「＋」から作成できます。'
        )
      );
    }

    // メモはあるが、絞り込み条件で0件になっている場合
    return const Center(
      child: Text(
        '条件に一致するメモがありません。',
        textAlign: TextAlign.center,
      ),
    );
  }
}