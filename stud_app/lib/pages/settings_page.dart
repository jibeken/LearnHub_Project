import 'package:flutter/material.dart';
import '../app.dart';
import '../core/theme.dart';
import '../core/strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeNotifier, languageNotifier]),
      builder: (context, _) {
        final c = context.colors;
        final s = context.s;
        return Scaffold(
          backgroundColor: c.bgSecondary,
          appBar: AppBar(
            title: Text(s.settingsTitle),
            leading: const BackButton(),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(s.appearance),
              _SettingsCard(
                children: [
                  _SwitchTile(
                    icon: themeNotifier.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    title: s.darkMode,
                    value: themeNotifier.isDark,
                    onChanged: (_) => themeNotifier.toggle(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //язык
              _SectionHeader(s.language),
              _SettingsCard(
                children: [
                  _LangTile(
                    flag: '🇷🇺',
                    label: s.langRu,
                    selected: languageNotifier.isRu,
                    onTap: () => languageNotifier.setRussian(),
                  ),
                  Divider(height: 1, color: c.border),
                  _LangTile(
                    flag: '🇬🇧',
                    label: s.langEn,
                    selected: !languageNotifier.isRu,
                    onTap: () => languageNotifier.setEnglish(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _SectionHeader(s.notifications),
              _SettingsCard(
                children: [
                  _SwitchTile(
                    icon: Icons.notifications_outlined,
                    title: s.notifications,
                    subtitle: s.notifSub,
                    value: true,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SwitchListTile(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: c.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(fontSize: 12, color: c.textTertiary),
            )
          : null,
      value: value,
      activeThumbColor: AppTheme.primary,
      onChanged: onChanged,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String flag, label;
  final bool selected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      onTap: onTap,
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: c.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppTheme.primary, size: 20)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
