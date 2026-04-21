import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:malist/data/models/todo/todo_model.dart';

part 'todo_state.freezed.dart';

@freezed
abstract class TodoState with _$TodoState {
  const factory TodoState.initial() = _Initial;
  const factory TodoState.loading() = _Loading;
  const factory TodoState.loaded({required List<ToDoModel> todos}) = _Loaded;
  const factory TodoState.error({required String message}) = _Error;
}