
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_edit_screen.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteProvider>();
    final notes = provider.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tagged Notes")
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];

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