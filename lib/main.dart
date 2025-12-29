import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tagged_notes/providers/note_provider.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NoteRepository>(create: (_) => NoteRepository()),
        ChangeNotifierProxyProvider<NoteRepository, NoteProvider>(
          create: (context) => NoteProvider(context.read<NoteRepository>()),
          update: (context, repo, previous) => previous ?? NoteProvider(repo),
        ),
      ],

      child: MaterialApp(
        title: 'Tagged Notes',

        // ライトテーマ
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(centerTitle: false),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // ダークテーマ
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          appBarTheme: const AppBarTheme(centerTitle: false),
          cardTheme: CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // 端末の設定（ライト/ダーク）に追従
        themeMode: ThemeMode.system,

        home: const NoteListScreen(),
      ),
    );
  }
}
