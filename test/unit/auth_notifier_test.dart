import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezayo_app/core/services/storage_service.dart';
import 'package:gezayo_app/core/services/database_service.dart';
import 'package:gezayo_app/core/services/backend_api_service.dart';
import 'package:gezayo_app/core/services/firestore_service.dart';
import 'package:gezayo_app/features/auth/data/auth_repository.dart';
import 'package:gezayo_app/features/auth/presentation/auth_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late DatabaseService dbService;
  late BackendApiService apiService;
  late FirestoreService firestoreService;
  late AuthRepository authRepo;
  late AuthNotifier authNotifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    dbService = DatabaseService(prefs);
    apiService = BackendApiService(dbService);
    firestoreService = FakeFirestoreService(dbService);
    authRepo = AuthRepositoryImpl(storageService, apiService, firestoreService);
    authNotifier = AuthNotifier(authRepo, storageService);
  });

  group('AuthNotifier Tests', () {
    test('Initial State is unauthenticated', () {
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.user, null);
    });

    test('loginWithEmail updates state with customer user', () async {
      final result =
          await authNotifier.loginWithEmail('customer@gezayo.rw', 'password');
      expect(result, true);
      expect(authNotifier.state.isAuthenticated, true);
      expect(authNotifier.state.user?.role, 'customer');
    });

    test('signUpWithEmail sets custom role and persists state', () async {
      final result = await authNotifier.signUpWithEmail(
          'eric@gezayo.rw', 'password123', 'Eric', 'rider');
      expect(result, true);
      expect(authNotifier.state.user?.role, 'rider');
      expect(storageService.getUserRole(), 'rider');
    });

    test('logout clears user state', () async {
      await authNotifier.loginWithEmail('user@gezayo.rw', 'pass');
      expect(authNotifier.state.isAuthenticated, true);

      await authNotifier.logout();
      expect(authNotifier.state.isAuthenticated, false);
      expect(authNotifier.state.user, null);
    });
  });
}
