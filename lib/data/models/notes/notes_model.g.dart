// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotesModel _$NotesModelFromJson(Map<String, dynamic> json) => _NotesModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  dateTime: DateTime.parse(json['dateTime'] as String),
);

Map<String, dynamic> _$NotesModelToJson(_NotesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'dateTime': instance.dateTime.toIso8601String(),
    };
