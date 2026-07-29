import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String avatarUrl;
  final String userName;
  final bool showBackButton;
  final bool showNotification;
  final Widget? trailing;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;

  const CustomAppBar({
    super.key,
    this.title = 'GezaYo',
    this.avatarUrl = '',
    this.userName = 'User',
    this.showBackButton = false,
    this.showNotification = true,
    this.trailing,
    this.onNotificationTap,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 4),
          ] else ...[
            GestureDetector(
              onTap: onAvatarTap,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryMint,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: AppTypography.titleLarge(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            title,
            style: AppTypography.headlineMedium(color: AppColors.primary),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          if (showNotification)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined,
                      color: AppColors.textPrimary, size: 26),
                  onPressed: onNotificationTap ??
                      () => context.push('/settings/notifications'),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.statusSuccess,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
