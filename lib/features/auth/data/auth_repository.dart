import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/backend_api_service.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final api = ref.watch(backendApiServiceProvider);
  return AuthRepositoryImpl(storage, api);
});

abstract class AuthRepository {
  Future<UserModel?> loginWithEmail(String email, String password);
  Future<UserModel?> signUpWithPhone(String phone, String name, String role);
  Future<UserModel?> signInWithGoogle();
  Future<void> logout();
  Future<UserModel?> switchRole(UserModel currentUser, String newRole);
  UserModel? getPersistedUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final StorageService _storageService;
  final BackendApiService _apiService;

  AuthRepositoryImpl(this._storageService, this._apiService);

  @override
  Future<UserModel?> loginWithEmail(String email, String password) async {
    final response = await _apiService.loginWithEmail(email, password);
    if (response.isSuccess && response.data != null) {
      final user = UserModel.fromMap(response.data!);
      await _storageService.setUserRole(user.role);
      await _storageService.setAuthenticated(true);
      return user;
    }
    return null;
  }

  @override
  Future<UserModel?> signUpWithPhone(
      String phone, String name, String role) async {
    final response = await _apiService.signUpWithPhone(phone, name, role);
    if (response.isSuccess && response.data != null) {
      final user = UserModel.fromMap(response.data!);
      await _storageService.setUserRole(user.role);
      await _storageService.setAuthenticated(true);
      return user;
    }
    return null;
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    final response = await _apiService.signInWithGoogle();
    if (response.isSuccess && response.data != null) {
      final user = UserModel.fromMap(response.data!);
      await _storageService.setUserRole(user.role);
      await _storageService.setAuthenticated(true);
      return user;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _storageService.setAuthenticated(false);
  }

  @override
  Future<UserModel?> switchRole(UserModel currentUser, String newRole) async {
    final updated = currentUser.copyWith(role: newRole);
    await _storageService.setUserRole(newRole);
    return updated;
  }

  @override
  UserModel? getPersistedUser() {
    final isAuthenticated = _storageService.isAuthenticated();
    if (!isAuthenticated) return null;

    final role = _storageService.getUserRole();
    return UserModel(
      uid: 'usr-persisted-100',
      fullName: role == 'rider' ? 'Jean Bosco K.' : 'Jean-Paul N.',
      email: 'user@gezayo.rw',
      phoneNumber: '+250 788 000 000',
      role: role,
    );
  }
}
