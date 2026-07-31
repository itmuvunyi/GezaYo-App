import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/auth_notifier.dart';
import '../../presentation/rider_notifier.dart';
import '../../../customer/domain/delivery_model.dart';

class RiderHomeScreen extends ConsumerWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riderState = ref.watch(riderNotifierProvider);
    final notifier = ref.read(riderNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final riderUid = authState.user?.uid ?? '';
    final riderName = authState.user?.fullName ?? 'Rider';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                style: AppTypography.headlineMedium(
                    color: theme.colorScheme.primary)),
          ],
        ),
        actions: [
          // ONLINE / OFFLINE Switcher Pill
          GestureDetector(
            onTap: () =>
                notifier.toggleOnlineStatus(!riderState.isOnline, riderUid),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: riderState.isOnline
                    ? AppColors.statusSuccessBg
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    riderState.isOnline ? 'ON' : 'OFF',
                    style: AppTypography.labelMedium(
                      color: riderState.isOnline
                          ? AppColors.statusSuccess
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: riderState.isOnline
                          ? AppColors.statusSuccess
                          : theme.colorScheme.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: theme.colorScheme.onSurface),
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
                          '${riderState.jobsDoneToday}',
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
                Text('Available Jobs',
                    style: AppTypography.headlineMedium(
                        color: theme.colorScheme.onSurface)),
                StatusBadge.live(),
              ],
            ),

            const SizedBox(height: 16),

            // Real-time Available Jobs from Firestore
            StreamBuilder<List<DeliveryModel>>(
              stream: firestoreService.getAvailableJobsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final jobs = snapshot.data ?? [];

                if (jobs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No available jobs right now',
                          style: AppTypography.titleLarge(
                              color: theme.colorScheme.onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'New delivery requests will appear here in real time',
                          style: AppTypography.bodySmall(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: jobs.map((job) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RiderJobCard(
                        job: job,
                        onAccept: () async {
                          final success = await notifier.acceptJob(
                            job.id,
                            job.estimatedFareRwf,
                            riderUid,
                            riderName,
                            authState.user?.rating ?? 0.0,
                          );
                          if (success && context.mounted) {
                            context.push('/job-details');
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'This job has already been accepted by another rider!'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
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
  final DeliveryModel job;
  final VoidCallback onAccept;

  const _RiderJobCard({
    required this.job,
    required this.onAccept,
  });

  Color _categoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return AppColors.foodBg;
      case 'grocery':
        return AppColors.groceryBg;
      case 'parcel':
        return AppColors.parcelBg;
      default:
        return AppColors.errandsBg;
    }
  }

  Color _categoryTextColor(String type) {
    switch (type.toLowerCase()) {
      case 'food':
        return AppColors.foodIcon;
      case 'grocery':
        return AppColors.groceryIcon;
      case 'parcel':
        return AppColors.parcelIcon;
      default:
        return AppColors.errandsIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceFormatted =
        job.estimatedFareRwf.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
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
                  color: _categoryColor(job.packageType),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.packageType.toUpperCase(),
                  style: AppTypography.labelMedium(
                      color: _categoryTextColor(job.packageType)),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(priceFormatted,
                      style: AppTypography.headlineLarge(
                          color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Text('RWF',
                      style: AppTypography.bodySmall(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(job.pickupAddress,
              style:
                  AppTypography.titleLarge(color: theme.colorScheme.onSurface)),

          const SizedBox(height: 14),

          // Route Details
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
                      Text(job.weightClass,
                          style: TextStyle(
                              fontSize: 8,
                              color: theme.colorScheme.onSurfaceVariant)),
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
                        Expanded(
                          child: Text('Pick: ${job.pickupAddress}',
                              style: AppTypography.bodyMedium(
                                  color: theme.colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis),
                        ),
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
                        Expanded(
                          child: Text('Drop: ${job.dropoffAddress}',
                              style: AppTypography.bodyMedium(
                                  color: theme.colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis),
                        ),
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
