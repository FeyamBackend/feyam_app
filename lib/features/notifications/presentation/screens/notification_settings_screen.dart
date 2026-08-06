import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/push/device_token_service.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

/// Reached from the Profile screen's "Notifications" settings row — surfaces the current OS
/// push-permission state, distinct from the bell icon's [NotificationsScreen] (history).
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  AuthorizationStatus? _status;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (!mounted) return;
    setState(() => _status = settings.authorizationStatus);
  }

  Future<void> _requestPermission() async {
    await sl<DeviceTokenService>().syncToken();
    await _refreshStatus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.notifSettingsTitle),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_statusText(l10n), style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              switch (_status) {
                AuthorizationStatus.notDetermined => CupertinoButton.filled(
                  onPressed: _requestPermission,
                  child: Text(l10n.notifSettingsEnableButton),
                ),
                AuthorizationStatus.denied => Text(
                  l10n.notifSettingsDeniedHint,
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
    );
  }

  String _statusText(AppLocalizations l10n) => switch (_status) {
    AuthorizationStatus.authorized ||
    AuthorizationStatus.provisional => l10n.notifSettingsEnabled,
    AuthorizationStatus.denied => l10n.notifSettingsDisabled,
    _ => l10n.notifSettingsUnknown,
  };
}
