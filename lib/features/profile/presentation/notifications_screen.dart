import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/storage_service.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late bool _deliveryUpdates;
  late bool _promoOffers;
  bool _appSounds = true;

  final List<NotificationItem> _notifications = [
    const NotificationItem(
      title: 'Rider Assigned to Order #GZ-8821',
      subtitle: 'Jean Claude is on his way to Kigali Heights for pickup.',
      timeText: '5 mins ago',
      icon: Icons.two_wheeler,
      isUnread: true,
    ),
    const NotificationItem(
      title: 'Order Completed Successfully',
      subtitle: 'Your delivery to Norrsken House Kigali was completed.',
      timeText: '2 hours ago',
      icon: Icons.check_circle,
      isUnread: false,
    ),
    const NotificationItem(
      title: 'Weekend Hero Bonus Credited!',
      subtitle: 'You earned +5,000 RWF bonus for completing 10 weekend trips.',
      timeText: '1 day ago',
      icon: Icons.card_giftcard,
      isUnread: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _deliveryUpdates = storage.getNotificationsEnabled();
    _promoOffers = true;
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.read(storageServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Notifications', style: AppTypography.headlineMedium()),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n = n.copyWith(isUnread: false);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('All notifications marked as read.')),
              );
            },
            child: Text(
              'Mark All Read',
              style: AppTypography.titleMedium(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preference Controls Section
            Text(
              'NOTIFICATION PREFERENCES',
              style: AppTypography.labelMedium(color: AppColors.textMuted),
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
                  SwitchListTile(
                    activeTrackColor: AppColors.primaryLight,
                    title: Text('Delivery Status Updates',
                        style: AppTypography.titleMedium()),
                    subtitle: Text(
                        'Receive real-time push alerts for your orders',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    value: _deliveryUpdates,
                    onChanged: (val) {
                      setState(() => _deliveryUpdates = val);
                      storage.setNotificationsEnabled(val);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeTrackColor: AppColors.primaryLight,
                    title: Text('Promotions & Special Offers',
                        style: AppTypography.titleMedium()),
                    subtitle: Text(
                        'Get discount vouchers and delivery promotions',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    value: _promoOffers,
                    onChanged: (val) => setState(() => _promoOffers = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeTrackColor: AppColors.primaryLight,
                    title: Text('In-App Sounds & Vibration',
                        style: AppTypography.titleMedium()),
                    subtitle: Text('Play audio cues for new job alerts',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    value: _appSounds,
                    onChanged: (val) => setState(() => _appSounds = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Notifications Section
            Text(
              'RECENT NOTIFICATIONS',
              style: AppTypography.labelMedium(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            ..._notifications.map((item) => NotificationTile(item: item)),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String subtitle;
  final String timeText;
  final IconData icon;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.subtitle,
    required this.timeText,
    required this.icon,
    required this.isUnread,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      title: title,
      subtitle: subtitle,
      timeText: timeText,
      icon: icon,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const NotificationTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isUnread ? AppColors.primarySubtle : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isUnread ? AppColors.primaryLight : AppColors.cardBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.isUnread ? AppColors.primaryMint : AppColors.parcelBg,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTypography.titleMedium(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style:
                      AppTypography.bodyMedium(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeText,
                  style: AppTypography.bodySmall(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
