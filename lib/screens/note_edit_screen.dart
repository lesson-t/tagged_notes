import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagged_notes/models/note.dart';
import 'package:tagged_notes/presentation/note_notifier.dart';

class NoteEditScreen extends ConsumerStatefulWidget {
  final Note? note; // あるときは編集、nullのときは新規
  const NoteEditScreen({super.key, this.note});

  @override
  ConsumerState<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends ConsumerState<NoteEditScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  // 初期タグ【仕事】
  String _selectedTag = '仕事';

  // 編集モードかどうか
  late final bool _isEditing;

  // ★追加：二重保存防止
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final note = widget.note;
    _isEditing = note != null; // noteがあれば編集モード

    if (note != null) {
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

  Future<void> _saveNote() async {
    if (_isSaving) return; // ★連打ガード（念のため）

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    final tag = _selectedTag;

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タイトルを入力してください')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(noteListProvider.notifier);

      if (_isEditing) {
        // 既存メモの更新
        await notifier.updateNote(
          id: widget.note!.id,
          title: title,
          body: body,
          tag: tag,
        );
      } else {
        // 新規メモの追加
        await notifier.addNote(title: title, body: body, tag: tag);
      }

      // 非同期中に画面が破棄されていたら何もしない
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
      setState(() => _isSaving = false);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'メモを編集' : '新規メモ'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveNote, // ★disable
            tooltip: '保存',
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSaving, // ★保存中は操作をまとめて無効化
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // タイトル
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // 本文
              Expanded(
                child: TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: '本文',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
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
                      DropdownMenuItem(value: '仕事', child: Text('仕事')),
                      DropdownMenuItem(value: 'プライベート', child: Text('プライベート')),
                      DropdownMenuItem(value: 'その他', child: Text('その他')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedTag = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
