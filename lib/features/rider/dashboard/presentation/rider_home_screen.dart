import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../presentation/rider_notifier.dart';

class RiderHomeScreen extends ConsumerWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riderState = ref.watch(riderNotifierProvider);
    final notifier = ref.read(riderNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryMint,
                child: Icon(Icons.person, color: AppColors.primary, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            Text('GezaYo',
                style: AppTypography.headlineMedium(color: AppColors.primary)),
          ],
        ),
        actions: [
          // ONLINE / OFFLINE Switcher Pill
          GestureDetector(
            onTap: () => notifier.toggleOnlineStatus(!riderState.isOnline),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: riderState.isOnline
                    ? AppColors.statusSuccessBg
                    : AppColors.cardBorder,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    riderState.isOnline ? 'ON' : 'OFF',
                    style: AppTypography.labelMedium(
                      color: riderState.isOnline
                          ? AppColors.statusSuccess
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: riderState.isOnline
                          ? AppColors.statusSuccess
                          : AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.notifications_none,
                color: AppColors.textPrimary),
            onPressed: () => context.push('/settings/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats Grid (2 Cards)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errandsBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EARNED TODAY',
                            style: AppTypography.labelMedium(
                                color: AppColors.errandsIcon)),
                        const SizedBox(height: 4),
                        Text(
                          '${riderState.earnedTodayRwf.toStringAsFixed(0)} RWF',
                          style: AppTypography.headlineLarge(
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errandsBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JOBS DONE',
                            style: AppTypography.labelMedium(
                                color: AppColors.errandsIcon)),
                        const SizedBox(height: 4),
                        Text(
                          '0${riderState.jobsDoneToday}',
                          style: AppTypography.headlineLarge(
                              color: AppColors.errandsIcon),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section Header: Available Jobs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Jobs', style: AppTypography.headlineMedium()),
                StatusBadge.live(),
              ],
            ),

            const SizedBox(height: 16),

            // Available Job Cards List
            _RiderJobCard(
              categoryTag: 'FOOD DELIVERY',
              categoryColor: AppColors.foodBg,
              categoryTextColor: AppColors.foodIcon,
              title: 'Kigali Heights Mall',
              distance: '1.2 km away',
              priceRwf: '1,200',
              pickLocation: 'Kigali Heights',
              dropLocation: 'Kimihurura',
              estimatedMins: '15 min est.',
              onAccept: () {
                notifier.acceptJob('GZ-8821', 1200);
                context.push('/job-details');
              },
            ),

            const SizedBox(height: 16),

            _RiderJobCard(
              categoryTag: 'PACKAGE PICKUP',
              categoryColor: AppColors.parcelBg,
              categoryTextColor: AppColors.parcelIcon,
              title: 'M. Peace Plaza',
              distance: '0.5 km away',
              priceRwf: '2,500',
              pickLocation: 'CBD Area',
              dropLocation: 'Nyarutarama',
              estimatedMins: '28 min est.',
              onAccept: () {
                notifier.acceptJob('GZ-8794', 2500);
                context.push('/job-details');
              },
            ),

            const SizedBox(height: 16),

            _RiderJobCard(
              categoryTag: 'URGENT',
              categoryColor: AppColors.statusErrorBg,
              categoryTextColor: AppColors.statusError,
              title: 'Inzora Rooftop Cafe',
              distance: '2.8 km away',
              priceRwf: '3,800',
              pickLocation: 'Inzora Cafe',
              dropLocation: 'Kicukiro',
              estimatedMins: '22 min est.',
              onAccept: () {
                notifier.acceptJob('GZ-9900', 3800);
                context.push('/job-details');
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/earnings');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }
}

class _RiderJobCard extends StatelessWidget {
  final String categoryTag;
  final Color categoryColor;
  final Color categoryTextColor;
  final String title;
  final String distance;
  final String priceRwf;
  final String pickLocation;
  final String dropLocation;
  final String estimatedMins;
  final VoidCallback onAccept;

  const _RiderJobCard({
    required this.categoryTag,
    required this.categoryColor,
    required this.categoryTextColor,
    required this.title,
    required this.distance,
    required this.priceRwf,
    required this.pickLocation,
    required this.dropLocation,
    required this.estimatedMins,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  categoryTag,
                  style: AppTypography.labelMedium(color: categoryTextColor),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(priceRwf,
                      style: AppTypography.headlineLarge(
                          color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Text('RWF',
                      style: AppTypography.bodySmall(
                          color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(title, style: AppTypography.titleLarge()),
          Text(distance,
              style: AppTypography.bodySmall(color: AppColors.textSecondary)),

          const SizedBox(height: 14),

          // Route Details with map preview image placeholder
          Row(
            children: [
              Container(
                width: 70,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.parcelBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.two_wheeler,
                          size: 20, color: AppColors.primary),
                      Text(estimatedMins,
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.circle,
                            color: AppColors.accentOrange, size: 10),
                        const SizedBox(width: 8),
                        Text('Pick: $pickLocation',
                            style: AppTypography.bodyMedium()),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: SizedBox(
                        height: 12,
                        child: VerticalDivider(
                            thickness: 1, color: AppColors.cardBorder),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.circle,
                            color: AppColors.statusSuccess, size: 10),
                        const SizedBox(width: 8),
                        Text('Drop: $dropLocation',
                            style: AppTypography.bodyMedium()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onAccept,
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              label: const Text('Accept Job',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
