
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';

class NoteListScreen extends StatefulWidget {
  const NoteListScreen({super.key});

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  // タグフィルタ用の状態（初期値は すべて ）
  String _selectedTag = 'すべて';

  // 表示するタグ一覧
  final List<String> _tags = ['すべて', '仕事', 'プライベート', 'その他'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;

    // タグに応じて絞り込んだリスト
    final filteredNotes = _selectedTag == 'すべて' 
      ? notes 
      : notes.where((n) => n.tag == _selectedTag).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tagged Notes")
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // タグフィルタのチップ行
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(tag), 
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedTag = tag;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // フィルタ済みのリスト表示
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];

                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.body.isEmpty ? '' : note.body.split('\n').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                    onPressed: () {
                      provider.togglePin(note.id);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: (_) => NoteEditScreen(note: note),
                      )
                    );
                  },
                  // 長押しで削除
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
}