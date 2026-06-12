// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserFile _$UserFileFromJson(Map<String, dynamic> json) => _UserFile(
  id: json['id'] as String,
  title: json['title'] as String,
  originalFileName: json['originalFileName'] as String,
  filePath: json['filePath'] as String,
  fileExtension: json['fileExtension'] as String,
  mimeType: json['mimeType'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  source: $enumDecode(_$FileSourceEnumMap, json['source']),
  isFavorite: json['isFavorite'] as bool? ?? false,
);

Map<String, dynamic> _$UserFileToJson(_UserFile instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'originalFileName': instance.originalFileName,
  'filePath': instance.filePath,
  'fileExtension': instance.fileExtension,
  'mimeType': instance.mimeType,
  'fileSize': instance.fileSize,
  'createdAt': instance.createdAt.toIso8601String(),
  'source': _$FileSourceEnumMap[instance.source]!,
  'isFavorite': instance.isFavorite,
};

const _$FileSourceEnumMap = {
  FileSource.camera: 'camera',
  FileSource.device: 'device',
};
