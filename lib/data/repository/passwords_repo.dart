import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/data/models/password/password_model.dart';
import 'package:malist/data/source/database_service.dart';

abstract class PasswordsRepo {
  Future<Either<Failure, Unit>> addPassword({required PasswordModel password});
  Future<Either<Failure, Unit>> updatePassword({
    required PasswordModel password,
  });
  Future<Either<Failure, bool>> deletePassword({required String id});
  Future<Either<Failure, List<PasswordModel>>> getPasswords();
}

class PasswordsRepoImpl implements PasswordsRepo {
  final DatabaseService databaseService;
  const PasswordsRepoImpl({required this.databaseService});

  final String _tableName = 'passwords';
  @override
  Future<Either<Failure, Unit>> addPassword({
    required PasswordModel password,
  }) async {
    try {
      final result = await databaseService.insertRecord(
        _tableName,
        password.toJson()..remove('id'),
      );
      debugPrint("addPassword result: $result");
      return result
          ? const Right(unit)
          : const Left(GeneralFailure("Failed to add password"));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePassword({required String id}) async {
    try {
      final result = await databaseService.deleteRecord(_tableName, "id", id);
      return result.fold((failure) => Left(failure), (_) => const Right(true));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PasswordModel>>> getPasswords() async {
    try {
      final result = await databaseService.getAllRecords(_tableName);
      return result.fold(
        (failure) => Left(failure),
        (value) => Right(value.map((e) => PasswordModel.fromJson(e)).toList()),
      );
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword({
    required PasswordModel password,
  }) async {
    try {
      final result = await databaseService.updateRecord(
        _tableName,
        password.toJson(),
        "id",
        password.id,
      );
      return result.fold((failure) => Left(failure), (_) => const Right(unit));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
