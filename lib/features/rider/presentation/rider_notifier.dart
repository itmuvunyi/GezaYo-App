import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firestore_service.dart';
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
    this.totalBalanceRwf = 0.0,
    this.earnedTodayRwf = 0.0,
    this.jobsDoneToday = 0,
    this.activeJobId,
    this.transactions = const [],
    this.isLoading = false,
  });

  // Convenience Aliases for UI & Tests
  double get todayEarningsRwf => earnedTodayRwf;
  int get jobsCompletedCount => jobsDoneToday;

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
  final firestore = ref.watch(firestoreServiceProvider);
  return RiderNotifier(repo, firestore);
});

class RiderNotifier extends StateNotifier<RiderState> {
  final RiderRepository _repository;
  final FirestoreService _firestoreService;

  RiderNotifier(this._repository, this._firestoreService)
      : super(const RiderState()) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txs = await _repository.fetchTransactions();
    state = state.copyWith(transactions: txs);
  }

  void toggleOnlineStatus(bool online, [String riderUid = 'rider-1']) {
    state = state.copyWith(isOnline: online);
    _firestoreService.updateOnlineStatus(riderUid, online);
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
