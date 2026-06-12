// lib/data/local/app_schemas.dart

import 'package:tostore/tostore.dart';

class DbSchemas {
  static final List<TableSchema> all = [
    // NOTES SCHEMA
    TableSchema(
      name: 'notes',
      primaryKeyConfig: PrimaryKeyConfig(
        name: 'id',
        type: PrimaryKeyType.shortCode,
      ),
      fields: [
        FieldSchema(name: 'title', type: DataType.text),
        FieldSchema(name: 'description', type: DataType.text),
        FieldSchema(name: 'dateTime', type: DataType.text),
        FieldSchema(name: 'isPinned', type: DataType.boolean),
      ],
    ),

    // To-Do SCHEMA
    TableSchema(
      name: 'todos',
      primaryKeyConfig: PrimaryKeyConfig(
        name: 'id',
        type: PrimaryKeyType.shortCode,
      ),
      fields: [
        FieldSchema(name: 'description', type: DataType.text),
        FieldSchema(name: 'dateTime', type: DataType.text),
        FieldSchema(name: 'status', type: DataType.boolean),
      ],
    ),

    // PASSWORD SCHEMA
    TableSchema(
      name: 'passwords',
      primaryKeyConfig: PrimaryKeyConfig(
        name: 'id',
        type: PrimaryKeyType.shortCode,
      ),
      fields: [
        FieldSchema(name: 'username', type: DataType.text),
        FieldSchema(name: 'category', type: DataType.text),
        FieldSchema(name: 'password', type: DataType.text),
        FieldSchema(name: 'dateTime', type: DataType.text),
      ],
    ),

    // FILES SCHEMA
    TableSchema(
      name: 'files',
      primaryKeyConfig: PrimaryKeyConfig(
        name: 'id',
        type: PrimaryKeyType.shortCode,
      ),
      fields: [
        FieldSchema(name: 'title', type: DataType.text),
        FieldSchema(name: 'originalFileName', type: DataType.text),
        FieldSchema(name: 'filePath', type: DataType.text),
        FieldSchema(name: 'fileExtension', type: DataType.text),
        FieldSchema(name: 'mimeType', type: DataType.text),
        FieldSchema(name: 'fileSize', type: DataType.integer),
        FieldSchema(name: 'createdAt', type: DataType.text),
        FieldSchema(name: 'source', type: DataType.text),
        FieldSchema(name: 'isFavorite', type: DataType.boolean),
      ],
    ),
  ];
}
