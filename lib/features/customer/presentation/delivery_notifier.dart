import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/delivery_model.dart';
import '../domain/rider_model.dart';
import '../data/delivery_repository.dart';

class DeliveryState {
  final DeliveryModel? activeDelivery;
  final List<RiderModel> availableRiders;
  final bool isAutoAssign;
  final bool isLoading;
  final String? errorMessage;

  const DeliveryState({
    this.activeDelivery,
    this.availableRiders = const [],
    this.isAutoAssign = true,
    this.isLoading = false,
    this.errorMessage,
  });

  DeliveryState copyWith({
    DeliveryModel? activeDelivery,
    List<RiderModel>? availableRiders,
    bool? isAutoAssign,
    bool? isLoading,
    String? errorMessage,
    bool clearActiveDelivery = false,
  }) {
    return DeliveryState(
      activeDelivery:
          clearActiveDelivery ? null : (activeDelivery ?? this.activeDelivery),
      availableRiders: availableRiders ?? this.availableRiders,
      isAutoAssign: isAutoAssign ?? this.isAutoAssign,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final deliveryNotifierProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return DeliveryNotifier(repo);
});

class DeliveryNotifier extends StateNotifier<DeliveryState> {
  final DeliveryRepository _repository;

  DeliveryNotifier(this._repository) : super(const DeliveryState()) {
    _initRiders();
  }

  Future<void> _initRiders() async {
    final riders = await _repository.fetchNearbyRiders();
    state = state.copyWith(availableRiders: riders);
  }

  Future<void> createDeliveryRequest({
    required String pickupAddress,
    required String dropoffAddress,
    required String packageType,
    required String weightClass,
    required String instructions,
    required double estimatedFare,
  }) async {
    state = state.copyWith(isLoading: true);
    final delivery = await _repository.createDeliveryRequest(
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      packageType: packageType,
      weightClass: weightClass,
      instructions: instructions,
      estimatedFare: estimatedFare,
    );
    state = state.copyWith(activeDelivery: delivery, isLoading: false);
  }

  Future<void> selectRider(RiderModel rider) async {
    if (state.activeDelivery != null) {
      state = state.copyWith(isLoading: true);
      final updated =
          await _repository.assignRider(state.activeDelivery!, rider);
      state = state.copyWith(activeDelivery: updated, isLoading: false);
    }
  }

  void toggleAssignMode(bool isAuto) {
    state = state.copyWith(isAutoAssign: isAuto);
  }

  Future<void> addTip(double tipAmount) async {
    if (state.activeDelivery != null) {
      final updated =
          await _repository.addTip(state.activeDelivery!, tipAmount);
      state = state.copyWith(activeDelivery: updated);
    }
  }

  Future<void> setRating(int stars) async {
    if (state.activeDelivery != null) {
      final updated = await _repository.setRating(state.activeDelivery!, stars);
      state = state.copyWith(activeDelivery: updated);
    }
  }

  Future<void> completeAndClearOrder() async {
    if (state.activeDelivery != null) {
      await _repository.clearActiveDelivery(state.activeDelivery!.id);
      state = state.copyWith(clearActiveDelivery: true);
    }
  }
}
