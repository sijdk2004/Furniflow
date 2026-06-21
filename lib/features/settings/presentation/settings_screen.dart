import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../main.dart'; // For themeModeProvider

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader(context, 'Account'),
          _buildSettingsTile(
            context,
            icon: LucideIcons.user,
            title: 'Profile Information',
            subtitle: 'Update your personal details and avatar',
            onTap: () => context.go('/settings/profile'),
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.lock,
            title: 'Security',
            subtitle: 'Change your password and secure your account',
            onTap: () => context.go('/settings/security'),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Preferences'),
          _buildSettingsTile(
            context,
            icon: LucideIcons.bell,
            title: 'Notifications',
            subtitle: 'Available in Phase 2',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications will be available in Phase 2')));
            },
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.moon,
            title: 'Appearance',
            subtitle: 'Switch between light and dark themes',
            onTap: () {
              final isDarkMode = ref.read(themeModeProvider) == ThemeMode.dark;
              ref.read(themeModeProvider.notifier).toggle(!isDarkMode);
            },
          ),
          _buildSettingsTile(
            context,
            icon: LucideIcons.globe,
            title: 'Language & Region',
            subtitle: 'Available in Phase 2',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language & Region will be available in Phase 2')));
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'System'),
          _buildSettingsTile(
            context,
            icon: LucideIcons.info,
            title: 'About',
            subtitle: 'System version, licenses, and documentation',
            onTap: () => context.go('/settings/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        trailing: const Icon(LucideIcons.chevronRight, size: 20),
        onTap: onTap,
      ),
    );
  }
}
