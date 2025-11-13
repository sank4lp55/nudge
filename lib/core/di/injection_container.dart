import 'package:get_it/get_it.dart';
import 'package:nudge/domain/repositories/chat_repositories.dart';
import 'package:nudge/presentation/bloc/chat/chat_list/chat_list_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/remote/mock_api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/chat/individual_chat/chat_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(
      getIt<FlutterSecureStorage>(),
      getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<MockApiService>(() => MockApiService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<MockApiService>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt<MockApiService>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

  // ChatListBloc is singleton since it's used in HomeScreen
  getIt.registerLazySingleton<ChatListBloc>(
    () => ChatListBloc(getIt<ChatRepository>()),
  );

  // ChatBloc is registered as Factory (not singleton)
  // because each chat screen needs its own instance
  getIt.registerFactory<ChatBloc>(() => ChatBloc(getIt<ChatRepository>()));
}
