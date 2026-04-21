import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_model.freezed.dart';
part 'todo_model.g.dart';

@freezed
abstract class ToDoModel with _$ToDoModel {
  factory ToDoModel({
    required String id,
    required String description,
    required DateTime dateTime,
    bool? status,
  }) = _ToDoModel;

  factory ToDoModel.fromJson(Map<String, dynamic> json) =>
      _$ToDoModelFromJson(json);
}
