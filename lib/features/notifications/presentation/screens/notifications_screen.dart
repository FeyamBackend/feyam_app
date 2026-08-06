import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/features/notifications/domain/entities/notification_entity.dart';
import 'package:feyam/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:feyam/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:feyam/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:feyam/features/payments/presentation/screens/price_adjustment_payment_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<NotificationsBloc>()..add(const NotificationsLoadRequested()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.surfaceContainer,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, size: 24 * scale),
            ),
            title: Text(
              l10n.notifTitle,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              BlocBuilder<NotificationsBloc, NotificationsState>(
                buildWhen: (previous, current) =>
                    previous.unreadCount != current.unreadCount,
                builder: (context, state) {
                  if (state.unreadCount == 0) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () => context.read<NotificationsBloc>().add(
                      const NotificationsMarkAllReadRequested(),
                    ),
                    child: Text(l10n.notifMarkAllRead),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              switch (state.status) {
                case NotificationsStatus.initial:
                case NotificationsStatus.loading:
                  return const Center(child: CircularProgressIndicator());
                case NotificationsStatus.failure:
                  return _ErrorState(
                    scale: scale,
                    message: l10n.notifLoadError,
                  );
                case NotificationsStatus.empty:
                  return _EmptyNotifications(scale: scale);
                case NotificationsStatus.loaded:
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                    itemCount: state.items.length,
                    separatorBuilder: (_, index) => Divider(
                      height: 1,
                      indent: 72 * scale,
                      color: colors.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _NotifTile(
                        scale: scale,
                        item: item,
                        onTap: () {
                          context.read<NotificationsBloc>().add(
                            NotificationsMarkReadRequested(item.id),
                          );
                          if (item.relatedEntityType == 'PriceAdjustment' &&
                              item.relatedEntityId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => PriceAdjustmentPaymentScreen(
                                  purchaseId: item.relatedEntityId!,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
              }
            },
          ),
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.scale,
    required this.item,
    required this.onTap,
  });

  final double scale;
  final NotificationEntity item;
  final VoidCallback onTap;

  IconData get _icon => switch (item.category) {
    'OrderStatus' => Icons.local_shipping_rounded,
    'Payment' => Icons.payments_rounded,
    'Wallet' => Icons.account_balance_wallet_rounded,
    'Marketing' => Icons.storefront_rounded,
    _ => Icons.notifications_rounded,
  };

  String _relativeTime(BuildContext context) {
    final isSpanish = Localizations.localeOf(context).languageCode == 'es';
    final diff = DateTime.now().difference(item.createdDate);

    if (diff.inMinutes < 1) return isSpanish ? 'Ahora' : 'Just now';
    if (diff.inHours < 1) {
      return isSpanish
          ? 'Hace ${diff.inMinutes}min'
          : '${diff.inMinutes}min ago';
    }
    if (diff.inDays < 1) {
      return isSpanish ? 'Hace ${diff.inHours}h' : '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return isSpanish ? 'Hace ${diff.inDays}d' : '${diff.inDays}d ago';
    }
    return isSpanish
        ? 'Hace ${diff.inDays ~/ 7}sem'
        : '${diff.inDays ~/ 7}w ago';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 14 * scale,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40 * scale,
              height: 40 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isRead
                    ? colors.surfaceContainerHigh
                    : colors.primaryContainer,
              ),
              child: Icon(
                _icon,
                size: 20 * scale,
                color: item.isRead
                    ? colors.onSurfaceVariant
                    : colors.onPrimaryContainer,
              ),
            ),
            SizedBox(width: 14 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.title,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: item.isRead
                          ? FontWeight.w400
                          : FontWeight.w700,
                      fontSize: 14 * scale,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    item.body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: item.isRead
                          ? FontWeight.w400
                          : FontWeight.w600,
                      fontSize: 14 * scale,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    _relativeTime(context),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12 * scale,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              SizedBox(width: 8 * scale),
              Container(
                width: 8 * scale,
                height: 8 * scale,
                margin: EdgeInsets.only(top: 6 * scale),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80 * scale,
              height: 80 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainerHigh,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 36 * scale,
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 20 * scale),
            Text(
              l10n.notifEmpty,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 17 * scale,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              l10n.notifEmptyBody,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 14 * scale,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.scale, required this.message});

  final double scale;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 36 * scale,
              color: colors.error,
            ),
            SizedBox(height: 16 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 14 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
