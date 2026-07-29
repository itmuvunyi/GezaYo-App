import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/transaction_model.dart';
import '../data/rider_repository.dart';

class RiderState {
  final bool isOnline;
  final double totalBalanceRwf;
  final double earnedTodayRwf;
  final int jobsDoneToday;
  final String? activeJobId;
  final List<TransactionModel> transactions;
  final bool isLoading;

  const RiderState({
    this.isOnline = true,
    this.totalBalanceRwf = 42500.0,
    this.earnedTodayRwf = 18200.0,
    this.jobsDoneToday = 14,
    this.activeJobId,
    this.transactions = const [],
    this.isLoading = false,
  });

  RiderState copyWith({
    bool? isOnline,
    double? totalBalanceRwf,
    double? earnedTodayRwf,
    int? jobsDoneToday,
    String? activeJobId,
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool clearActiveJob = false,
  }) {
    return RiderState(
      isOnline: isOnline ?? this.isOnline,
      totalBalanceRwf: totalBalanceRwf ?? this.totalBalanceRwf,
      earnedTodayRwf: earnedTodayRwf ?? this.earnedTodayRwf,
      jobsDoneToday: jobsDoneToday ?? this.jobsDoneToday,
      activeJobId: clearActiveJob ? null : (activeJobId ?? this.activeJobId),
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final riderNotifierProvider =
    StateNotifierProvider<RiderNotifier, RiderState>((ref) {
  final repo = ref.watch(riderRepositoryProvider);
  return RiderNotifier(repo);
});

class RiderNotifier extends StateNotifier<RiderState> {
  final RiderRepository _repository;

  RiderNotifier(this._repository) : super(const RiderState()) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txs = await _repository.fetchTransactions();
    if (txs.isNotEmpty) {
      state = state.copyWith(transactions: txs);
    } else {
      state = state.copyWith(
        transactions: const [
          TransactionModel(
            id: 'tx-101',
            title: 'Delivery #GZ-8821',
            dateText: 'Today, 11:42 AM',
            amountRwf: 4500,
            type: TransactionType.jobEarning,
            status: TransactionStatus.completed,
          ),
          TransactionModel(
            id: 'tx-102',
            title: 'Withdrawal to MTN MoMo',
            dateText: 'Yesterday, 4:15 PM',
            amountRwf: 10000,
            type: TransactionType.withdrawal,
            status: TransactionStatus.completed,
          ),
        ],
      );
    }
  }

  void toggleOnlineStatus(bool online) {
    state = state.copyWith(isOnline: online);
  }

  void acceptJob(String jobId, double fareRwf) {
    state = state.copyWith(activeJobId: jobId);
  }

  void markPickedUp() {}

  void completeCurrentJob(double fareRwf) {
    final updatedBalance = state.totalBalanceRwf + fareRwf;
    final updatedToday = state.earnedTodayRwf + fareRwf;
    final updatedJobs = state.jobsDoneToday + 1;

    final newTx = TransactionModel(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: 'Delivery #${state.activeJobId ?? 'GZ-8821'}',
      dateText: 'Just now',
      amountRwf: fareRwf,
      type: TransactionType.jobEarning,
      status: TransactionStatus.completed,
    );

    state = state.copyWith(
      totalBalanceRwf: updatedBalance,
      earnedTodayRwf: updatedToday,
      jobsDoneToday: updatedJobs,
      clearActiveJob: true,
      transactions: [newTx, ...state.transactions],
    );
  }

  Future<bool> withdrawToMoMo(double amount) async {
    if (amount <= 0 || amount > state.totalBalanceRwf) {
      return false;
    }

    state = state.copyWith(isLoading: true);
    final success = await _repository.withdrawToMoMo(amount, 'rider-1');

    if (success) {
      final updatedBalance = state.totalBalanceRwf - amount;
      final newTx = TransactionModel(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        title: 'Withdrawal to MTN MoMo',
        dateText: 'Just now',
        amountRwf: amount,
        type: TransactionType.withdrawal,
        status: TransactionStatus.completed,
      );

      state = state.copyWith(
        totalBalanceRwf: updatedBalance,
        transactions: [newTx, ...state.transactions],
        isLoading: false,
      );
      return true;
    }

    state = state.copyWith(isLoading: false);
    return false;
  }
}
