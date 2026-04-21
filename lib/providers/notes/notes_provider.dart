import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:malist/data/models/notes/notes_model.dart';
import 'package:malist/data/repository/notes_repo.dart';
import 'package:malist/providers/notes/state/notes_state.dart';
import 'package:malist/service_locator.dart';

class NotesNotifier extends Notifier<NotesState> {
  final NotesRepo repository;

  NotesNotifier({required this.repository});

  @override
  NotesState build() {
    Future.microtask(() => getNotes());
    return const NotesState.initial();
  }

  Future<void> getNotes() async {
    state = const NotesState.loading();

    final result = await repository.getNotes();

    state = result.fold(
      (failure) => NotesState.error(message: failure.message),
      (notes) => NotesState.loaded(notes: notes),
    );
  }

  Future<void> addNote(NotesModel note) async {
    state = const NotesState.loading();
    final result = await repository.addNotes(notes: note);

    result.fold(
      (failure) => state = NotesState.error(message: failure.message),
      (_) => getNotes(),
    );
  }

  Future<void> updateNote(NotesModel note) async {
    state = const NotesState.loading();
    final result = await repository.updateNotes(notes: note);

    result.fold(
      (failure) => state = NotesState.error(message: failure.message),
      (_) => getNotes(),
    );
  }

  Future<void> deleteNote(String id) async {
    state = const NotesState.loading();
    final result = await repository.deleteNotes(id: id);

    result.fold(
      (failure) => state = NotesState.error(message: failure.message),
      (_) => getNotes(),
    );
  }
}

final notesNotifierProvider = NotifierProvider<NotesNotifier, NotesState>(
  () => sl<NotesNotifier>(),
);
