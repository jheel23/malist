// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ToDoModel _$ToDoModelFromJson(Map<String, dynamic> json) => _ToDoModel(
  id: json['id'] as String,
  description: json['description'] as String,
  dateTime: DateTime.parse(json['dateTime'] as String),
  status: json['status'] as bool?,
);

Map<String, dynamic> _$ToDoModelToJson(_ToDoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'dateTime': instance.dateTime.toIso8601String(),
      'status': instance.status,
    };
