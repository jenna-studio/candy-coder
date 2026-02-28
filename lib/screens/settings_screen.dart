import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../theme/candy_theme.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../models/user.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatelessWidget {
  final User? user;

  const SettingsScreen({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section
            _SettingsSection(
              title: l10n.profile,
              icon: Icons.person,
              children: [
                if (user != null)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: CandyColors.pink,
                      backgroundImage: user!.avatar.isNotEmpty
                          ? (user!.avatar.startsWith('http')
                              ? NetworkImage(user!.avatar) as ImageProvider
                              : (File(user!.avatar).existsSync()
                                  ? FileImage(File(user!.avatar))
                                  : null))
                          : null,
                      child: user!.avatar.isEmpty ||
                              (!user!.avatar.startsWith('http') &&
                                  !File(user!.avatar).existsSync())
                          ? Text(
                              user!.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(user!.name),
                    subtitle: Text('${user!.points} ${l10n.points}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileEditScreen(user: user!),
                        ),
                      );

                      // Trigger rebuild if profile was updated
                      if (result == true && context.mounted) {
                        // The main screen will handle reloading
                        Navigator.of(context).pop(true);
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Language Settings Section
            _SettingsSection(
              title: l10n.languageSettings,
              icon: Icons.language,
              children: [
                Consumer<LocaleProvider>(
                  builder: (context, localeProvider, child) {
                    return ListTile(
                      leading: const Icon(Icons.translate),
                      title: Text(l10n.selectLanguage),
                      subtitle: Text(
                        localeProvider.locale.languageCode == 'ko'
                            ? l10n.korean
                            : l10n.english,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showLanguageDialog(context, localeProvider, l10n);
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About Section
            _SettingsSection(
              title: 'About',
              icon: Icons.info_outline,
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite, color: CandyColors.pink),
                  title: const Text('Candy Coder'),
                  subtitle: const Text('Version 1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocaleProvider localeProvider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.english),
                trailing: localeProvider.locale.languageCode == 'en'
                    ? const Icon(Icons.check, color: CandyColors.blue)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('en'));
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.languageChanged),
                      duration: const Duration(seconds: 2),
                      backgroundColor: CandyColors.blue,
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.korean),
                trailing: localeProvider.locale.languageCode == 'ko'
                    ? const Icon(Icons.check, color: CandyColors.blue)
                    : null,
                onTap: () {
                  localeProvider.setLocale(const Locale('ko'));
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.languageChanged),
                      duration: const Duration(seconds: 2),
                      backgroundColor: CandyColors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: CandyColors.textLight),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: CandyColors.textLight,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Container(
          decoration: CandyTheme.cardDecoration,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
