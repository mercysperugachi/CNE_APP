import 'package:get_it/get_it.dart';
import '../config/appwrite_config.dart';
import '../database/app_database.dart';
import '../services/connectivity_service.dart';

// Auth Imports
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/recover_password_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Provincial Imports
import '../../features/provincial/domain/repositories/provincial_repository.dart';
import '../../features/provincial/domain/repositories/organizacion_repository.dart';
import '../../features/provincial/domain/repositories/votos_consolidados_repository.dart';
import '../../features/provincial/domain/usecases/get_recintos_usecase.dart';
import '../../features/provincial/domain/usecases/create_recinto_usecase.dart';
import '../../features/provincial/domain/usecases/create_coordinador_recinto_usecase.dart';
import '../../features/provincial/domain/usecases/get_actas_count_by_recinto_usecase.dart';
import '../../features/provincial/domain/usecases/get_organizaciones_by_dignidad_usecase.dart';
import '../../features/provincial/domain/usecases/get_votos_consolidados_usecase.dart';
import '../../features/provincial/data/datasources/provincial_remote_datasource.dart';
import '../../features/provincial/data/datasources/organizacion_remote_datasource.dart';
import '../../features/provincial/data/datasources/votos_consolidados_remote_datasource.dart';
import '../../features/provincial/data/repositories/provincial_repository_impl.dart';
import '../../features/provincial/data/repositories/organizacion_repository_impl.dart';
import '../../features/provincial/data/repositories/votos_consolidados_repository_impl.dart';
import '../../features/provincial/presentation/bloc/provincial_bloc.dart';

// Recinto Imports
import '../../features/recinto/domain/repositories/coordinador_recinto_repository.dart';
import '../../features/recinto/domain/usecases/get_mesas_by_recinto_usecase.dart';
import '../../features/recinto/domain/usecases/create_mesa_usecase.dart';
import '../../features/recinto/domain/usecases/create_veedor_mesa_usecase.dart';
import '../../features/recinto/domain/usecases/get_asignaciones_by_recinto_usecase.dart';
import '../../features/recinto/data/datasources/recinto_remote_datasource.dart';
import '../../features/recinto/data/repositories/coordinador_recinto_repository_impl.dart';
import '../../features/recinto/presentation/bloc/recinto_bloc.dart';

// Veedor Imports
import '../../features/veedor/domain/repositories/veedor_repository.dart';
import '../../features/veedor/domain/usecases/get_acta_mesa_usecase.dart';
import '../../features/veedor/domain/usecases/get_actas_by_mesa_usecase.dart';
import '../../features/veedor/domain/usecases/get_mesas_by_veedor_usecase.dart';
import '../../features/veedor/domain/usecases/submit_acta_usecase.dart';
import '../../features/veedor/domain/usecases/save_acta_offline_usecase.dart';
import '../../features/veedor/domain/usecases/get_pending_actas_usecase.dart';
import '../../features/veedor/data/datasources/veedor_remote_datasource.dart';
import '../../features/veedor/data/datasources/acta_local_datasource.dart';
import '../../features/veedor/data/repositories/veedor_repository_impl.dart';
import '../../features/veedor/data/services/sync_service.dart';
import '../../features/veedor/presentation/bloc/veedor_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core / Config
  sl.registerLazySingleton(() => AppwriteConfig());
  sl.registerLazySingleton(() => AppDatabase());
  sl.registerLazySingleton(() => ConnectivityService());

// Features - Auth

  // 1. DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AppwriteAuthDataSource(sl()),
  );

  // 2. Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // 3. UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => RecoverPasswordUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // 4. Blocs
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      checkAuthUseCase: sl(),
      changePasswordUseCase: sl(),
      recoverPasswordUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Features - Provincial

  sl.registerLazySingleton<ProvincialRemoteDataSource>(
    () => AppwriteProvincialDataSource(sl()),
  );

  sl.registerLazySingleton<ProvincialRepository>(
    () => ProvincialRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<OrganizacionRemoteDataSource>(
    () => AppwriteOrganizacionDataSource(sl()),
  );

  sl.registerLazySingleton<OrganizacionRepository>(
    () => OrganizacionRepositoryImpl(sl<OrganizacionRemoteDataSource>()),
  );

  sl.registerLazySingleton<VotosConsolidadosRemoteDataSource>(
    () => AppwriteVotosConsolidadosDataSource(sl()),
  );

  sl.registerLazySingleton<VotosConsolidadosRepository>(
    () => VotosConsolidadosRepositoryImpl(sl<VotosConsolidadosRemoteDataSource>()),
  );

  sl.registerLazySingleton(() => GetRecintosUseCase(sl()));
  sl.registerLazySingleton(() => CreateRecintoUseCase(sl()));
  sl.registerLazySingleton(() => CreateCoordinadorRecintoUseCase(sl()));
  sl.registerLazySingleton(() => GetActasCountByRecintoUseCase(sl()));
  sl.registerLazySingleton(() => GetOrganizacionesByDignidadUseCase(sl()));
  sl.registerLazySingleton(() => GetVotosConsolidadosUseCase(sl()));

  sl.registerFactory(
    () => ProvincialBloc(
      getRecintosUseCase: sl(),
      createRecintoUseCase: sl(),
      createCoordinadorRecintoUseCase: sl(),
      getOrganizacionesUseCase: sl(),
      getVotosConsolidadosUseCase: sl(),
    ),
  );

  // Features - Recinto

  sl.registerLazySingleton<RecintoRemoteDataSource>(
    () => AppwriteRecintoDataSource(sl()),
  );

  sl.registerLazySingleton<CoordinadorRecintoRepository>(
    () => CoordinadorRecintoRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetMesasByRecintoUseCase(sl()));
  sl.registerLazySingleton(() => CreateMesaUseCase(sl()));
  sl.registerLazySingleton(() => CreateVeedorMesaUseCase(sl()));
  sl.registerLazySingleton(() => GetAsignacionesByRecintoUseCase(sl()));

  sl.registerFactory(
    () => RecintoBloc(
      getMesasUseCase: sl(),
      createMesaUseCase: sl(),
      createVeedorMesaUseCase: sl(),
    ),
  );

  // Features - Veedor

  sl.registerLazySingleton<VeedorRemoteDataSource>(
    () => AppwriteVeedorDataSource(sl()),
  );

  sl.registerLazySingleton<ActaLocalDataSource>(
    () => SqfliteActaLocalDataSource(sl()),
  );

  sl.registerLazySingleton<VeedorRepository>(
    () => VeedorRepositoryImpl(sl(), sl()),
  );

  sl.registerLazySingleton(() => GetActaMesaUseCase(sl()));
  sl.registerLazySingleton(() => GetActasByMesaUseCase(sl()));
  sl.registerLazySingleton(() => GetMesasByVeedorUseCase(sl()));
  sl.registerLazySingleton(() => SubmitActaUseCase(sl()));
  sl.registerLazySingleton(() => SaveActaOfflineUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingActasUseCase(sl()));

  sl.registerLazySingleton<SyncService>(
    () => SyncService(sl(), sl(), sl()),
  );

  sl.registerFactory(
    () => VeedorBloc(
      getActaMesaUseCase: sl(),
      getActasByMesaUseCase: sl(),
      getMesasByVeedorUseCase: sl(),
      submitActaUseCase: sl(),
      saveActaOfflineUseCase: sl(),
      getPendingActasUseCase: sl(),
      syncService: sl(),
    ),
  );
}