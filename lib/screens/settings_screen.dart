import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  int _notificationHour = 8;
  int _notificationMinute = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _notificationHour = prefs.getInt('notification_hour') ?? 8;
      _notificationMinute = prefs.getInt('notification_minute') ?? 0;
    });
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = value;
    });
    if (value) {
      await NotificationService().requestPermissions();
      await NotificationService()
          .scheduleDaily(_notificationHour, _notificationMinute);
    } else {
      await NotificationService().cancelAll();
    }
  }

  Future<void> _pickNotificationTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: _notificationHour, minute: _notificationMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.goldColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_hour', picked.hour);
    await prefs.setInt('notification_minute', picked.minute);
    if (!mounted) return;
    setState(() {
      _notificationHour = picked.hour;
      _notificationMinute = picked.minute;
    });
    await NotificationService().scheduleDaily(picked.hour, picked.minute);
  }

  String get _formattedTime {
    final h = _notificationHour.toString().padLeft(2, '0');
    final m = _notificationMinute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.0,
              color: AppTheme.accentGoldLight,
            ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        iconTheme: const IconThemeData(color: AppTheme.goldColor),
        title: Text(
          'Setări',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                letterSpacing: 1.2,
              ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Section: Notificări
            SliverToBoxAdapter(
              child: _buildSectionHeader(context, 'NOTIFICĂRI'),
            ),
            SliverToBoxAdapter(
              child: _buildCard(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Notificare zilnică',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      'Primești o rugăciune în fiecare dimineață',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: _notificationsEnabled,
                    onChanged: _setNotificationsEnabled,
                    activeThumbColor: AppTheme.goldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  if (_notificationsEnabled) ...[
                    const Divider(
                      height: 1,
                      color: AppTheme.dividerColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                    ListTile(
                      title: Text(
                        'Ora notificării',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      trailing: Text(
                        _formattedTime,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.goldColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      onTap: _pickNotificationTime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Section: Aplicație
            SliverToBoxAdapter(
              child: _buildSectionHeader(context, 'APLICAȚIE'),
            ),
            SliverToBoxAdapter(
              child: _buildCard(
                children: [
                  ListTile(
                    title: Text(
                      'Versiunea aplicației',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    trailing: Text(
                      '1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textBrownColor,
                          ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
