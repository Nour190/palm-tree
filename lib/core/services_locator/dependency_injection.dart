// lib/core/dependency_injection.dart
import 'package:baseqat/modules/auth/data/repos/auth_repo.dart';
import 'package:baseqat/modules/auth/data/repos/auth_repo_impl.dart';
import 'package:baseqat/modules/auth/logic/login_cubit/login_cubit.dart';
import 'package:baseqat/modules/auth/logic/register_cubit/register_cubit.dart';
import 'package:baseqat/modules/profile/data/repositories/favorites_repository.dart';
import 'package:baseqat/modules/profile/data/datasources/favorites_remote_data_source.dart';
import 'package:baseqat/modules/profile/presentation/cubit/favorites_cubit.dart';
import 'package:baseqat/modules/profile/data/repositories/conversations_repository.dart';
import 'package:baseqat/modules/profile/data/datasources/conversations_remote_data_source.dart';
import 'package:baseqat/modules/profile/presentation/cubit/conversations_cubit.dart';
import 'package:baseqat/modules/profile/data/repositories/profile_repository.dart';
import 'package:baseqat/modules/profile/data/repositories/profile_repository_impl.dart';
import 'package:baseqat/modules/profile/presentation/cubit/account_settings_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

import '../../modules/auth/logic/auth_gate_cubit/auth_cubit.dart';

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
  sl.registerFactory<AuthCubit>(
        () => AuthCubit(sl<AuthRepo>()),
  );

  sl.registerFactory<RegisterCubit>(
        () => RegisterCubit(sl<AuthRepo>()),
  );

  // Profile Repository
  sl.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(Supabase.instance.client),
  );

  // Profile Cubits
  sl.registerFactory<AccountSettingsCubit>(
        () => AccountSettingsCubit(sl<ProfileRepository>()),
  );

  // Favorites Data Source
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
        () => FavoritesRemoteDataSourceImpl(Supabase.instance.client),
  );

  // Favorites Repository
  sl.registerLazySingleton<FavoritesRepository>(
        () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>()),
  );

  // Favorites Cubit
  sl.registerFactory<FavoritesCubit>(
        () => FavoritesCubit(sl<FavoritesRepository>()),
  );

  // Conversations Data Source
  sl.registerLazySingleton<ConversationsRemoteDataSource>(
        () => ConversationsRemoteDataSourceImpl(Supabase.instance.client),
  );

  // Conversations Repository
  sl.registerLazySingleton<ConversationsRepository>(
        () => ConversationsRepositoryImpl(sl<ConversationsRemoteDataSource>()),
  );

  // Conversations Cubit
  sl.registerFactory<ConversationsCubit>(
        () => ConversationsCubit(sl<ConversationsRepository>()),
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
