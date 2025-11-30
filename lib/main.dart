import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: MaterialApp(
        title: 'Tagged Notes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const NoteListScreen(),
      ),
    );
  }
}

