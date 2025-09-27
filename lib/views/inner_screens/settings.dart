import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import 'package:brevity/l10n/app_localizations.dart';
import 'package:brevity/controller/services/notification_service.dart';
import 'package:brevity/controller/services/auth_service.dart';
import 'package:brevity/controller/cubit/locale/locale_cubit.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/controller/cubit/theme/theme_state.dart';
import 'package:brevity/models/theme_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _reminderEnabled = false;
  String _reminderTime = '09:00';

  @override
  void initState() {
    super.initState();
    _loadReminderPrefs();
  }

  Future<void> _loadReminderPrefs() async {
    try {
      final enabled = await _notificationService.isReminderEnabled();
      final time = await _notificationService.getReminderTime();
      setState(() {
        _reminderEnabled = enabled;
        _reminderTime = time;
      });
    } catch (_) {}
  }

  void _toggleReminder(bool v) async {
    setState(() => _reminderEnabled = v);
    if (v) {
      final hasPermission = await _notificationService.requestPermissions();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.notificationPermissionRequired)));
        setState(() => _reminderEnabled = false);
        return;
      }
      await _notificationService.setReminderEnabled(true);
    } else {
      await _notificationService.setReminderEnabled(false);
    }
  }

  Future<void> _pickTime() async {
    final parts = _reminderTime.split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => _reminderTime = formatted);
      await _notificationService.setReminderTime(formatted);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.reminderTimeSet(formatted))));
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LocaleCubit.supportedLanguages.entries.map((entry) {
              final languageName = entry.key;
              final localeCode = entry.value;
              return ListTile(
                title: Text(languageName),
                onTap: () {
                  context.read<LocaleCubit>().changeLocaleByCode(localeCode);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.close),
          )
        ],
      ),
    );
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectTheme),
        content: BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
          return Wrap(spacing: 8, children: AppTheme.availableThemes.map((t) {
            final isSelected = state.currentTheme.name == t.name;
            return GestureDetector(
              onTap: () {
                context.read<ThemeCubit>().changeTheme(t.copyWith(isDarkMode: state.currentTheme.isDarkMode));
                Navigator.pop(ctx);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: t.primaryColor, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.black, width: 2) : null),
                child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }).toList());
        }),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.close))],
      ),
    );
  }

  void _shareApp() {
    Share.share(AppLocalizations.of(context)!.shareAppMessage);
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccount),
        content: Text(AppLocalizations.of(context)!.deleteAccountWarning),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().deleteAccount(context: context);
            },
            child: Text(AppLocalizations.of(context)!.deleteAccount),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: ListTile(
            title: Text(loc.language),
            subtitle: Text(loc.english),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguageDialog,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text(loc.appTheme),
            subtitle: Text(loc.changeAppAccentColor),
            trailing: const Icon(Icons.palette),
            onTap: _showThemePicker,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile.adaptive(
            title: Text(loc.dailyBookmarkReminder),
            subtitle: Text(_reminderEnabled ? loc.dailyRemindersEnabled(_reminderTime) : loc.dailyRemindersDisabled),
            value: _reminderEnabled,
            onChanged: _toggleReminder,
          ),
        ),
        if (_reminderEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.access_time),
              label: Text(loc.setReminderTime),
            ),
          ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text(loc.shareApp),
            subtitle: Text(loc.shareAppMessage),
            leading: const Icon(Icons.share),
            onTap: _shareApp,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: theme.colorScheme.errorContainer,
          child: ListTile(
            title: Text(loc.deleteAccount, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            subtitle: Text(loc.deleteAccountWarning, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _confirmDeleteAccount,
          ),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }
}
