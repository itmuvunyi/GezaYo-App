import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/phone_helper.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../customer/domain/delivery_model.dart';
import '../../presentation/delivery_notifier.dart';

class LiveTrackingScreen extends ConsumerWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryNotifierProvider);
    final delivery = deliveryState.activeDelivery;
    final theme = Theme.of(context);

    final isSearching = delivery?.status == DeliveryStatus.searching;
    final isAssigned = delivery?.status == DeliveryStatus.assigned;
    final isPickedUp = delivery?.status == DeliveryStatus.pickedUp;
    final isDelivered = delivery?.status == DeliveryStatus.delivered;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Track Order',
            style: AppTypography.headlineMedium(
                color: theme.colorScheme.onSurface)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: delivery == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_outlined,
                        size: 64, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Delivery to Track',
                      style: AppTypography.headlineMedium(
                          color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You do not have an active order in progress. Request a new delivery to view live GPS tracking.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push('/create-delivery'),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Create New Delivery',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                // Map View
                const Positioned.fill(
                  child: SimulatedMapWidget(
                    showRoute: true,
                  ),
                ),


          // Floating ESTIMATED ARRIVAL Card Top
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDelivered
                                ? 'DELIVERY COMPLETE'
                                : 'ESTIMATED ARRIVAL',
                            style: AppTypography.labelMedium(
                                color: isDelivered
                                    ? AppColors.statusSuccess
                                    : AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                isDelivered
                                    ? '0'
                                    : '${delivery.estimatedArrivalMins}',
                                style: AppTypography.displayMedium(
                                    color: theme.colorScheme.onSurface),
                              ),

                              const SizedBox(width: 4),
                              Text('mins',
                                  style: AppTypography.titleLarge(
                                      color: theme.colorScheme.onSurface)),
                            ],
                          ),
                        ],
                      ),
                      if (isDelivered)
                        const StatusBadge(
                          text: 'Delivered',
                          backgroundColor: AppColors.statusSuccessBg,
                          textColor: AppColors.statusSuccess,
                        )
                      else if (isPickedUp)
                        StatusBadge.onTheWay()
                      else
                        StatusBadge.searching(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Horizontal 4-Step Stepper (Dynamic from Firestore)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StepItem(
                        title: 'Ordered',
                        isDone: !isSearching,
                        isActive: isSearching,
                      ),
                      _StepItem(
                        title: 'Picked up',
                        isDone: isPickedUp || isDelivered,
                        isActive: isAssigned,
                      ),
                      _StepItem(
                        title: 'On the way',
                        isDone: isDelivered,
                        isActive: isPickedUp,
                      ),
                      _StepItem(
                        title: 'Confirm',
                        isDone: false,
                        isActive: isDelivered,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Rider Info Card Bottom Overlay
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 12),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Rider Photo Avatar
                      const Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryMint,
                            child: Icon(Icons.person,
                                size: 36, color: AppColors.primary),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Icon(Icons.verified,
                                color: AppColors.primary, size: 18),
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Rider Name & Rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                final riderName = delivery.assignedRiderName;
                                final riderRating = delivery.assignedRiderRating;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (riderName != null && riderName.isNotEmpty)
                                          ? riderName
                                          : 'Rider Accepted',
                                      style: AppTypography.titleLarge(
                                          color: theme.colorScheme.onSurface),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${riderRating > 0 ? riderRating : 5.0}',
                                          style: AppTypography.bodySmall(
                                              color: AppColors.accentOrangeDark),
                                        ),

                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Quick Call Button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: const Icon(Icons.phone, color: Colors.white),
                        onPressed: () {
                          final phone = delivery.assignedRiderPhone;
                          final validPhone = (phone != null && phone.isNotEmpty)
                              ? phone
                              : '+250788123456';
                          PhoneHelper.makePhoneCall(context, validPhone);
                        },
                      ),


                    ],
                  ),

                  const SizedBox(height: 14),

                  // Dynamic Delivery Confirmation Banner & Action Button
                  if (isDelivered) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusSuccessBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.statusSuccess, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Rider completed delivery! Please confirm below.',
                              style: AppTypography.bodySmall(
                                  color: AppColors.statusSuccess),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusSuccess,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final activeDelivery = deliveryState.activeDelivery;
                          if (activeDelivery != null) {
                            await ref
                                .read(deliveryNotifierProvider.notifier)
                                .clearActiveDelivery(activeDelivery.id);
                          }
                          if (context.mounted) {
                            context.go('/customer');
                          }
                        },
                        child: Text('Confirm Delivery & Complete',
                            style: AppTypography.labelLarge(
                                color: Colors.white)),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => context.push('/order-completion'),
                        child: Text(
                          isPickedUp
                              ? 'Order In Transit...'
                              : 'Confirm Delivery',
                          style: AppTypography.labelLarge(
                              color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
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

class _StepItem extends StatelessWidget {
  final String title;
  final bool isDone;
  final bool isActive;

  const _StepItem({
    required this.title,
    this.isDone = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.statusSuccess
                : (isActive ? AppColors.primary : AppColors.cardBorder),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : (isActive
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTypography.bodySmall(
            color: isDone || isActive
                ? AppColors.primary
                : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
