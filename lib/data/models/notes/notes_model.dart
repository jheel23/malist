import 'package:freezed_annotation/freezed_annotation.dart';

part 'notes_model.freezed.dart';
part 'notes_model.g.dart';

@freezed
abstract class NotesModel with _$NotesModel {
  factory NotesModel({
    required String id,
    required String title,
    required String description,
    required DateTime dateTime,
  }) = _NotesModel;

  factory NotesModel.fromJson(Map<String, dynamic> json) =>
      _$NotesModelFromJson(json);
}
