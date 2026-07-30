import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gezayo_app/core/services/database_service.dart';
import 'package:gezayo_app/core/services/backend_api_service.dart';
import 'package:gezayo_app/core/services/firestore_service.dart';
import 'package:gezayo_app/features/customer/data/delivery_repository.dart';
import 'package:gezayo_app/features/customer/domain/delivery_model.dart';
import 'package:gezayo_app/features/customer/domain/rider_model.dart';
import 'package:gezayo_app/features/customer/presentation/delivery_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DeliveryRepository repo;
  late FirestoreService firestore;
  late DeliveryNotifier deliveryNotifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseService(prefs);
    final api = BackendApiService(db);
    firestore = FakeFirestoreService(db);
    repo = DeliveryRepositoryImpl(api, firestore);
    deliveryNotifier = DeliveryNotifier(repo, firestore);
  });

  group('DeliveryNotifier Tests', () {
    test('createDeliveryRequest sets active delivery correctly', () async {
      await deliveryNotifier.createDeliveryRequest(
        pickupAddress: 'KN 5 Rd',
        dropoffAddress: 'CBD Kigali',
        packageType: 'Food',
        weightClass: 'Light (<5kg)',
        instructions: 'Call on arrival',
        estimatedFare: 3000,
        customerUid: 'cust-123',
      );

      final active = deliveryNotifier.state.activeDelivery;
      expect(active, isNotNull);
      expect(active?.pickupAddress, 'KN 5 Rd');
      expect(active?.estimatedFareRwf, 3000);
      expect(active?.status, DeliveryStatus.searching);
    });

    test('selectRider updates delivery status to assigned', () async {
      await deliveryNotifier.createDeliveryRequest(
        pickupAddress: 'KN 5 Rd',
        dropoffAddress: 'CBD Kigali',
        packageType: 'Parcel',
        weightClass: 'Light (<5kg)',
        instructions: '',
        estimatedFare: 2500,
        customerUid: 'cust-123',
      );

      const testRider = RiderModel(
        id: 'r1',
        name: 'Jean Bosco K.',
        rating: 4.9,
        completedJobs: 120,
        vehicleType: 'EV Motor (Eco)',
        etaText: '3 min',
      );

      await deliveryNotifier.selectRider(testRider);

      expect(deliveryNotifier.state.activeDelivery?.assignedRiderName,
          testRider.name);
      expect(deliveryNotifier.state.activeDelivery?.status,
          DeliveryStatus.assigned);
    });

    test('addTip increases tip amount', () async {
      await deliveryNotifier.createDeliveryRequest(
        pickupAddress: 'A',
        dropoffAddress: 'B',
        packageType: 'Food',
        weightClass: 'Light (<5kg)',
        instructions: '',
        estimatedFare: 2000,
        customerUid: 'cust-123',
      );

      await deliveryNotifier.addTip(1000);
      expect(deliveryNotifier.state.activeDelivery?.tipAmount, 1000);
    });
  });
}
