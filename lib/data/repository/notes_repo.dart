import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/data/models/notes/notes_model.dart';
import 'package:malist/data/source/database_service.dart';

abstract class NotesRepo {
  Future<Either<Failure, Unit>> addNotes({required NotesModel notes});
  Future<Either<Failure, Unit>> updateNotes({required NotesModel notes});
  Future<Either<Failure, bool>> deleteNotes({required String id});
  Future<Either<Failure, List<NotesModel>>> getNotes();
}

class NotesRepoImpl implements NotesRepo {
  final DatabaseService databaseService;
  const NotesRepoImpl({required this.databaseService});

  final String _tableName = 'notes';
  @override
  Future<Either<Failure, Unit>> addNotes({required NotesModel notes}) async {
    try {
      final result = await databaseService.insertRecord(
        _tableName,
        notes.toJson()..remove('id'),
      );
      debugPrint("addNotes result: $result");
      return result
          ? const Right(unit)
          : const Left(GeneralFailure("Failed to add notes"));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotes({required String id}) async {
    try {
      final result = await databaseService.deleteRecord(_tableName, "id", id);
      return result.fold((failure) => Left(failure), (_) => const Right(true));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotesModel>>> getNotes() async {
    try {
      final result = await databaseService.getAllRecords(_tableName);
      return result.fold(
        (failure) => Left(failure),
        (value) => Right(value.map((e) => NotesModel.fromJson(e)).toList()),
      );
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateNotes({required NotesModel notes}) async {
    try {
      final result = await databaseService.updateRecord(
        _tableName,
        notes.toJson(),
        "id",
        notes.id,
      );
      return result.fold((failure) => Left(failure), (_) => const Right(unit));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
