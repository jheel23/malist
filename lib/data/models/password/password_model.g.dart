// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PasswordModel _$PasswordModelFromJson(Map<String, dynamic> json) =>
    _PasswordModel(
      id: json['id'] as String,
      username: json['username'] as String,
      category: json['category'] as String,
      password: json['password'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
    );

Map<String, dynamic> _$PasswordModelToJson(_PasswordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'category': instance.category,
      'password': instance.password,
      'dateTime': instance.dateTime.toIso8601String(),
    };
