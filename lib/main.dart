import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:provider/provider.dart';
// import 'package:tagged_notes/providers/note_provider.dart';
// import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/screens/note_list_screen.dart';
// import 'package:tagged_notes/storage/key_value_store.dart';
// import 'package:tagged_notes/storage/shared_preferences_store.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tagged Notes',
        
    // MultiProvider(
    //   providers: [
    //     Provider<KeyValueStore>(create: (_) => SharedPreferencesStore()),
    //     Provider<NoteRepository>(
    //       create: (context) => NoteRepository(context.read<KeyValueStore>()),
    //     ),
    //     ChangeNotifierProvider<NoteProvider>(
    //       create: (context) => NoteProvider(context.read<NoteRepository>()),
    //     ),
    //   ],

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
    );
  }
}
