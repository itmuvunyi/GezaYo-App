import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezayo_app/core/services/database_service.dart';
import 'package:gezayo_app/core/services/backend_api_service.dart';
import 'package:gezayo_app/core/services/firestore_service.dart';
import 'package:gezayo_app/features/rider/data/rider_repository.dart';
import 'package:gezayo_app/features/rider/presentation/rider_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiderRepository repo;
  late FirestoreService firestore;
  late RiderNotifier riderNotifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseService(prefs);
    final api = BackendApiService(db);
    firestore = FirestoreService(db);
    repo = RiderRepositoryImpl(api, firestore);
    riderNotifier = RiderNotifier(repository: repo, firestoreService: firestore);
  });

  group('RiderNotifier Tests', () {
    test('toggleOnlineStatus toggles state', () async {
      expect(riderNotifier.state.isOnline, false);
      await riderNotifier.toggleOnlineStatus(true);
      expect(riderNotifier.state.isOnline, true);
      await riderNotifier.toggleOnlineStatus(false);
      expect(riderNotifier.state.isOnline, false);
    });

    test('acceptJob sets activeJobId', () async {
      await riderNotifier.acceptJob('GZ-101', 3000);
      expect(riderNotifier.state.activeJobId, 'GZ-101');
    });

    test('completeCurrentJob updates earnings and balance', () async {
      final initialBalance = riderNotifier.state.totalBalanceRwf;
      await riderNotifier.acceptJob('GZ-101', 3000);
      await riderNotifier.completeCurrentJob(3000);

      expect(riderNotifier.state.activeJobId, null);
      expect(riderNotifier.state.totalBalanceRwf, initialBalance + 3000);
    });
  });
}
