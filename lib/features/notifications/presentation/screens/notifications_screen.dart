import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_NotifItem> _notifs;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _notifs = [
      _NotifItem(
        id: 1,
        icon: Icons.local_shipping_rounded,
        text: l10n.notifTitle == 'Notificaciones'
            ? 'Tu pedido de Sony WH-1000XM5 está en camino'
            : 'Your Sony WH-1000XM5 order is in transit',
        time: l10n.notifTitle == 'Notificaciones' ? 'Hace 2h' : '2h ago',
        read: false,
      ),
      _NotifItem(
        id: 2,
        icon: Icons.payments_rounded,
        text: l10n.notifTitle == 'Notificaciones'
            ? 'Pedido #FY-24489 listo para pagar'
            : 'Order #FY-24489 ready to pay',
        time: l10n.notifTitle == 'Notificaciones' ? 'Hace 1 día' : '1d ago',
        read: false,
      ),
      _NotifItem(
        id: 3,
        icon: Icons.check_circle_rounded,
        text: l10n.notifTitle == 'Notificaciones'
            ? '¡Tu Nike Air Max 90 fue entregado!'
            : 'Your Nike Air Max 90 was delivered!',
        time: l10n.notifTitle == 'Notificaciones' ? 'Hace 3 días' : '3d ago',
        read: true,
      ),
      _NotifItem(
        id: 4,
        icon: Icons.storefront_rounded,
        text: l10n.notifTitle == 'Notificaciones'
            ? 'Ahora soportamos compras en Best Buy'
            : 'We now support purchases from Best Buy',
        time: l10n.notifTitle == 'Notificaciones' ? 'Hace 1 sem' : '1w ago',
        read: true,
      ),
    ];
  }

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
          ),
          body: _notifs.isEmpty
              ? _EmptyNotifications(scale: scale)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8 * scale),
                  itemCount: _notifs.length,
                  separatorBuilder: (_, index) => Divider(
                    height: 1,
                    indent: 72 * scale,
                    color: colors.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final n = _notifs[index];
                    return _NotifTile(
                      scale: scale,
                      item: n,
                      onTap: () {
                        setState(() {
                          _notifs = _notifs
                              .map((x) => x.id == n.id ? x.copyWith(read: true) : x)
                              .toList();
                        });
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.scale, required this.item, required this.onTap});

  final double scale;
  final _NotifItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40 * scale,
              height: 40 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.read ? colors.surfaceContainerHigh : colors.primaryContainer,
              ),
              child: Icon(
                item.icon,
                size: 20 * scale,
                color: item.read ? colors.onSurfaceVariant : colors.onPrimaryContainer,
              ),
            ),
            SizedBox(width: 14 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.text,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: item.read ? FontWeight.w400 : FontWeight.w600,
                      fontSize: 14 * scale,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    item.time,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12 * scale,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.read) ...[
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
              child: Icon(Icons.notifications_outlined, size: 36 * scale, color: colors.onSurfaceVariant),
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

class _NotifItem {
  const _NotifItem({
    required this.id,
    required this.icon,
    required this.text,
    required this.time,
    required this.read,
  });

  final int id;
  final IconData icon;
  final String text;
  final String time;
  final bool read;

  _NotifItem copyWith({bool? read}) => _NotifItem(
        id: id,
        icon: icon,
        text: text,
        time: time,
        read: read ?? this.read,
      );
}
