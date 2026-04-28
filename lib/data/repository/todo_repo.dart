import 'package:dartz/dartz.dart';
import 'package:flutter/rendering.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/data/models/todo/todo_model.dart';
import 'package:malist/data/source/database_service.dart';

abstract class TodoRepo {
  Future<Either<Failure, Unit>> addTodo({required ToDoModel todo});
  Future<Either<Failure, Unit>> updateTodo({required ToDoModel todo});
  Future<Either<Failure, bool>> deleteTodo({required String id});
  Future<Either<Failure, List<ToDoModel>>> getTodos();
}

class TodoRepoImpl implements TodoRepo {
  final DatabaseService databaseService;
  const TodoRepoImpl({required this.databaseService});

  final String _tableName = 'todos';
  @override
  Future<Either<Failure, Unit>> addTodo({required ToDoModel todo}) async {
    try {
      final result = await databaseService.insertRecord(
        _tableName,
        todo.toJson()..remove('id'),
      );
      debugPrint("addTodo result: $result");
      return result
          ? const Right(unit)
          : const Left(GeneralFailure("Failed to add todo"));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTodo({required String id}) async {
    try {
      final result = await databaseService.deleteRecord(_tableName, "id", id);
      return result.fold((failure) => Left(failure), (_) => const Right(true));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ToDoModel>>> getTodos() async {
    try {
      final result = await databaseService.getAllRecords(_tableName);
      return result.fold((failure) => Left(failure), (value) {
        final todos = value.map((e) => ToDoModel.fromJson(e)).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

        return Right(todos);
      });
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTodo({required ToDoModel todo}) async {
    try {
      final result = await databaseService.updateRecord(
        _tableName,
        todo.toJson(),
        "id",
        todo.id,
      );
      return result.fold((failure) => Left(failure), (_) => const Right(unit));
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }
}
