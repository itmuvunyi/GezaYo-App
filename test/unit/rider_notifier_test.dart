import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezayo_app/core/services/database_service.dart';
import 'package:gezayo_app/core/services/backend_api_service.dart';
import 'package:gezayo_app/features/rider/data/rider_repository.dart';
import 'package:gezayo_app/features/rider/presentation/rider_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RiderRepository repo;
  late RiderNotifier riderNotifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseService(prefs);
    final api = BackendApiService(db);
    repo = RiderRepositoryImpl(api);
    riderNotifier = RiderNotifier(repo);
  });

  group('RiderNotifier Tests', () {
    test('toggleOnlineStatus toggles state', () {
      expect(riderNotifier.state.isOnline, true);
      riderNotifier.toggleOnlineStatus(false);
      expect(riderNotifier.state.isOnline, false);
    });

    test('acceptJob sets active job id and status', () {
      riderNotifier.acceptJob('JOB-101', 2500);
      expect(riderNotifier.state.activeJobId, 'JOB-101');
    });

    test('completeCurrentJob increments earnings and jobs completed', () {
      final initialBalance = riderNotifier.state.totalBalanceRwf;
      final initialJobs = riderNotifier.state.jobsDoneToday;

      riderNotifier.acceptJob('JOB-101', 2500);
      riderNotifier.completeCurrentJob(2500);

      expect(riderNotifier.state.jobsDoneToday, initialJobs + 1);
      expect(riderNotifier.state.totalBalanceRwf, initialBalance + 2500);
      expect(riderNotifier.state.activeJobId, null);
    });

    test('withdrawToMoMo deducts balance on valid amount', () async {
      final initialBalance = riderNotifier.state.totalBalanceRwf;
      final success = await riderNotifier.withdrawToMoMo(5000);

      expect(success, true);
      expect(riderNotifier.state.totalBalanceRwf, initialBalance - 5000);
    });
  });
}
