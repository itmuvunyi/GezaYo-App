import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../presentation/rider_notifier.dart';

class DeliveryJobDetailsScreen extends ConsumerWidget {
  const DeliveryJobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(riderNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Job Details', style: AppTypography.headlineMedium()),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'RWF 4,500',
              style: AppTypography.labelLarge(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Floating Top Toast Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.statusSuccess, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Navigating to pickup...',
                  style: AppTypography.titleMedium(color: Colors.white),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Map Box
                  SizedBox(
                    height: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: const SimulatedMapWidget(showRoute: true),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Customer Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryMint,
                              child:
                                  Icon(Icons.person, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Jean-Paul N.',
                                      style: AppTypography.titleLarge()),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_border,
                                          size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('4.9 Rating',
                                          style: AppTypography.bodySmall()),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.statusSuccessBg,
                                padding: const EdgeInsets.all(10),
                              ),
                              icon: const Icon(Icons.phone,
                                  color: AppColors.primary),
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                color: AppColors.accentOrange, size: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PICKUP',
                                      style: AppTypography.labelMedium(
                                          color: AppColors.accentOrange)),
                                  Text('Inzora Rooftop Cafe',
                                      style: AppTypography.titleMedium()),
                                  Text('Kigali Cultural Village, KN 81 St',
                                      style: AppTypography.bodySmall()),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 16,
                              child: VerticalDivider(
                                  thickness: 1.5, color: AppColors.cardBorder),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                color: AppColors.statusSuccess, size: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('DROP-OFF',
                                      style: AppTypography.labelMedium(
                                          color: AppColors.statusSuccess)),
                                  Text('Norrsken House Kigali',
                                      style: AppTypography.titleMedium()),
                                  Text('KN 78 St, Town Centre',
                                      style: AppTypography.bodySmall()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PACKAGE DETAILS Card
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
                        Text('PACKAGE DETAILS',
                            style: AppTypography.labelMedium(
                                color: AppColors.textMuted)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.parcelBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.inventory_2_outlined,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hot Pastries & Coffee',
                                    style: AppTypography.titleLarge()),
                                Text('Weight: ~2.5kg • Fragile',
                                    style: AppTypography.bodySmall()),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.parcelBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: AppColors.accentOrange, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '"Please keep the bag upright. Use the side entrance at Norrsken."',
                                  style: AppTypography.bodySmall(
                                      color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PAYMENT BREAKDOWN Card
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
                        Text('PAYMENT BREAKDOWN',
                            style: AppTypography.labelMedium(
                                color: AppColors.textMuted)),
                        const SizedBox(height: 12),
                        const _FareRow(label: 'Base Fare', value: 'RWF 3,000'),
                        const SizedBox(height: 6),
                        const _FareRow(
                            label: 'Distance (4.2 km)', value: 'RWF 1,200'),
                        const SizedBox(height: 6),
                        const _FareRow(
                            label: 'Peak Hour Bonus',
                            value: '+ RWF 300',
                            isBonus: true),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Earnings',
                                    style: AppTypography.headlineMedium()),
                                Text('💳 PAID ONLINE',
                                    style: AppTypography.labelMedium(
                                        color: AppColors.statusSuccess)),
                              ],
                            ),
                            Text('RWF 4,500',
                                style: AppTypography.headlineLarge(
                                    color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Bar Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceLight,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Reject',
                    icon: Icons.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: 'Navigate to Pickup',
                    icon: Icons.send,
                    onPressed: () {
                      notifier.markPickedUp();
                      context.push('/rider-navigation');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBonus;

  const _FareRow(
      {required this.label, required this.value, this.isBonus = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium()),
        Text(
          value,
          style: AppTypography.titleMedium(
            color: isBonus ? AppColors.statusSuccess : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
