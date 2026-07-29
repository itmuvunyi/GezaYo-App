import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/backend_api_service.dart';
import '../domain/transaction_model.dart';

final riderRepositoryProvider = Provider<RiderRepository>((ref) {
  final api = ref.watch(backendApiServiceProvider);
  return RiderRepositoryImpl(api);
});

abstract class RiderRepository {
  Future<List<TransactionModel>> fetchTransactions();
  Future<bool> withdrawToMoMo(double amount, String userId);
}

class RiderRepositoryImpl implements RiderRepository {
  final BackendApiService _apiService;

  RiderRepositoryImpl(this._apiService);

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    final response = await _apiService.getTransactions();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((m) => TransactionModel.fromMap(m)).toList();
    }
    return [];
  }

  @override
  Future<bool> withdrawToMoMo(double amount, String userId) async {
    final response = await _apiService.withdrawToMoMo(amount, userId);
    return response.isSuccess;
  }
}
