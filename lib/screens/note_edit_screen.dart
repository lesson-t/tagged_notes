import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/providers/note_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;  // あるときは編集、nullのときは新規

  const NoteEditScreen({super.key, this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  // 初期タグ【仕事】
  String _selectedTag = '仕事';

  // 編集モードかどうか
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();

    final note = widget.note;
    _isEditing = note != null; // noteがあれば編集モード

    if (note != null) {
      // 
      _titleController.text = note.title;
      _bodyController.text = note.body;
      _selectedTag = note.tag;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final tag = _selectedTag;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルを入力ください'))
      );
      return;
    }

    // Provider から追加処理を呼ぶ
    final provider = context.read<NoteProvider>();

    if (_isEditing) {
      // 既存メモの更新
      provider.updateNote(widget.note!.id, title, body, tag);
    } else {
      // 新規メモの追加
      provider.addNote(title, body, tag);
    }

    // 一覧画面に戻る
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'メモを編集' : '新規メモ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote, 
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // タイトル
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル'
              ),
            ),
            const SizedBox(height: 12),
            // 本文
            Expanded(
              child: TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: '本文',
                  alignLabelWithHint: true
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 16),
            // タグ選択
            Row(
              children: [
                const Text('タグ'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedTag,
                  items: const [
                    DropdownMenuItem(
                      value: '仕事',
                      child: Text('仕事'),
                    ),
                    DropdownMenuItem(
                      value: 'プライベート',
                      child: Text('プライベート')
                    ),
                    DropdownMenuItem(
                      value: 'その他',
                      child: Text('その他')
                    ),
                  ], 
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedTag = value;
                    });
                  },
                ),
              ],
            )
          ]
        ),
      ),
    );
  }
}