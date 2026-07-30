import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/firestore_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final firestore = ref.watch(firestoreServiceProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.headlineMedium(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestore.getNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(color: theme.colorScheme.primary),
            );
          }

          final notificationsData = snapshot.data ?? [];

          if (notificationsData.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.notifications_off_outlined,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No Notifications Yet',
                      style: AppTypography.headlineMedium(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Real-time updates regarding your delivery orders and transactions will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECENT NOTIFICATIONS',
                  style: AppTypography.labelMedium(color: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                ...notificationsData.map((data) => NotificationTile(
                      item: NotificationItem(
                        title: data['title'] ?? 'Notification',
                        subtitle: data['subtitle'] ?? '',
                        timeText: data['timeText'] ?? 'Just now',
                        isUnread: data['isUnread'] ?? false,
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final String title;
  final String subtitle;
  final String timeText;
  final bool isUnread;

  const NotificationItem({
    required this.title,
    required this.subtitle,
    required this.timeText,
    required this.isUnread,
  });
}

class NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const NotificationTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isUnread
            ? theme.colorScheme.primaryContainer
            : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isUnread
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.isUnread
                  ? theme.colorScheme.primaryContainer
                  : AppColors.parcelBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active,
                color: theme.colorScheme.primary, size: 20),
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
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (item.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: AppTypography.bodyMedium(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
