import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/data/models/files/user_file.dart';
import 'package:malist/data/source/database_service.dart';

abstract class FilesRepo {
  Future<Either<Failure, Unit>> addFile({required UserFile file});
  Future<Either<Failure, Unit>> updateFile({required UserFile file});
  Future<Either<Failure, bool>> deleteFile({
    required String id,
    required String filePath,
  });
  Future<Either<Failure, List<UserFile>>> getFiles();
}

class FilesRepoImpl implements FilesRepo {
  final DatabaseService databaseService;
  const FilesRepoImpl({required this.databaseService});

  final String _tableName = 'files';

  @override
  Future<Either<Failure, Unit>> addFile({required UserFile file}) async {
    try {
      final json = file.toJson()..remove('id');
      json['createdAt'] = file.createdAt.toIso8601String();
      json['source'] = file.source.name;
      final result = await databaseService.insertRecord(_tableName, json);
      debugPrint("addFile result: $result");
      return result
          ? const Right(unit)
          : const Left(GeneralFailure("Failed to add file"));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFile({
    required String id,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      final result = await databaseService.deleteRecord(_tableName, "id", id);
      return result.fold((failure) => Left(failure), (_) => const Right(true));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserFile>>> getFiles() async {
    try {
      final result = await databaseService.getAllRecords(_tableName);
      return result.fold((failure) => Left(failure), (value) {
        final files = value.map((e) {
          final map = Map<String, dynamic>.from(e);
          if (map['createdAt'] is String) {
            map['createdAt'] = map['createdAt'];
          }
          if (map['source'] is String) {
            map['source'] = map['source'];
          }
          return UserFile.fromJson(map);
        }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return Right(files);
      });
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateFile({required UserFile file}) async {
    try {
      final json = file.toJson();
      json['createdAt'] = file.createdAt.toIso8601String();
      json['source'] = file.source.name;
      final result = await databaseService.updateRecord(
        _tableName,
        json,
        "id",
        file.id,
      );
      return result.fold((failure) => Left(failure), (_) => const Right(unit));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
