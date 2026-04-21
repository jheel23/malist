import 'package:dartz/dartz.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/core/local/secure_storage_service.dart';
import 'package:malist/data/source/database_service.dart';

abstract class CoreServiceSource {
  Future<Either<Failure, Unit>> nukeData();
  Future<Either<Failure, Unit>> importData();
  Future<Either<Failure, Unit>> exportData();
}

class CoreServiceSourceImpl implements CoreServiceSource {
  final DatabaseService databaseService;
  final SecureStorageService secureStorageService;

  CoreServiceSourceImpl({
    required this.databaseService,
    required this.secureStorageService,
  });

  @override
  Future<Either<Failure, Unit>> importData() {
    // TODO: implement importData
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> nukeData() async {
    try {
      await databaseService.deleteAll();
      await secureStorageService.nuke();
      return Right(unit);
    } catch (e) {
      return Left(GeneralFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> exportData() {
    // TODO: implement exportData
    throw UnimplementedError();
  }
}
