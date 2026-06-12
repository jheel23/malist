import 'package:dartz/dartz.dart';
import 'package:malist/core/failures.dart';
import 'package:malist/data/source/core_service.dart';

abstract class CoreServiceRepo {
  Future<Either<Failure, Unit>> nukeData();
  Future<Either<Failure, String>> exportData(
    String password, {
    void Function(int, int)? onProgress,
  });
  Future<Either<Failure, Map<String, dynamic>>> validateBackup(
    String zipPath,
    String password,
  );
  Future<Either<Failure, Unit>> importData(
    String zipPath,
    String password, {
    void Function(int, int)? onProgress,
  });
}

class CoreServiceRepoImpl implements CoreServiceRepo {
  final CoreServiceSource source;
  CoreServiceRepoImpl({required this.source});

  @override
  Future<Either<Failure, Unit>> nukeData() => source.nukeData();

  @override
  Future<Either<Failure, String>> exportData(
    String password, {
    void Function(int, int)? onProgress,
  }) => source.exportData(password, onProgress: onProgress);

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateBackup(
    String zipPath,
    String password,
  ) => source.validateBackup(zipPath, password);

  @override
  Future<Either<Failure, Unit>> importData(
    String zipPath,
    String password, {
    void Function(int, int)? onProgress,
  }) => source.importData(zipPath, password, onProgress: onProgress);
}
