import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../domain/rider_model.dart';
import '../../presentation/delivery_notifier.dart';

class RiderMatchingScreen extends ConsumerWidget {
  const RiderMatchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryNotifierProvider);
    final notifier = ref.read(deliveryNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'GezaYo',
        userName: 'Jean-Paul',
      ),
      body: Stack(
        children: [
          // Upper Radar Map Canvas
          const Positioned.fill(
            child: SimulatedMapWidget(
              showRiderPins: true,
              showRadarScan: true,
              centerLabel: '5 nearby in Kigali City',
            ),
          ),

          // Bottom Sheet Content overlay
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, -4)),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Handle Bar Indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Auto-assign vs Select Manually Toggle
                    Row(
                      children: [
                        Expanded(
                          child: _ModeToggleButton(
                            label: '⚡ Auto-assign',
                            isSelected: deliveryState.isAutoAssign,
                            onTap: () {
                              notifier.toggleAssignMode(true);
                              // Auto assign first rider
                              if (deliveryState.availableRiders.isNotEmpty) {
                                notifier.selectRider(
                                    deliveryState.availableRiders.first);
                                context.push('/live-tracking');
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModeToggleButton(
                            label: '👆 Select Manually',
                            isSelected: !deliveryState.isAutoAssign,
                            onTap: () => notifier.toggleAssignMode(false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text('Available Drivers Nearby',
                        style: AppTypography.headlineMedium()),

                    const SizedBox(height: 12),

                    // Rider Cards List
                    ...deliveryState.availableRiders.map((rider) {
                      return _RiderCardTile(
                        rider: rider,
                        onTap: () {
                          notifier.selectRider(rider);
                          context.push('/live-tracking');
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/customer');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.parcelBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelLarge(
            color: isSelected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _RiderCardTile extends StatelessWidget {
  final RiderModel rider;
  final VoidCallback onTap;

  const _RiderCardTile({
    required this.rider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Rider Avatar with rating badge
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primarySubtle,
                child: Text(
                  rider.name[0],
                  style: AppTypography.headlineMedium(color: AppColors.primary),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${rider.rating}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.star, size: 10, color: Colors.amber),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rider.name, style: AppTypography.titleLarge()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrangeLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        rider.etaText,
                        style: AppTypography.labelMedium(
                            color: AppColors.accentOrangeDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${rider.vehicleType} • ${rider.completedJobs} Completed',
                  style:
                      AppTypography.bodySmall(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textMuted),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}
