// lib/core/dependency_injection.dart
// import 'package:baseqat/modules/arts_works/data/data_sources/remote/artwork_remote_data_source.dart';
// import 'package:baseqat/modules/arts_works/data/repositories/repository.dart';
import 'package:baseqat/modules/auth/data/repos/auth_repo.dart';
import 'package:baseqat/modules/auth/data/repos/auth_repo_impl.dart';
import 'package:baseqat/modules/auth/logic/login_cubit/login_cubit.dart';
import 'package:baseqat/modules/auth/logic/register_cubit/register_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> diInit() async {
  // Auth Repository
  sl.registerLazySingleton<AuthRepo>(
        () => AuthRepoImpl(Supabase.instance.client),
  );

  // Auth Cubits
  sl.registerFactory<LoginCubit>(
        () => LoginCubit(sl<AuthRepo>()),
  );

  sl.registerFactory<RegisterCubit>(
        () => RegisterCubit(sl<AuthRepo>()),
  );

  // Repository
  // sl.registerLazySingleton<ArtworkRepository>(
  //       () => ArtworkRepositoryImpl(remoteDataSource: sl()),
  // );
  //
  // // Data sources
  // sl.registerLazySingleton<ArtworkRemoteDataSource>(
  //       () => ArtworkRemoteDataSourceImpl(),
  // );
}
