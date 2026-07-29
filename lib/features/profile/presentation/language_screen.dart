import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/presentation/auth_notifier.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  final List<_LanguageItem> _languages = const [
    _LanguageItem(name: 'English', nativeName: 'English (US/UK)', code: 'en'),
    _LanguageItem(name: 'Kinyarwanda', nativeName: 'Ikinyarwanda', code: 'rw'),
    _LanguageItem(name: 'Français', nativeName: 'French', code: 'fr'),
    _LanguageItem(name: 'Kiswahili', nativeName: 'Swahili', code: 'sw'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final selectedLang = authState.selectedLanguage;
    final notifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('App Language', style: AppTypography.headlineMedium()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your preferred language. Changes apply across the entire app.',
              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: List.generate(_languages.length, (index) {
                  final item = _languages[index];
                  final isSelected = selectedLang == item.name;
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {
                          notifier.setLanguage(item.name);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Language set to ${item.name}!'),
                            ),
                          );
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryMint
                                : AppColors.parcelBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.language,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: AppTypography.titleLarge(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          item.nativeName,
                          style: AppTypography.bodySmall(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : const Icon(Icons.radio_button_unchecked,
                                color: AppColors.cardBorder),
                      ),
                      if (index < _languages.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageItem {
  final String name;
  final String nativeName;
  final String code;

  const _LanguageItem({
    required this.name,
    required this.nativeName,
    required this.code,
  });
}
