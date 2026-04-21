import 'package:dartz/dartz.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/data/source/core_service.dart';

abstract class CoreServiceRepo {
  Future<Either<Failure, Unit>> nukeData();
  Future<Either<Failure, Unit>> importData();
  Future<Either<Failure, Unit>> exportData();
}

class CoreServiceRepoImpl implements CoreServiceRepo {
  final CoreServiceSource source;

  CoreServiceRepoImpl({required this.source});

  @override
  Future<Either<Failure, Unit>> importData() {
    return source.importData();
  }

  @override
  Future<Either<Failure, Unit>> nukeData() {
    return source.nukeData();
  }

  @override
  Future<Either<Failure, Unit>> exportData() {
    return source.exportData();
  }
}
