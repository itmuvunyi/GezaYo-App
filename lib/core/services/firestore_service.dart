import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/user_model.dart';
import '../../features/customer/domain/delivery_model.dart';
import '../../features/customer/domain/rider_model.dart';
import '../../features/rider/domain/transaction_model.dart';
import 'database_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final db = ref.watch(databaseServiceProvider);
  try {
    return FirestoreService(FirebaseFirestore.instance, db);
  } catch (_) {
    return FakeFirestoreService(db);
  }
});

class FirestoreService {
  final FirebaseFirestore? _firestore;
  final DatabaseService _localDb;

  FirestoreService(this._firestore, this._localDb);

  // Firestore Collection References
  CollectionReference<Map<String, dynamic>>? get _usersCol =>
      _firestore?.collection('users');

  CollectionReference<Map<String, dynamic>>? get _deliveriesCol =>
      _firestore?.collection('deliveries');

  CollectionReference<Map<String, dynamic>>? get _ridersCol =>
      _firestore?.collection('riders');

  CollectionReference<Map<String, dynamic>>? get _transactionsCol =>
      _firestore?.collection('transactions');

  CollectionReference<Map<String, dynamic>>? get _notificationsCol =>
      _firestore?.collection('notifications');

  // --- USERS COLLECTION SCHEMA & CRUD ---

  /// Creates/updates user document in Cloud Firestore upon signup/login
  Future<void> saveUser(UserModel user) async {
    try {
      if (_usersCol != null) {
        await _usersCol!
            .doc(user.uid)
            .set(user.toMap(), SetOptions(merge: true));
        return;
      }
    } catch (e) {
      debugPrint('Firestore saveUser error: $e');
    }
    await _localDb.saveUser(user.toMap());
  }

  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      if (_usersCol != null) {
        await _usersCol!
            .doc(uid)
            .set({'isOnline': isOnline}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore updateOnlineStatus error: $e');
    }
  }

  /// Updates rider location and online status in Firestore
  Future<void> updateRiderLocation(
      String uid, double lat, double lng) async {
    try {
      if (_usersCol != null) {
        await _usersCol!.doc(uid).set({
          'isOnline': true,
          'latitude': lat,
          'longitude': lng,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore updateRiderLocation error: $e');
    }
  }

  /// Real-time stream of online riders with valid locations
  Stream<List<UserModel>> getOnlineRidersStream() {
    if (_usersCol != null) {
      return _usersCol!
          .where('role', isEqualTo: 'rider')
          .where('isOnline', isEqualTo: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .where((u) => u.latitude != 0.0 && u.longitude != 0.0)
              .toList());
    }
    return Stream.value([]);
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      if (_usersCol != null) {
        final doc = await _usersCol!.doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!);
        }
      }
    } catch (e) {
      debugPrint('Firestore getUser error: $e');
    }
    final localUsers = _localDb.getUsers();
    final match = localUsers.firstWhere(
      (u) => u['uid'] == uid,
      orElse: () => {},
    );
    return match.isNotEmpty ? UserModel.fromMap(match) : null;
  }

  // --- DELIVERIES COLLECTION SCHEMA & CRUD ---

  Future<DeliveryModel> createDelivery(DeliveryModel delivery) async {
    try {
      if (_deliveriesCol != null) {
        await _deliveriesCol!.doc(delivery.id).set(delivery.toMap());
        return delivery;
      }
    } catch (e) {
      debugPrint('Firestore createDelivery error: $e');
    }
    await _localDb.saveDelivery(delivery.toMap());
    return delivery;
  }

  Future<DeliveryModel?> getActiveDelivery(String userId) async {
    try {
      if (_deliveriesCol != null) {
        final snap = await _deliveriesCol!
            .where('status',
                whereIn: ['searching', 'assigned', 'pickedUp', 'onTheWay'])
            .limit(1)
            .get();

        if (snap.docs.isNotEmpty) {
          return DeliveryModel.fromMap(snap.docs.first.data());
        }
      }
    } catch (e) {
      debugPrint('Firestore getActiveDelivery error: $e');
    }

    final localDeliveries = _localDb.getDeliveries();
    if (localDeliveries.isNotEmpty) {
      return DeliveryModel.fromMap(localDeliveries.last);
    }
    return null;
  }

  Future<void> updateDelivery(
      String deliveryId, Map<String, dynamic> updates) async {
    try {
      if (_deliveriesCol != null) {
        await _deliveriesCol!.doc(deliveryId).update(updates);
        return;
      }
    } catch (e) {
      debugPrint('Firestore updateDelivery error: $e');
    }
    final localDeliveries = _localDb.getDeliveries();
    final match = localDeliveries.firstWhere(
      (d) => d['id'] == deliveryId,
      orElse: () => {},
    );
    if (match.isNotEmpty) {
      final updated = {...match, ...updates};
      await _localDb.saveDelivery(updated);
    }
  }

  /// Real-time stream for a single delivery document
  Stream<DeliveryModel?> getDeliveryStream(String deliveryId) {
    if (_deliveriesCol != null) {
      return _deliveriesCol!.doc(deliveryId).snapshots().map((snap) {
        if (snap.exists && snap.data() != null) {
          return DeliveryModel.fromMap(snap.data()!);
        }
        return null;
      });
    }
    return Stream.value(null);
  }

  /// Real-time stream of available jobs (status == 'searching') for riders
  Stream<List<DeliveryModel>> getAvailableJobsStream() {
    if (_deliveriesCol != null) {
      return _deliveriesCol!
          .where('status', isEqualTo: 'searching')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => DeliveryModel.fromMap(doc.data()))
              .toList());
    }
    return Stream.value([]);
  }

  // --- RIDERS COLLECTION SCHEMA & CRUD ---

  Future<List<RiderModel>> getNearbyRiders() async {
    try {
      if (_ridersCol != null) {
        final snap = await _ridersCol!.limit(10).get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((doc) => RiderModel.fromMap(doc.data()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getNearbyRiders error: $e');
    }

    final localRiders = _localDb.getRiders();
    return localRiders.map((m) => RiderModel.fromMap(m)).toList();
  }

  // --- TRANSACTIONS COLLECTION SCHEMA & CRUD ---

  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      if (_transactionsCol != null) {
        final snap = await _transactionsCol!.limit(20).get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((doc) => TransactionModel.fromMap(doc.data()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getTransactions error: $e');
    }

    final localTx = _localDb.getTransactions();
    return localTx.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    try {
      if (_transactionsCol != null) {
        await _transactionsCol!.doc(tx.id).set(tx.toMap());
        return;
      }
    } catch (e) {
      debugPrint('Firestore addTransaction error: $e');
    }
    await _localDb.addTransaction(tx.toMap());
  }

  // --- NOTIFICATIONS REAL-TIME STREAM ---

  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    if (_notificationsCol != null) {
      return _notificationsCol!
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());
    }
    return Stream.value([]);
  }
}

class FakeFirestoreService extends FirestoreService {
  FakeFirestoreService(DatabaseService localDb) : super(null, localDb);

  @override
  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    return Stream.value([]);
  }

  @override
  Stream<List<UserModel>> getOnlineRidersStream() {
    return Stream.value([]);
  }

  @override
  Stream<DeliveryModel?> getDeliveryStream(String deliveryId) {
    return Stream.value(null);
  }

  @override
  Stream<List<DeliveryModel>> getAvailableJobsStream() {
    return Stream.value([]);
  }
}
