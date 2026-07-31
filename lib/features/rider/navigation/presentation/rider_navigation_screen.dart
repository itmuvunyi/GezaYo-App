import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/phone_helper.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../../customer/domain/delivery_model.dart';
import '../../presentation/rider_notifier.dart';

class RiderNavigationScreen extends ConsumerStatefulWidget {
  const RiderNavigationScreen({super.key});

  @override
  ConsumerState<RiderNavigationScreen> createState() =>
      _RiderNavigationScreenState();
}

class _RiderNavigationScreenState
    extends ConsumerState<RiderNavigationScreen> {
  bool _isPickedUp = false;

  @override
  Widget build(BuildContext context) {
    final riderState = ref.watch(riderNotifierProvider);
    final notifier = ref.read(riderNotifierProvider.notifier);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final theme = Theme.of(context);
    final jobId = riderState.activeJobId ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: StreamBuilder<DeliveryModel?>(
        stream: firestoreService.getDeliveryStream(jobId),
        builder: (context, snapshot) {
          final job = snapshot.data;
          final pickupAddress = job?.pickupAddress ?? 'Kigali City Center';
          final dropoffAddress = job?.dropoffAddress ?? 'Nyarutarama, Kigali';
          final customerPhone = (job?.customerPhone != null && job!.customerPhone!.isNotEmpty)
              ? job.customerPhone!
              : '+250788123456';

          return Stack(
            children: [
              // Simulated Live GPS Map
              const Positioned.fill(
                child: SimulatedMapWidget(showRoute: true),
              ),

              // Top Turn Instruction Card
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.turn_right_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isPickedUp
                                  ? 'Head to Dropoff Location'
                                  : 'Head to Pickup Location',
                              style: AppTypography.headlineMedium(
                                  color: Colors.white),
                            ),
                            Text(
                              _isPickedUp ? dropoffAddress : pickupAddress,
                              style: AppTypography.bodyMedium(
                                  color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Step Action Drawer Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, -4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag Handle Line
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Customer Contact Quick Row
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryMint,
                            child: Icon(Icons.person,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Call Customer',
                                    style: AppTypography.titleMedium(
                                        color: theme.colorScheme.onSurface)),
                                Text(
                                  _isPickedUp ? 'Dropoff Stop' : 'Pickup Stop',
                                  style: AppTypography.bodySmall(
                                    color: _isPickedUp
                                        ? AppColors.statusSuccess
                                        : AppColors.accentOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.parcelBg,
                              padding: const EdgeInsets.all(10),
                            ),
                            icon: const Icon(Icons.phone,
                                color: AppColors.primary),
                            onPressed: () => PhoneHelper.makePhoneCall(
                                context, customerPhone),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Destination Card Summary
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isPickedUp ? Icons.location_on : Icons.storefront,
                              color: _isPickedUp
                                  ? AppColors.statusSuccess
                                  : AppColors.accentOrange,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPickedUp ? 'DROP OFF' : 'PICKUP STOP',
                                    style: AppTypography.labelMedium(
                                      color: _isPickedUp
                                          ? AppColors.statusSuccess
                                          : AppColors.accentOrange,
                                    ),
                                  ),
                                  Text(
                                    _isPickedUp ? dropoffAddress : pickupAddress,
                                    style: AppTypography.titleMedium(
                                        color: theme.colorScheme.onSurface),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sequential Action Button
                      if (!_isPickedUp)
                        PrimaryButton(
                          text: 'Confirm Package Picked Up',
                          icon: Icons.inventory,
                          onPressed: () {
                            setState(() {
                              _isPickedUp = true;
                            });
                            notifier.markPickedUp();
                          },
                        )
                      else
                        PrimaryButton(
                          text: 'Complete Delivery',
                          icon: Icons.check_circle_outline,
                          backgroundColor: AppColors.statusSuccess,
                          onPressed: () async {
                            await notifier.completeCurrentJob();
                            if (mounted) {
                              context.go('/rider');
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
