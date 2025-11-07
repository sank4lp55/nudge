import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/mock_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockApiService _apiService;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._apiService, this._localDataSource);

  @override
  Future<User> login(String email, String password) async {
    try {
      final user = await _apiService.login(email, password);

      // Save user and mock token locally
      await _localDataSource.saveToken('mock_token_${user.id}');
      await _localDataSource.saveUser(user);

      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _apiService.logout();
    await _localDataSource.clearAuth();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _localDataSource.getUser();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.isLoggedIn();
  }
}