import 'dart:convert';
import 'dart:math';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:malist/core/constants/db_schemas.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/core/local/secure_storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tostore/tostore.dart';

/// Interface for dependency injection
abstract class DatabaseService {
  Future<void> initDb();
  Future<bool> insertRecord(String table, Map<String, dynamic> data);
  Future<Either<Failure, List<Map<String, dynamic>>>> queryRecords(
    String table,
    String field,
    String operator,
    dynamic value,
  );
  Future<Either<Failure, Unit>> updateRecord(
    String table,
    Map<String, dynamic> data,
    String whereField,
    dynamic whereValue,
  );
  Future<Either<Failure, Unit>> deleteRecord(
    String table,
    String whereField,
    dynamic whereValue,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllRecords(
    String table,
  );
  Future<Either<Failure, Unit>> deleteAll();
}

class DatabaseServiceImpl implements DatabaseService {
  final SecureStorageService secureStorage;

  DatabaseServiceImpl({required this.secureStorage});

  static const String _keyName = 'malist_master_key';
  late final ToStore db;

  @override
  Future<void> initDb() async {
    final String masterKey = await _getOrCreateEncryptionKey();
    final directory = await getApplicationDocumentsDirectory();
    db = await ToStore.open(
      dbName: 'malist',
      config: DataStoreConfig(
        dbPath: directory.path,
        encryptionConfig: EncryptionConfig(encryptionKey: masterKey),
      ),
      schemas: DbSchemas.all,
    );
    debugPrint('ToStore database initialized with inbuilt encryption.');
  }

  /// Encrytion Key Creation
  Future<String> _getOrCreateEncryptionKey() async {
    String? existingKey = await secureStorage.getString(_keyName);

    if (existingKey != null) {
      return existingKey;
    }
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final secureRandomKey = base64UrlEncode(values);
    await secureStorage.setString(_keyName, secureRandomKey);
    return secureRandomKey;
  }

  @override
  Future<bool> insertRecord(String table, Map<String, dynamic> data) async {
    final result = await db.insert(table, data);
    if (result.isSuccess) {
      debugPrint(
        'Insert succeeded, generated primary key ID: ${result.successKeys.first}',
      );
      return true;
    } else {
      debugPrint('Insert failed: ${result.message}');
      return false;
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> queryRecords(
    String table,
    String field,
    String operator,
    dynamic value,
  ) async {
    try {
      final records = await db.query(table).where(field, operator, value);
      if (records.isSuccess) {
        return Right(List<Map<String, dynamic>>.from(records.data));
      } else {
        return Left(GeneralFailure(records.message));
      }
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateRecord(
    String table,
    Map<String, dynamic> data,
    String whereField,
    dynamic whereValue,
  ) async {
    try {
      final result = await db
          .update(table, data)
          .where(whereField, '=', whereValue);
      if (result.isSuccess) {
        return Right(unit);
      } else {
        return Left(GeneralFailure(result.message));
      }
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecord(
    String table,
    String whereField,
    dynamic whereValue,
  ) async {
    try {
      final result = await db.delete(table).where(whereField, '=', whereValue);
      if (result.isSuccess) {
        return Right(unit);
      } else {
        return Left(GeneralFailure(result.message));
      }
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllRecords(
    String table,
  ) async {
    try {
      final records = await db.query(table);
      if (records.isSuccess) {
        return Right(List<Map<String, dynamic>>.from(records.data));
      } else {
        return Left(GeneralFailure(records.message));
      }
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAll() async {
    try {
      final tables = ['notes', 'todos', 'passwords'];
      for (final table in tables) {
        final records = await db.query(table);
        if (records.isSuccess) {
          for (final record in records.data) {
            await db.delete(table).where('id', '=', record['id']);
          }
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
