import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tagged_notes/repositories/note_repository.dart';
import 'package:tagged_notes/storage/key_value_store.dart';
import 'package:tagged_notes/storage/shared_preferences_store.dart';
import 'package:tagged_notes/usecase/add_note_usecase.dart';
import 'package:tagged_notes/usecase/delete_note_usecase.dart';
import 'package:tagged_notes/usecase/load_note_usecase.dart';
import 'package:tagged_notes/usecase/toggle_pin_usecase.dart';
import 'package:tagged_notes/usecase/update_note_usecase.dart';

/// Storage
final keyValueStoreProvider = Provider<KeyValueStore>((ref) {
  return SharedPreferencesStore();
});

/// Repository
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final store = ref.watch(keyValueStoreProvider);
  return NoteRepository(store);
});

/// UseCases
final loadNoteUsecaseProvider = Provider<LoadNoteUsecase>((ref) {
  return LoadNoteUsecase(ref.watch(noteRepositoryProvider));
});

final addNoteUsecaseProvider = Provider<AddNoteUsecase>((ref) {
  return AddNoteUsecase(ref.watch(noteRepositoryProvider));
});

final deleteNoteUsecaseProvider = Provider<DeleteNoteUsecase>((ref) {
  return DeleteNoteUsecase(ref.watch(noteRepositoryProvider));
});

final togglePinUsecaseProvider = Provider<TogglePinUsecase>((ref) {
  return TogglePinUsecase(ref.watch(noteRepositoryProvider));
});

final updateNoteUsecaseProvider = Provider<UpdateNoteUsecase>((ref) {
  return UpdateNoteUsecase(ref.watch(noteRepositoryProvider));
});
