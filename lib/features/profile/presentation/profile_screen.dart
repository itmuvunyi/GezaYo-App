import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_bottom_nav.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../auth/presentation/auth_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: 'GezaYo',
        userName: user?.fullName ?? 'User',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Avatar with verified badge
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryMint,
                    child: Text(
                      user?.fullName.isNotEmpty == true
                          ? user!.fullName[0]
                          : 'J',
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.check_circle,
                          color: AppColors.primary, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              user?.fullName ?? 'Jean Bosco Habimana',
              style: AppTypography.headlineMedium(),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '4.9 (124 reviews)',
                  style:
                      AppTypography.titleMedium(color: AppColors.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent Review Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.parcelBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Review', style: AppTypography.titleMedium()),
                      const RatingStars(rating: 5, iconSize: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"Always on time and handles the deliveries with great care. Highly recommended!"',
                    style:
                        AppTypography.bodyMedium(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text('— Sarah K.',
                      style:
                          AppTypography.bodySmall(color: AppColors.textMuted)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Header: PREFERENCES
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PREFERENCES',
                style: AppTypography.labelMedium(color: AppColors.textMuted),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  // Role Switcher Option
                  ListTile(
                    leading:
                        const Icon(Icons.swap_horiz, color: AppColors.primary),
                    title:
                        Text('Active Mode', style: AppTypography.titleMedium()),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.isRider == true ? 'Rider Mode' : 'Customer Mode',
                        style:
                            AppTypography.labelMedium(color: AppColors.primary),
                      ),
                    ),
                    onTap: () {
                      final newRole =
                          user?.isRider == true ? 'customer' : 'rider';
                      notifier.switchRole(newRole);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Switched to ${newRole.toUpperCase()} mode!')),
                      );
                    },
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading:
                        const Icon(Icons.language, color: AppColors.primary),
                    title: Text('Language', style: AppTypography.titleMedium()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(authState.selectedLanguage,
                            style: AppTypography.bodyMedium(
                                color: AppColors.textSecondary)),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                      ],
                    ),
                    onTap: () => context.push('/settings/language'),
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.notifications_none,
                        color: AppColors.primary),
                    title: Text('Notifications',
                        style: AppTypography.titleMedium()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.statusSuccess,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('3',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                      ],
                    ),
                    onTap: () => context.push('/settings/notifications'),
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading:
                        const Icon(Icons.security, color: AppColors.primary),
                    title: Text('Security', style: AppTypography.titleMedium()),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                    onTap: () => context.push('/settings/security'),
                  ),
                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.help_outline,
                        color: AppColors.primary),
                    title:
                        Text('Help Center', style: AppTypography.titleMedium()),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                    onTap: () => context.push('/help'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusErrorBg,
                  foregroundColor: AppColors.statusError,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await notifier.logout();
                  if (context.mounted) context.go('/auth');
                },
                icon: const Icon(Icons.logout, color: AppColors.statusError),
                label: Text(
                  'Logout',
                  style: AppTypography.labelLarge(color: AppColors.statusError),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            if (user?.isRider == true) {
              context.go('/rider');
            } else {
              context.go('/customer');
            }
          }
          if (index == 1) {
            if (user?.isRider == true) {
              context.push('/earnings');
            } else {
              context.push('/live-tracking');
            }
          }
        },
      ),
    );
  }
}
