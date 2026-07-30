import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../../core/widgets/simulated_map_widget.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/presentation/auth_notifier.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final displayName = authState.user?.fullName.split(' ').first ?? 'Customer';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'GezaYo',
        userName: displayName,
        onNotificationTap: () => context.push('/notifications'),
        onAvatarTap: () => context.push('/profile'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(
                        'What are you sending today?',
                        style: AppTypography.bodyLarge(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2x2 Service Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _ServiceCard(
                      title: 'Food Delivery',
                      icon: Icons.restaurant,
                      bgColor: AppColors.foodBg,
                      iconColor: AppColors.foodIcon,
                      onTap: () => context.push('/create-delivery?type=Food'),
                    ),
                    _ServiceCard(
                      title: 'Groceries',
                      icon: Icons.shopping_cart,
                      bgColor: AppColors.groceryBg,
                      iconColor: AppColors.groceryIcon,
                      onTap: () =>
                          context.push('/create-delivery?type=Grocery'),
                    ),
                    _ServiceCard(
                      title: 'Parcels',
                      icon: Icons.inventory_2,
                      bgColor: AppColors.parcelBg,
                      iconColor: AppColors.parcelIcon,
                      onTap: () => context.push('/create-delivery?type=Parcel'),
                    ),
                    _ServiceCard(
                      title: 'Errands',
                      icon: Icons.check_circle_outline,
                      bgColor: AppColors.errandsBg,
                      iconColor: AppColors.errandsIcon,
                      onTap: () => context.push('/create-delivery?type=Other'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section Header: Nearby Riders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nearby Riders',
                      style: AppTypography.headlineMedium(
                          color: theme.colorScheme.onSurface),
                    ),
                    StatusBadge.live(),
                  ],
                ),

                const SizedBox(height: 12),

                // Map Container listening to real-time online riders
                SizedBox(
                  height: 240,
                  child: StreamBuilder<List<UserModel>>(
                    stream: firestoreService.getOnlineRidersStream(),
                    builder: (context, snapshot) {
                      final onlineRiders = snapshot.data ?? [];
                      final riderCoords = onlineRiders
                          .map((r) => LatLng(r.latitude, r.longitude))
                          .toList();

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SimulatedMapWidget(
                          riderLocations: riderCoords,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 100), // Space for floating button
              ],
            ),
          ),

          // Floating Action Button ("Send Now")
          Positioned(
            right: 20,
            bottom: 84,
            child: FloatingActionButton.extended(
              backgroundColor: const Color(0xFFB45309), // Brown/Orange accent
              onPressed: () => context.push('/create-delivery'),
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              label: Text(
                'Send Now',
                style: AppTypography.labelLarge(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.push('/live-tracking');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.titleLarge(color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}
