import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:malist/data/models/notes/notes_model.dart';

part 'notes_state.freezed.dart';

@freezed
abstract class NotesState with _$NotesState {
  const factory NotesState.initial() = _Initial;
  const factory NotesState.loading() = _Loading;
  const factory NotesState.loaded({required List<NotesModel> notes}) = _Loaded;
  const factory NotesState.error({required String message}) = _Error;
}
