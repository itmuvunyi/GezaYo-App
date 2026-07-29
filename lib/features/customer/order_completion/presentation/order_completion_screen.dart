import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../presentation/delivery_notifier.dart';

class OrderCompletionScreen extends ConsumerStatefulWidget {
  const OrderCompletionScreen({super.key});

  @override
  ConsumerState<OrderCompletionScreen> createState() =>
      _OrderCompletionScreenState();
}

class _OrderCompletionScreenState extends ConsumerState<OrderCompletionScreen> {
  late ConfettiController _confettiController;
  double _selectedTip = 1000;
  int _userRating = 5;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(deliveryNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(
        title: 'GezaYo',
        userName: 'Jean-Paul',
      ),
      body: Stack(
        children: [
          // Confetti Animation Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.primaryLight,
                AppColors.accentOrange,
                Colors.blue,
              ],
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Celebration Checkmark Circle
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.statusSuccess,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x3310B981),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, size: 52, color: Colors.white),
                ),

                const SizedBox(height: 16),

                Text(
                  'Delivered!',
                  style: AppTypography.displayMedium(color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your order was delivered in 24 minutes.',
                  style:
                      AppTypography.bodyMedium(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 24),

                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long,
                              color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Order Summary',
                              style: AppTypography.titleLarge()),
                        ],
                      ),
                      const Divider(height: 24),
                      const _SummaryRow(
                        title: '2x Grilled Tilapia with Isombe',
                        amount: '12,500 RWF',
                      ),
                      const SizedBox(height: 8),
                      const _SummaryRow(
                        title: '1x Ibirayi Special Fries',
                        amount: '3,500 RWF',
                      ),
                      const SizedBox(height: 8),
                      const _SummaryRow(
                        title: 'Delivery Fee',
                        amount: '1,200 RWF',
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid',
                              style: AppTypography.headlineMedium(
                                  color: AppColors.primary)),
                          Text(
                            '17,200 RWF',
                            style: AppTypography.headlineLarge(
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2-Column Metrics (Time & Distance)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.parcelBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.access_time,
                                color: AppColors.primary),
                            const SizedBox(height: 4),
                            Text('Time', style: AppTypography.bodySmall()),
                            Text('11:42 AM', style: AppTypography.titleLarge()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.parcelBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                color: AppColors.primary),
                            const SizedBox(height: 4),
                            Text('Distance', style: AppTypography.bodySmall()),
                            Text('3.2 km', style: AppTypography.titleLarge()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Rider Rating Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryMint,
                        child: Icon(Icons.person,
                            size: 36, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text('Rate Jean-Luc', style: AppTypography.titleLarge()),
                      Text('How was your delivery service?',
                          style: AppTypography.bodyMedium(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      RatingStars(
                        rating: _userRating,
                        onRatingChanged: (stars) {
                          setState(() => _userRating = stars);
                          notifier.setRating(stars);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Tip Your Rider Container (Dotted Border container)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primaryLight,
                        width: 1.5,
                        style: BorderStyle.solid),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pan_tool_alt_outlined,
                              color: AppColors.accentOrange),
                          const SizedBox(width: 8),
                          Text('Tip your rider',
                              style: AppTypography.titleLarge()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Show some appreciation for the speed!',
                          style: AppTypography.bodyMedium(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _TipPill(
                            amountText: '500 RWF',
                            isSelected: _selectedTip == 500,
                            onTap: () => setState(() => _selectedTip = 500),
                          ),
                          _TipPill(
                            amountText: '1,000 RWF',
                            isSelected: _selectedTip == 1000,
                            onTap: () => setState(() => _selectedTip = 1000),
                          ),
                          _TipPill(
                            amountText: '2,000 RWF',
                            isSelected: _selectedTip == 2000,
                            onTap: () => setState(() => _selectedTip = 2000),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.smartphone,
                                    color: AppColors.statusSuccess),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mobile Money Pay',
                                        style: AppTypography.titleMedium()),
                                    Text('Fast & Secure',
                                        style: AppTypography.bodySmall()),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                notifier.addTip(_selectedTip);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Added ${_selectedTip.toStringAsFixed(0)} RWF tip via MoMo!')),
                                );
                              },
                              child: const Text('Add Tip',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                PrimaryButton(
                  text: 'Done',
                  icon: Icons.home,
                  onPressed: () {
                    notifier.completeAndClearOrder();
                    context.go('/customer');
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/customer');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String amount;

  const _SummaryRow({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: AppTypography.bodyMedium(color: AppColors.textPrimary)),
        Text(amount, style: AppTypography.titleMedium()),
      ],
    );
  }
}

class _TipPill extends StatelessWidget {
  final String amountText;
  final bool isSelected;
  final VoidCallback onTap;

  const _TipPill({
    required this.amountText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMint : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          amountText,
          style: AppTypography.titleMedium(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
