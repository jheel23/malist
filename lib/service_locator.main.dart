part of 'service_locator.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  final secureStorage = FlutterSecureStorage();
  final secureStorageService = SecureStorageService(secureStorage);
  sl.registerLazySingleton(() => secureStorageService);
  sl.registerLazySingleton(() => Dio());

  //Dio client initialization...
  sl.registerLazySingleton(() => DioClient(ApiEndpoints.baseUrl, sl()));

  // ----------------------------------------------------------------------
  //? Services/Sources
  // ----------------------------------------------------------------------
  // sl.registerSingleton<DemandItemsApiService>(DemandItemsApiServiceImpl(sl()));
  sl.registerSingleton<DatabaseService>(
    DatabaseServiceImpl(secureStorage: sl<SecureStorageService>()),
  );
  sl.registerSingleton<CoreServiceSource>(
    CoreServiceSourceImpl(
      databaseService: sl<DatabaseService>(),
      secureStorageService: sl<SecureStorageService>(),
    ),
  );

  // ----------------------------------------------------------------------
  //? Repositories
  // ----------------------------------------------------------------------
  // sl.registerSingleton<DemandItemsRepo>(DemandItemsRepoImp(sl()));
  sl.registerSingleton<NotesRepo>(
    NotesRepoImpl(databaseService: sl<DatabaseService>()),
  );

  sl.registerSingleton<PasswordsRepo>(
    PasswordsRepoImpl(databaseService: sl<DatabaseService>()),
  );

  sl.registerSingleton<TodoRepo>(
    TodoRepoImpl(databaseService: sl<DatabaseService>()),
  );
  sl.registerSingleton<CoreServiceRepo>(
    CoreServiceRepoImpl(source: sl<CoreServiceSource>()),
  );

  // ----------------------------------------------------------------------
  //? Providers
  // ----------------------------------------------------------------------
  // sl.registerFactory(() => DemandItemsNotifier(sl<GetDemandItemsUseCase>()));

  sl.registerFactory(() => NotesNotifier(repository: sl<NotesRepo>()));
  sl.registerFactory(() => PasswordsNotifier(repository: sl<PasswordsRepo>()));
  sl.registerFactory(() => TodoNotifier(repository: sl<TodoRepo>()));
  sl.registerFactory(() => CoreServiceNotifier(repo: sl<CoreServiceRepo>()));
}
