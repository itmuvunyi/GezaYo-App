import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_notifier.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController(text: '788 000 000');
  final _emailController = TextEditingController(text: 'user@gezayo.rw');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController(text: 'Jean-Paul');

  bool _isPhoneMode = true;
  bool _showToast = false;
  String _selectedRole = 'customer'; // 'customer' or 'rider'

  void _triggerToast() {
    setState(() => _showToast = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showToast = false);
    });
  }

  Future<void> _handleAuth() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    bool success = false;

    if (_isPhoneMode) {
      _triggerToast();
      success = await notifier.signUpWithPhone(
        '+250 ${_phoneController.text}',
        _nameController.text,
        _selectedRole,
      );
    } else {
      success = await notifier.loginWithEmail(
        _emailController.text,
        _passwordController.text,
      );
    }

    if (success && mounted) {
      if (_selectedRole == 'rider') {
        context.go('/rider');
      } else {
        context.go('/customer');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48), // space for top toast

                  // Top Header with Logo & Language Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logos/logo.png',
                            width: 32,
                            height: 32,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.bolt,
                                    color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text('GezaYo',
                              style: AppTypography.headlineMedium(
                                  color: AppColors.primary)),
                        ],
                      ),

                      // Language Dropdown Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.parcelBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.language,
                                size: 16, color: AppColors.textPrimary),
                            const SizedBox(width: 4),
                            Text(
                              authState.selectedLanguage,
                              style: AppTypography.titleMedium(
                                  color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Hero Banner Card
                  Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF046A38), Color(0xFF10B981)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pedal_bike,
                              size: 48, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            'Swift & Reliable Delivery',
                            style:
                                AppTypography.titleLarge(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Agility in Motion',
                    style: AppTypography.displayMedium(
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details to get started with Rwanda\'s fastest delivery service.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(
                        color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 24),

                  // Role Selector Switcher (Customer vs Rider)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRole = 'customer'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'customer'
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Customer Mode',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge(
                                  color: _selectedRole == 'customer'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRole = 'rider'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'rider'
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Rider Mode',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge(
                                  color: _selectedRole == 'rider'
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Phone vs Email Auth Mode Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            setState(() => _isPhoneMode = !_isPhoneMode),
                        child: Text(
                          _isPhoneMode
                              ? 'Use Email / Password'
                              : 'Use Phone Number',
                          style: AppTypography.titleMedium(
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),

                  if (_isPhoneMode) ...[
                    AppTextField(
                      label: 'Phone Number',
                      hintText: '788 000 000',
                      prefixText: '+250',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ] else ...[
                    AppTextField(
                      label: 'Email Address',
                      hintText: 'user@gezayo.rw',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Password',
                      hintText: '••••••••',
                      obscureText: true,
                      controller: _passwordController,
                    ),
                  ],

                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: _isPhoneMode ? 'Send OTP' : 'Sign In',
                    icon: Icons.arrow_forward,
                    isLoading: authState.isLoading,
                    onPressed: _handleAuth,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: AppTypography.labelMedium(
                              color: AppColors.textMuted),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Social Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final success = await ref
                                .read(authNotifierProvider.notifier)
                                .signInWithGoogle();
                            if (!context.mounted) return;
                            if (success) context.go('/customer');
                          },
                          icon: const Icon(Icons.g_mobiledata,
                              size: 28, color: Colors.deepOrange),
                          label: const Text('Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.facebook,
                              size: 22, color: Colors.blue),
                          label: const Text('Facebook'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),

            // Top Floating Toast Banner (Matching prototype top toast)
            if (_showToast)
              Positioned(
                top: 16,
                left: 24,
                right: 24,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF1E293B),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.statusSuccess, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'OTP Sent Successfully!',
                          style: AppTypography.titleMedium(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
