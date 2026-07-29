import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'storage_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DatabaseService(storage.prefs);
});

class DatabaseService {
  final SharedPreferences _prefs;

  DatabaseService(this._prefs) {
    _initDatabaseSeeding();
  }

  static const String _keyUsers = 'gezayo_db_users';
  static const String _keyDeliveries = 'gezayo_db_deliveries';
  static const String _keyRiders = 'gezayo_db_riders';
  static const String _keyTransactions = 'gezayo_db_transactions';
  static const String _keyNotifications = 'gezayo_db_notifications';

  void _initDatabaseSeeding() {
    if (!_prefs.containsKey(_keyRiders)) {
      final initialRiders = [
        {
          'id': 'r1',
          'name': 'Jean Bosco K.',
          'rating': 4.9,
          'completedJobs': 120,
          'vehicleType': 'EV Motor (Eco)',
          'etaText': '3 min',
          'distanceText': '0.8 km',
        },
        {
          'id': 'r2',
          'name': 'Claudine M.',
          'rating': 4.8,
          'completedJobs': 84,
          'vehicleType': 'EV Motor (Eco)',
          'etaText': '5 min',
          'distanceText': '1.4 km',
        },
        {
          'id': 'r3',
          'name': 'Eric N.',
          'rating': 4.7,
          'completedJobs': 210,
          'vehicleType': 'Fuel Moto',
          'etaText': '7 min',
          'distanceText': '2.1 km',
        },
      ];
      _prefs.setString(_keyRiders, json.encode(initialRiders));
    }

    if (!_prefs.containsKey(_keyTransactions)) {
      final initialTx = [
        {
          'id': 'tx-101',
          'title': 'Delivery #GZ-8821',
          'dateText': 'Today, 11:42 AM',
          'amountRwf': 4500.0,
          'type': 'jobEarning',
          'status': 'completed',
        },
        {
          'id': 'tx-102',
          'title': 'Withdrawal to MTN MoMo',
          'dateText': 'Yesterday, 4:15 PM',
          'amountRwf': 10000.0,
          'type': 'withdrawal',
          'status': 'completed',
        },
        {
          'id': 'tx-103',
          'title': 'Weekend Hero Bonus',
          'dateText': '2 days ago',
          'amountRwf': 5000.0,
          'type': 'bonus',
          'status': 'completed',
        },
      ];
      _prefs.setString(_keyTransactions, json.encode(initialTx));
    }

    if (!_prefs.containsKey(_keyNotifications)) {
      final initialNotifications = [
        {
          'id': 'n1',
          'title': 'Rider Assigned to Order #GZ-8821',
          'subtitle': 'Jean Claude is on his way to Kigali Heights for pickup.',
          'timeText': '5 mins ago',
          'icon': 'two_wheeler',
          'isUnread': true,
        },
        {
          'id': 'n2',
          'title': 'Order Completed Successfully',
          'subtitle': 'Your delivery to Norrsken House Kigali was completed.',
          'timeText': '2 hours ago',
          'icon': 'check_circle',
          'isUnread': false,
        },
      ];
      _prefs.setString(_keyNotifications, json.encode(initialNotifications));
    }
  }

  // Generic DB Operations
  List<Map<String, dynamic>> getCollection(String key) {
    final rawJson = _prefs.getString(key);
    if (rawJson == null || rawJson.isEmpty) return [];
    try {
      final List decoded = json.decode(rawJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCollection(
      String key, List<Map<String, dynamic>> items) async {
    await _prefs.setString(key, json.encode(items));
  }

  // Specific Entity APIs
  List<Map<String, dynamic>> getUsers() => getCollection(_keyUsers);

  Future<void> saveUser(Map<String, dynamic> userMap) async {
    final users = getUsers();
    final index = users.indexWhere((u) => u['uid'] == userMap['uid']);
    if (index >= 0) {
      users[index] = userMap;
    } else {
      users.add(userMap);
    }
    await saveCollection(_keyUsers, users);
  }

  List<Map<String, dynamic>> getDeliveries() => getCollection(_keyDeliveries);

  Future<void> saveDelivery(Map<String, dynamic> deliveryMap) async {
    final deliveries = getDeliveries();
    final index = deliveries.indexWhere((d) => d['id'] == deliveryMap['id']);
    if (index >= 0) {
      deliveries[index] = deliveryMap;
    } else {
      deliveries.add(deliveryMap);
    }
    await saveCollection(_keyDeliveries, deliveries);
  }

  List<Map<String, dynamic>> getRiders() => getCollection(_keyRiders);

  List<Map<String, dynamic>> getTransactions() =>
      getCollection(_keyTransactions);

  Future<void> addTransaction(Map<String, dynamic> txMap) async {
    final txs = getTransactions();
    txs.insert(0, txMap);
    await saveCollection(_keyTransactions, txs);
  }

  List<Map<String, dynamic>> getNotifications() =>
      getCollection(_keyNotifications);
}
