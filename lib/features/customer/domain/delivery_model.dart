import 'dart:convert';
import 'package:equatable/equatable.dart';

enum DeliveryStatus {
  searching,
  assigned,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
}

class DeliveryModel extends Equatable {
  final String id;
  final String pickupAddress;
  final String dropoffAddress;
  final String packageType; // 'Food', 'Parcel', 'Grocery', 'Other'
  final String
      weightClass; // 'Light (<5kg)', 'Medium (5-15kg)', 'Heavy (>15kg)'
  final String instructions;
  final double estimatedFareRwf;
  final DeliveryStatus status;
  final String? assignedRiderName;
  final String? assignedRiderPhone;
  final double assignedRiderRating;
  final int estimatedArrivalMins;
  final List<String> items;
  final double baseFare;
  final double distanceFare;
  final double peakHourBonus;
  final double tipAmount;
  final int ratingGiven;

  const DeliveryModel({
    required this.id,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.packageType,
    required this.weightClass,
    this.instructions = '',
    required this.estimatedFareRwf,
    this.status = DeliveryStatus.searching,
    this.assignedRiderName,
    this.assignedRiderPhone = '+250 788 123 456',
    this.assignedRiderRating = 4.9,
    this.estimatedArrivalMins = 12,
    this.items = const [
      '2x Grilled Tilapia with Isombe',
      '1x Ibirayi Special Fries'
    ],
    this.baseFare = 3000.0,
    this.distanceFare = 1200.0,
    this.peakHourBonus = 300.0,
    this.tipAmount = 0.0,
    this.ratingGiven = 0,
  });

  double get totalPaid => baseFare + distanceFare + peakHourBonus + tipAmount;

  DeliveryModel copyWith({
    String? id,
    String? pickupAddress,
    String? dropoffAddress,
    String? packageType,
    String? weightClass,
    String? instructions,
    double? estimatedFareRwf,
    DeliveryStatus? status,
    String? assignedRiderName,
    String? assignedRiderPhone,
    double? assignedRiderRating,
    int? estimatedArrivalMins,
    List<String>? items,
    double? baseFare,
    double? distanceFare,
    double? peakHourBonus,
    double? tipAmount,
    int? ratingGiven,
  }) {
    return DeliveryModel(
      id: id ?? this.id,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      packageType: packageType ?? this.packageType,
      weightClass: weightClass ?? this.weightClass,
      instructions: instructions ?? this.instructions,
      estimatedFareRwf: estimatedFareRwf ?? this.estimatedFareRwf,
      status: status ?? this.status,
      assignedRiderName: assignedRiderName ?? this.assignedRiderName,
      assignedRiderPhone: assignedRiderPhone ?? this.assignedRiderPhone,
      assignedRiderRating: assignedRiderRating ?? this.assignedRiderRating,
      estimatedArrivalMins: estimatedArrivalMins ?? this.estimatedArrivalMins,
      items: items ?? this.items,
      baseFare: baseFare ?? this.baseFare,
      distanceFare: distanceFare ?? this.distanceFare,
      peakHourBonus: peakHourBonus ?? this.peakHourBonus,
      tipAmount: tipAmount ?? this.tipAmount,
      ratingGiven: ratingGiven ?? this.ratingGiven,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'packageType': packageType,
      'weightClass': weightClass,
      'instructions': instructions,
      'estimatedFareRwf': estimatedFareRwf,
      'status': status.name,
      'assignedRiderName': assignedRiderName,
      'assignedRiderPhone': assignedRiderPhone,
      'assignedRiderRating': assignedRiderRating,
      'estimatedArrivalMins': estimatedArrivalMins,
      'items': items,
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'peakHourBonus': peakHourBonus,
      'tipAmount': tipAmount,
      'ratingGiven': ratingGiven,
    };
  }

  factory DeliveryModel.fromMap(Map<String, dynamic> map) {
    return DeliveryModel(
      id: map['id'] ?? '',
      pickupAddress: map['pickupAddress'] ?? '',
      dropoffAddress: map['dropoffAddress'] ?? '',
      packageType: map['packageType'] ?? 'Parcel',
      weightClass: map['weightClass'] ?? 'Light (<5kg)',
      instructions: map['instructions'] ?? '',
      estimatedFareRwf: (map['estimatedFareRwf'] ?? 2500.0).toDouble(),
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DeliveryStatus.searching,
      ),
      assignedRiderName: map['assignedRiderName'],
      assignedRiderPhone: map['assignedRiderPhone'] ?? '+250 788 123 456',
      assignedRiderRating: (map['assignedRiderRating'] ?? 4.9).toDouble(),
      estimatedArrivalMins: map['estimatedArrivalMins'] ?? 12,
      items: List<String>.from(map['items'] ??
          ['2x Grilled Tilapia with Isombe', '1x Ibirayi Special Fries']),
      baseFare: (map['baseFare'] ?? 3000.0).toDouble(),
      distanceFare: (map['distanceFare'] ?? 1200.0).toDouble(),
      peakHourBonus: (map['peakHourBonus'] ?? 300.0).toDouble(),
      tipAmount: (map['tipAmount'] ?? 0.0).toDouble(),
      ratingGiven: map['ratingGiven'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DeliveryModel.fromJson(String source) =>
      DeliveryModel.fromMap(json.decode(source));

  @override
  List<Object?> get props => [
        id,
        pickupAddress,
        dropoffAddress,
        packageType,
        weightClass,
        instructions,
        estimatedFareRwf,
        status,
        assignedRiderName,
        assignedRiderPhone,
        assignedRiderRating,
        estimatedArrivalMins,
        items,
        baseFare,
        distanceFare,
        peakHourBonus,
        tipAmount,
        ratingGiven,
      ];
}
