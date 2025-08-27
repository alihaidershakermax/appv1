import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../../main.dart';
import '../../../../core/localization/language_provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/language_selector.dart';
import '../widgets/theme_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader(theme, 'Account'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  subtitle: authState.user?.email ?? 'Not signed in',
                  onTap: () {
                    // TODO: Navigate to profile screen
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Subscription',
                  subtitle: 'Manage your subscription',
                  onTap: () {
                    // TODO: Navigate to subscription screen
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.analytics_outlined,
                  title: 'Usage Statistics',
                  subtitle: 'View your usage data',
                  onTap: () {
                    // TODO: Navigate to usage screen
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(theme, 'Appearance'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: _getThemeDisplayName(ref.watch(themeModeProvider)),
                  onTap: () {
                    _showThemeSelector(context, ref);
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: _getLanguageDisplayName(ref.watch(languageProvider).languageCode),
                  onTap: () {
                    _showLanguageSelector(context, ref);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // AI Settings Section
          _buildSectionHeader(theme, 'AI Settings'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.psychology_outlined,
                  title: 'AI Model',
                  subtitle: 'Choose your preferred AI model',
                  onTap: () {
                    // TODO: Navigate to AI model selection
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.tune_outlined,
                  title: 'AI Personality',
                  subtitle: 'Customize AI behavior',
                  onTap: () {
                    // TODO: Navigate to AI personality settings
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.speed_outlined,
                  title: 'Response Speed',
                  subtitle: 'Streaming vs. complete responses',
                  onTap: () {
                    // TODO: Toggle streaming responses
                  },
                  trailing: Switch(
                    value: true, // TODO: Get from provider
                    onChanged: (value) {
                      // TODO: Update streaming preference
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy & Security Section
          _buildSectionHeader(theme, 'Privacy & Security'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.history,
                  title: 'Chat History',
                  subtitle: 'Manage your conversation history',
                  onTap: () {
                    // TODO: Navigate to chat history settings
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Data Sync',
                  subtitle: 'Sync data across devices',
                  onTap: () {
                    // TODO: Toggle data sync
                  },
                  trailing: Switch(
                    value: true, // TODO: Get from provider
                    onChanged: (value) {
                      // TODO: Update sync preference
                    },
                  ),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.security_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    // TODO: Open privacy policy
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  onTap: () {
                    // TODO: Open terms of service
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader(theme, 'Support'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & FAQ',
                  subtitle: 'Get help and find answers',
                  onTap: () {
                    // TODO: Navigate to help screen
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the app',
                  onTap: () {
                    // TODO: Open feedback form
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.star_outline,
                  title: 'Rate App',
                  subtitle: 'Rate us on the app store',
                  onTap: () {
                    // TODO: Open app store rating
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.share_outlined,
                  title: 'Share App',
                  subtitle: 'Share with friends and family',
                  onTap: () {
                    // TODO: Share app
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(theme, 'About'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: '1.0.0+1', // TODO: Get from package info
                  onTap: () {
                    // TODO: Show app info
                  },
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.update_outlined,
                  title: 'Check for Updates',
                  subtitle: 'Update to the latest version',
                  onTap: () {
                    // TODO: Check for updates
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sign Out Button
          if (authState.isAuthenticated)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  _showSignOutDialog(context, ref);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'ku':
        return 'کوردی';
      default:
        return 'English';
    }
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const ThemeSelector(),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const LanguageSelector(),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}