import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_text_field.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricEnabled = true;
  bool _rememberLogin = true;

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password', style: AppTypography.headlineMedium()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Current Password',
              hintText: '••••••••',
              obscureText: true,
              controller: currentPassController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'New Password',
              hintText: '••••••••',
              obscureText: true,
              controller: newPassController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Confirm New Password',
              hintText: '••••••••',
              obscureText: true,
              controller: confirmPassController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: AppTypography.titleMedium(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (newPassController.text == confirmPassController.text &&
                  newPassController.text.isNotEmpty) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password updated successfully!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New passwords do not match.')),
                );
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.statusError),
            const SizedBox(width: 8),
            Text('Delete Account',
                style:
                    AppTypography.headlineMedium(color: AppColors.statusError)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete your GezaYo account? This action cannot be undone.',
          style: AppTypography.bodyMedium(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusError),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/auth');
            },
            child: const Text('Delete Permanently',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title:
            Text('Security & Privacy', style: AppTypography.headlineMedium()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Login & Authentication Settings
            Text(
              'AUTHENTICATION SETTINGS',
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
                  ListTile(
                    leading: const Icon(Icons.lock_outline,
                        color: AppColors.primary),
                    title: Text('Change Password',
                        style: AppTypography.titleMedium()),
                    subtitle: Text('Update your account password',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeTrackColor: AppColors.primaryLight,
                    secondary: const Icon(Icons.verified_user_outlined,
                        color: AppColors.primary),
                    title: Text('Two-Factor Authentication (2FA)',
                        style: AppTypography.titleMedium()),
                    subtitle: Text('Require SMS code on unknown logins',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    value: _twoFactorEnabled,
                    onChanged: (val) => setState(() => _twoFactorEnabled = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeTrackColor: AppColors.primaryLight,
                    secondary:
                        const Icon(Icons.fingerprint, color: AppColors.primary),
                    title: Text('Biometric / Fingerprint Lock',
                        style: AppTypography.titleMedium()),
                    subtitle: Text('Unlock app using device biometrics',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    value: _biometricEnabled,
                    onChanged: (val) => setState(() => _biometricEnabled = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    activeTrackColor: AppColors.primaryLight,
                    secondary:
                        const Icon(Icons.remember_me, color: AppColors.primary),
                    title: Text('Remember Login State',
                        style: AppTypography.titleMedium()),
                    subtitle: Text('Stay signed in automatically on startup',
                        style: AppTypography.bodySmall(
                            color: AppColors.textSecondary)),
                    value: _rememberLogin,
                    onChanged: (val) => setState(() => _rememberLogin = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active Sessions
            Text(
              'ACTIVE SESSIONS',
              style: AppTypography.labelMedium(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.smartphone,
                      color: AppColors.statusSuccess, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kigali Mobile Device (This Phone)',
                            style: AppTypography.titleMedium()),
                        Text('Active Now • Android App v1.0.0',
                            style: AppTypography.bodySmall(
                                color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Danger Zone Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusErrorBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.statusError.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DANGER ZONE',
                      style: AppTypography.labelMedium(
                          color: AppColors.statusError)),
                  const SizedBox(height: 6),
                  Text(
                    'Permanently remove your account and erase personal delivery history.',
                    style:
                        AppTypography.bodySmall(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: 'Delete Account',
                    backgroundColor: AppColors.statusError,
                    onPressed: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
