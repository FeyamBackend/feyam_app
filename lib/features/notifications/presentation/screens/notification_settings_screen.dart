import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/push/device_token_service.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

  String _statusText(AppLocalizations l10n) => switch (_status) {
    AuthorizationStatus.authorized ||
    AuthorizationStatus.provisional => l10n.notifSettingsEnabled,
    AuthorizationStatus.denied => l10n.notifSettingsDisabled,
    _ => l10n.notifSettingsUnknown,
  };

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return _buildCupertino(context);
    }
    return _buildMaterial(context);
  }

  Widget _buildCupertino(BuildContext context) {
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
                AuthorizationStatus.denied => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.notifSettingsDeniedHint,
                      style: const TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: openAppSettings,
                      child: Text(l10n.notifSettingsOpenButton),
                    ),
                  ],
                ),
                AuthorizationStatus.authorized ||
                AuthorizationStatus.provisional => CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: openAppSettings,
                  child: Text(l10n.notifSettingsOpenButton),
                ),
                _ => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final (icon, iconColor, iconBg) = switch (_status) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional => (
        Icons.notifications_active_rounded,
        colors.secondary,
        colors.secondaryContainer,
      ),
      AuthorizationStatus.denied => (
        Icons.notifications_off_rounded,
        colors.error,
        colors.errorContainer,
      ),
      _ => (
        Icons.notifications_none_rounded,
        colors.primary,
        colors.primaryContainer,
      ),
    };

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          FeyamHeroHeader(showBackButton: true, title: l10n.notifSettingsTitle),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.outlineVariant),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: iconBg,
                              ),
                              child: Icon(icon, size: 22, color: iconColor),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _statusText(l10n),
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_status == AuthorizationStatus.notDetermined) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _requestPermission,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.secondary,
                            foregroundColor: colors.onSecondary,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(l10n.notifSettingsEnableButton),
                        ),
                      ),
                    ],
                    if (_status == AuthorizationStatus.denied) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.notifSettingsDeniedHint,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.tonal(
                          onPressed: openAppSettings,
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: Text(l10n.notifSettingsOpenButton),
                        ),
                      ),
                    ],
                    if (_status == AuthorizationStatus.authorized ||
                        _status == AuthorizationStatus.provisional) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.tonal(
                          onPressed: openAppSettings,
                          style: FilledButton.styleFrom(
                            shape: const StadiumBorder(),
                          ),
                          child: Text(l10n.notifSettingsOpenButton),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
