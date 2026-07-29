import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/backend_api_service.dart';
import '../domain/delivery_model.dart';
import '../domain/rider_model.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final api = ref.watch(backendApiServiceProvider);
  return DeliveryRepositoryImpl(api);
});

abstract class DeliveryRepository {
  Future<DeliveryModel?> createDeliveryRequest({
    required String pickupAddress,
    required String dropoffAddress,
    required String packageType,
    required String weightClass,
    required String instructions,
    required double estimatedFare,
  });

  Future<DeliveryModel?> getActiveDelivery();
  Future<List<RiderModel>> fetchNearbyRiders();
  Future<DeliveryModel?> assignRider(DeliveryModel current, RiderModel rider);
  Future<DeliveryModel?> addTip(DeliveryModel current, double tipRwf);
  Future<DeliveryModel?> setRating(DeliveryModel current, int stars);
  Future<void> clearActiveDelivery(String deliveryId);
}

class DeliveryRepositoryImpl implements DeliveryRepository {
  final BackendApiService _apiService;

  DeliveryRepositoryImpl(this._apiService);

  @override
  Future<DeliveryModel?> createDeliveryRequest({
    required String pickupAddress,
    required String dropoffAddress,
    required String packageType,
    required String weightClass,
    required String instructions,
    required double estimatedFare,
  }) async {
    final payload = {
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'packageType': packageType,
      'weightClass': weightClass,
      'instructions': instructions,
      'estimatedFareRwf': estimatedFare,
      'status': 'searching',
    };

    final response = await _apiService.createDeliveryRequest(payload);
    if (response.isSuccess && response.data != null) {
      return DeliveryModel.fromMap(response.data!);
    }
    return null;
  }

  @override
  Future<DeliveryModel?> getActiveDelivery() async {
    final response = await _apiService.getActiveDelivery();
    if (response.isSuccess && response.data != null) {
      return DeliveryModel.fromMap(response.data!);
    }
    return null;
  }

  @override
  Future<List<RiderModel>> fetchNearbyRiders() async {
    final response = await _apiService.getNearbyRiders();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((m) => RiderModel.fromMap(m)).toList();
    }
    return [];
  }

  @override
  Future<DeliveryModel?> assignRider(
      DeliveryModel current, RiderModel rider) async {
    final updates = {
      'status': 'assigned',
      'assignedRiderName': rider.name,
      'assignedRiderRating': rider.rating,
    };
    final response =
        await _apiService.updateDeliveryStatus(current.id, updates);
    if (response.isSuccess && response.data != null) {
      return DeliveryModel.fromMap(response.data!);
    }
    return current.copyWith(
      status: DeliveryStatus.assigned,
      assignedRiderName: rider.name,
      assignedRiderRating: rider.rating,
    );
  }

  @override
  Future<DeliveryModel?> addTip(DeliveryModel current, double tipRwf) async {
    final updates = {
      'tipAmount': current.tipAmount + tipRwf,
    };
    final response =
        await _apiService.updateDeliveryStatus(current.id, updates);
    if (response.isSuccess && response.data != null) {
      return DeliveryModel.fromMap(response.data!);
    }
    return current.copyWith(tipAmount: current.tipAmount + tipRwf);
  }

  @override
  Future<DeliveryModel?> setRating(DeliveryModel current, int stars) async {
    final updates = {
      'ratingGiven': stars,
    };
    final response =
        await _apiService.updateDeliveryStatus(current.id, updates);
    if (response.isSuccess && response.data != null) {
      return DeliveryModel.fromMap(response.data!);
    }
    return current.copyWith(ratingGiven: stars);
  }

  @override
  Future<void> clearActiveDelivery(String deliveryId) async {
    await _apiService.updateDeliveryStatus(deliveryId, {'status': 'delivered'});
  }
}
