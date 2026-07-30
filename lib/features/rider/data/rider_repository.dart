import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/backend_api_service.dart';
import '../../../core/services/firestore_service.dart';
import '../domain/transaction_model.dart';

final riderRepositoryProvider = Provider<RiderRepository>((ref) {
  final api = ref.watch(backendApiServiceProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  return RiderRepositoryImpl(api, firestore);
});

abstract class RiderRepository {
  Future<List<TransactionModel>> fetchTransactions();
  Future<bool> withdrawToMoMo(double amount, String userId);
}

class RiderRepositoryImpl implements RiderRepository {
  final BackendApiService _apiService;
  final FirestoreService _firestoreService;

  RiderRepositoryImpl(this._apiService, this._firestoreService);

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    final firestoreTx = await _firestoreService.getTransactions('rider-1');
    if (firestoreTx.isNotEmpty) {
      return firestoreTx;
    }

    final response = await _apiService.getTransactions();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((m) => TransactionModel.fromMap(m)).toList();
    }
    return [];
  }

  @override
  Future<bool> withdrawToMoMo(double amount, String userId) async {
    final response = await _apiService.withdrawToMoMo(amount, userId);
    if (response.isSuccess && response.data != null) {
      final tx = TransactionModel.fromMap(response.data!);
      await _firestoreService.addTransaction(tx);
      return true;
    }
    return response.isSuccess;
  }
}
