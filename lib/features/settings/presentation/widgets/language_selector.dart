import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/language_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentLocale = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Language',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred language',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          
          // English Option
          _LanguageOption(
            languageCode: 'en',
            title: 'English',
            nativeName: 'English',
            icon: Icons.language,
            isSelected: currentLocale.languageCode == 'en',
            onTap: () {
              ref.read(languageProvider.notifier).setLanguage(const Locale('en'));
              Navigator.of(context).pop();
            },
          ),
          
          const SizedBox(height: 8),
          
          // Arabic Option
          _LanguageOption(
            languageCode: 'ar',
            title: 'Arabic',
            nativeName: 'العربية',
            icon: Icons.translate,
            isSelected: currentLocale.languageCode == 'ar',
            onTap: () {
              ref.read(languageProvider.notifier).setLanguage(const Locale('ar'));
              Navigator.of(context).pop();
            },
          ),
          
          const SizedBox(height: 8),
          
          // Kurdish Option
          _LanguageOption(
            languageCode: 'ku',
            title: 'Kurdish',
            nativeName: 'کوردی',
            icon: Icons.translate_outlined,
            isSelected: currentLocale.languageCode == 'ku',
            onTap: () {
              ref.read(languageProvider.notifier).setLanguage(const Locale('ku'));
              Navigator.of(context).pop();
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String languageCode;
  final String title;
  final String nativeName;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.languageCode,
    required this.title,
    required this.nativeName,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.05)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : null,
                    ),
                  ),
                  if (nativeName != title)
                    Text(
                      nativeName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}