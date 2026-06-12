part of 'service_locator.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  final secureStorage = FlutterSecureStorage();
  final secureStorageService = SecureStorageService(secureStorage);
  sl.registerLazySingleton(() => secureStorageService);
  sl.registerLazySingleton(() => Dio());

  sl.registerLazySingleton(() => DioClient(ApiEndpoints.baseUrl, sl()));

  // ----------------------------------------------------------------------
  //? Services/Sources
  // ----------------------------------------------------------------------
  sl.registerSingleton<DatabaseService>(
    DatabaseServiceImpl(secureStorage: sl<SecureStorageService>()),
  );

  sl.registerSingleton<BackupStorageServiceImpl>(
    BackupStorageServiceImpl(backupDir: await _getBackupDirectory()),
  );

  sl.registerSingleton<CoreServiceSource>(
    CoreServiceSourceImpl(
      databaseService: sl<DatabaseService>(),
      backupStorageProvider: sl<BackupStorageServiceImpl>(),
    ),
  );

  // ----------------------------------------------------------------------
  //? Repositories
  // ----------------------------------------------------------------------
  sl.registerSingleton<NotesRepo>(
    NotesRepoImpl(databaseService: sl<DatabaseService>()),
  );

  sl.registerSingleton<PasswordsRepo>(
    PasswordsRepoImpl(databaseService: sl<DatabaseService>()),
  );

  sl.registerSingleton<TodoRepo>(
    TodoRepoImpl(databaseService: sl<DatabaseService>()),
  );

  sl.registerSingleton<FilesRepo>(
    FilesRepoImpl(databaseService: sl<DatabaseService>()),
  );

  sl.registerSingleton<CoreServiceRepo>(
    CoreServiceRepoImpl(source: sl<CoreServiceSource>()),
  );

  // ----------------------------------------------------------------------
  //? Providers
  // ----------------------------------------------------------------------
  sl.registerFactory(() => NotesNotifier(repository: sl<NotesRepo>()));
  sl.registerFactory(() => PasswordsNotifier(repository: sl<PasswordsRepo>()));
  sl.registerFactory(() => TodoNotifier(repository: sl<TodoRepo>()));
  sl.registerFactory(() => FilesNotifier(repository: sl<FilesRepo>()));
  sl.registerFactory(() => CoreServiceNotifier(repo: sl<CoreServiceRepo>()));
  sl.registerFactory(
    () => BackupNotifier(
      repo: sl<CoreServiceRepo>(),
      storage: sl<SecureStorageService>(),
      backupStorage: sl<BackupStorageServiceImpl>(),
    ),
  );
}

Future<Directory> _getBackupDirectory() async {
  final appDir = await getApplicationDocumentsDirectory();
  final backupDir = Directory('${appDir.path}/malist_backups');
  if (!await backupDir.exists()) {
    await backupDir.create(recursive: true);
  }
  return backupDir;
}
