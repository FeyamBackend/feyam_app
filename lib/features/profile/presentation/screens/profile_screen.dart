import 'dart:async';

import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/push/device_token_service.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:feyam/features/help/presentation/screens/help_screen.dart';
import 'package:feyam/features/notifications/presentation/bloc/unread_count_bloc.dart';
import 'package:feyam/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:feyam/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:feyam/features/orders/presentation/screens/order_screen.dart';
import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';
import 'package:feyam/features/profile/domain/entities/address_subdivision_entity.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_bloc.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_event.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_state.dart';
import 'package:feyam/features/profile/presentation/screens/addresses_screen.dart';
import 'package:feyam/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return BlocProvider<AddressesBloc>(
        create: (_) => sl<AddressesBloc>()
          ..add(
            AddressesLoadRequested(
              Localizations.localeOf(context).languageCode,
            ),
          ),
        child: const _CupertinoProfileContent(),
      );
    }

    return const _MaterialProfileContent();
  }
}

class _MaterialProfileContent extends StatelessWidget {
  const _MaterialProfileContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);
        // The scrollable content starts above the header's bottom edge so the
        // profile card overlaps into the navy area, matching the design.
        const cardOverlap = 28.0;
        final headerHeight = MediaQuery.of(context).padding.top + 76 * scale;

        return ColoredBox(
          color: colors.surface,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: _MaterialProfileHeader(scale: scale),
              ),
              Positioned.fill(
                top: headerHeight - cardOverlap * scale,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    0,
                    20 * scale,
                    32 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _MaterialProfileCard(scale: scale),
                      SizedBox(height: 20 * scale),
                      _MaterialProfileRowCard(
                        scale: scale,
                        title: l10n.profileMyOrders,
                        subtitle: l10n.profileMyOrdersSubtitle,
                        icon: Icons.inventory_2_outlined,
                        iconColor: colors.primary,
                        onTap: () {
                          final unreadCountBloc = context.read<UnreadCountBloc>();
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider<UnreadCountBloc>.value(
                                value: unreadCountBloc,
                                child: const OrderScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12 * scale),
                      _MaterialProfileRowCard(
                        scale: scale,
                        title: l10n.profileMyAddresses,
                        subtitle: l10n.profileMyAddressesSubtitle,
                        icon: Icons.location_on_outlined,
                        iconColor: colors.secondary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider<AddressesBloc>(
                              create: (_) => sl<AddressesBloc>(),
                              child: const AddressesScreen(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      _MaterialProfileRowCard(
                        scale: scale,
                        title: l10n.profilePaymentMethods,
                        subtitle: l10n.profilePaymentMethodsSubtitle,
                        icon: Icons.credit_card_outlined,
                        iconColor: colors.secondary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const PaymentMethodsScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      _MaterialProfileRowCard(
                        scale: scale,
                        title: l10n.profileNotifications,
                        subtitle: l10n.profileNotificationsSubtitle,
                        icon: Icons.notifications_outlined,
                        iconColor: colors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const NotificationSettingsScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      _MaterialProfileRowCard(
                        scale: scale,
                        title: l10n.profileHelpSupport,
                        subtitle: l10n.profileHelpSupportSubtitle,
                        icon: Icons.support_agent_outlined,
                        iconColor: colors.secondary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const HelpScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: 28 * scale),
                      _MaterialLogoutButton(
                        label: l10n.profileLogOut,
                        scale: scale,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MaterialProfileHeader extends StatelessWidget {
  const _MaterialProfileHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.primary),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 76 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20 * scale,
              vertical: 12 * scale,
            ),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/branding/logo_white.png',
                  height: 28 * scale,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  icon: Badge.count(
                    count: context.watch<UnreadCountBloc>().state.count,
                    isLabelVisible:
                        context.watch<UnreadCountBloc>().state.count > 0,
                    child: Icon(
                      Icons.notifications_outlined,
                      color: colors.onPrimary,
                      size: 24 * scale,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialProfileCard extends StatelessWidget {
  const _MaterialProfileCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthBloc>().state.user;
    final displayName = user?.displayName ?? l10n.profileName;
    final email = user?.email ?? l10n.profileEmail;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 64 * scale,
                  height: 64 * scale,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 26 * scale,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          color: colors.primary,
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3 * scale),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 13 * scale,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18 * scale),
            Divider(height: 1, thickness: 1, color: colors.outlineVariant),
            SizedBox(height: 16 * scale),
            // Placeholder counts: the API only exposes a capped "recent orders"
            // list (no lifetime totals), and there's no favorites feature yet.
            // Swap these for real data once that backend support exists.
            Row(
              children: <Widget>[
                Expanded(
                  child: _MaterialProfileStat(
                    scale: scale,
                    icon: Icons.shopping_bag_outlined,
                    iconColor: colors.primary,
                    value: '12',
                    label: l10n.profileStatOrders,
                  ),
                ),
                _MaterialProfileStatDivider(scale: scale),
                Expanded(
                  child: _MaterialProfileStat(
                    scale: scale,
                    icon: Icons.local_shipping_outlined,
                    iconColor: colors.secondary,
                    value: '10',
                    label: l10n.profileStatDelivered,
                  ),
                ),
                _MaterialProfileStatDivider(scale: scale),
                Expanded(
                  child: _MaterialProfileStat(
                    scale: scale,
                    icon: Icons.favorite_border_rounded,
                    iconColor: colors.tertiary,
                    value: '8',
                    label: l10n.profileStatFavorites,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialProfileStat extends StatelessWidget {
  const _MaterialProfileStat({
    required this.scale,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final double scale;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Icon(icon, color: iconColor, size: 20 * scale),
        SizedBox(height: 6 * scale),
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: colors.primary,
            fontSize: 17 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2 * scale),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 11.5 * scale,
          ),
        ),
      ],
    );
  }
}

class _MaterialProfileStatDivider extends StatelessWidget {
  const _MaterialProfileStatDivider({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36 * scale,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _MaterialProfileRowCard extends StatelessWidget {
  const _MaterialProfileRowCard({
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final double scale;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16 * scale),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 14 * scale,
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: iconColor, size: 24 * scale),
              SizedBox(width: 16 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.primary,
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12.5 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 20 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialLogoutButton extends StatelessWidget {
  const _MaterialLogoutButton({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: () {
        unawaited(sl<DeviceTokenService>().clearToken());
        context.read<AuthBloc>().add(SignOutPressed());
      },
      icon: Icon(Icons.logout_rounded, size: 18 * scale, color: colors.error),
      label: Text(
        label,
        style: TextStyle(
          color: colors.error,
          fontSize: 15 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 44 * scale),
      ),
    );
  }
}

class _CupertinoProfileContent extends StatefulWidget {
  const _CupertinoProfileContent();

  @override
  State<_CupertinoProfileContent> createState() =>
      _CupertinoProfileContentState();
}

class _CupertinoProfileContentState extends State<_CupertinoProfileContent> {
  bool _sheetOpen = false;

  void _showAddressSheet(BuildContext context, {AddressEntity? initial}) {
    final bloc = context.read<AddressesBloc>();
    _sheetOpen = true;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => BlocProvider<AddressesBloc>.value(
        value: bloc,
        child: _CupertinoAddressSheet(
          initial: initial,
          onSave: (id, params) {
            if (id != null) {
              bloc.add(AddressUpdateRequested(id, params));
            } else {
              bloc.add(AddressCreateRequested(params));
            }
          },
          onDelete: (id) => bloc.add(AddressDeleteRequested(id)),
        ),
      ),
    ).whenComplete(() => _sheetOpen = false);
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<AuthBloc>();

    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutBody),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              unawaited(sl<DeviceTokenService>().clearToken());
              bloc.add(SignOutPressed());
            },
            child: Text(l10n.profileLogOut),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthBloc>().state.user;
    final displayName = user?.displayName ?? l10n.profileName;
    final email = user?.email ?? l10n.profileEmail;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return ColoredBox(
          color: kFeyamBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Large title
              Container(
                color: kFeyamBg,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    8 * scale,
                    16 * scale,
                    0,
                  ),
                  child: Text(
                    l10n.navProfile,
                    style: GoogleFonts.poppins(
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.w700,
                      color: kFeyamLabel,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 32 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 16 * scale),
                      // Account tile
                      FeyamListSection(
                        children: <Widget>[
                          FeyamListTile(
                            title: Text(displayName),
                            subtitle: Text(email),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: kFeyamTint,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ),
                            ),
                            chevron: false,
                            isLast: true,
                          ),
                        ],
                      ),
                      // Addresses
                      BlocConsumer<AddressesBloc, AddressesState>(
                        listenWhen: (prev, curr) =>
                            prev.actionStatus != curr.actionStatus,
                        listener: (context, state) {
                          if (state.actionStatus ==
                                  AddressActionStatus.success &&
                              _sheetOpen) {
                            Navigator.of(context).pop();
                          }
                        },
                        builder: (context, state) {
                          final addresses = state.addresses;
                          final loading =
                              state.status == AddressesStatus.loading &&
                              addresses.isEmpty;
                          return FeyamListSection(
                            header: 'Mis direcciones',
                            footer: addresses.isEmpty && !loading
                                ? 'Todavía no agregaste direcciones.'
                                : null,
                            children: <Widget>[
                              if (loading)
                                const FeyamListTile(
                                  title: Text('Cargando…'),
                                  chevron: false,
                                ),
                              for (var i = 0; i < addresses.length; i++)
                                FeyamListTile(
                                  title: Text(_cupertinoTitle(addresses[i])),
                                  subtitle: Text(
                                    _cupertinoSubtitle(addresses[i]),
                                  ),
                                  leading: FeyamIconTile(
                                    icon: addresses[i].type == 'Billing'
                                        ? CupertinoIcons.bag_fill
                                        : CupertinoIcons.house_fill,
                                    color: addresses[i].type == 'Billing'
                                        ? kFeyamTint
                                        : kFeyamGreen,
                                  ),
                                  isLast: false,
                                  onTap: () => _showAddressSheet(
                                    context,
                                    initial: addresses[i],
                                  ),
                                ),
                              FeyamListTile(
                                title: const Text('Agregar dirección'),
                                leading: FeyamIconTile(
                                  icon: CupertinoIcons.plus_circle_fill,
                                  color: kFeyamGreen,
                                ),
                                isLast: true,
                                onTap: () => _showAddressSheet(context),
                              ),
                            ],
                          );
                        },
                      ),
                      // Settings
                      FeyamListSection(
                        header: 'Configuración',
                        children: <Widget>[
                          FeyamListTile(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              )!.profileNotifications,
                            ),
                            leading: FeyamIconTile(
                              icon: CupertinoIcons.bell_fill,
                              color: kFeyamRed,
                            ),
                            onTap: () => Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) =>
                                    const NotificationSettingsScreen(),
                              ),
                            ),
                          ),
                          FeyamListTile(
                            title: const Text('Seguridad y acceso'),
                            leading: FeyamIconTile(
                              icon: CupertinoIcons.lock_fill,
                              color: kFeyamLabelSec,
                            ),
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
                      ),
                      // Logout
                      FeyamListSection(
                        children: <Widget>[
                          FeyamListTile(
                            title: const Text('Cerrar sesión'),
                            leading: FeyamIconTile(
                              icon: CupertinoIcons.square_arrow_right_fill,
                              color: kFeyamRed,
                            ),
                            destructive: true,
                            chevron: false,
                            isLast: true,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Feyam v2.0.0 (Cupertino)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: kFeyamLabelTer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _cupertinoTitle(AddressEntity a) {
  final recipient = a.recipient?.trim() ?? '';
  if (recipient.isNotEmpty) return recipient;
  return a.type == 'Billing' ? 'Facturación' : 'Envío';
}

String _cupertinoSubtitle(AddressEntity a) {
  final parts = <String>[
    ...a.lines,
    ...a.subdivisions.map((s) => s.name),
    if (a.zipCode != null && a.zipCode!.isNotEmpty) a.zipCode!,
    a.countryCode,
  ];
  return parts.join(' · ');
}

// ── Address Sheet ─────────────────────────────────────────────────────────────

class _CupertinoAddressSheet extends StatefulWidget {
  const _CupertinoAddressSheet({
    this.initial,
    required this.onSave,
    required this.onDelete,
  });

  final AddressEntity? initial;
  final void Function(String? id, AddressParams params) onSave;
  final void Function(String id) onDelete;

  @override
  State<_CupertinoAddressSheet> createState() => _CupertinoAddressSheetState();
}

class _CupertinoAddressSheetState extends State<_CupertinoAddressSheet> {
  late String _type;
  late final TextEditingController _country;
  late final List<TextEditingController> _lines;
  late final TextEditingController _subdivision;
  late final TextEditingController _zip;
  late final TextEditingController _recipient;
  late final TextEditingController _instructions;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _type = initial?.type ?? 'Shipment';
    _country = TextEditingController(text: initial?.countryCode ?? 'VE');
    _lines = (initial?.lines.isNotEmpty ?? false)
        ? initial!.lines.map((l) => TextEditingController(text: l)).toList()
        : <TextEditingController>[TextEditingController()];
    _subdivision = TextEditingController(
      text: initial?.subdivisions.isNotEmpty ?? false
          ? initial!.subdivisions.first.name
          : '',
    );
    _zip = TextEditingController(text: initial?.zipCode ?? '');
    _recipient = TextEditingController(text: initial?.recipient ?? '');
    _instructions = TextEditingController(
      text: initial?.deliveryInstructions ?? '',
    );
  }

  @override
  void dispose() {
    _country.dispose();
    for (final c in _lines) {
      c.dispose();
    }
    _subdivision.dispose();
    _zip.dispose();
    _recipient.dispose();
    _instructions.dispose();
    super.dispose();
  }

  void _addLine() {
    if (_lines.length >= 5) return;
    setState(() => _lines.add(TextEditingController()));
  }

  void _removeLine(int index) {
    if (_lines.length <= 1) return;
    setState(() => _lines.removeAt(index).dispose());
  }

  void _save() {
    setState(() => _submitted = true);

    final country = _country.text.trim();
    final lines = _lines
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (country.length != 2 || lines.isEmpty) return;

    final subName = _subdivision.text.trim();
    final subdivisions = subName.isEmpty
        ? const <AddressSubdivisionEntity>[]
        : <AddressSubdivisionEntity>[
            // El backend exige code no nulo; usamos el nombre como código.
            AddressSubdivisionEntity(
              type: 'Other',
              code: subName,
              name: subName,
            ),
          ];

    final params = AddressParams(
      type: _type,
      countryCode: country.toUpperCase(),
      lines: lines,
      zipCode: _zip.text.trim().isEmpty ? null : _zip.text.trim(),
      recipient: _recipient.text.trim().isEmpty ? null : _recipient.text.trim(),
      deliveryInstructions: _instructions.text.trim().isEmpty
          ? null
          : _instructions.text.trim(),
      subdivisions: subdivisions,
    );

    widget.onSave(widget.initial?.id, params);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final inProgress = context.select<AddressesBloc, bool>(
      (b) => b.state.actionStatus == AddressActionStatus.inProgress,
    );
    final countryError = _submitted && _country.text.trim().length != 2
        ? 'Usá el código de 2 letras (ej. VE)'
        : null;
    final linesError = _submitted && _lines[0].text.trim().isEmpty
        ? 'Requerido'
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: kFeyamCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Drag handle + title
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: kFeyamFillTer,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 60),
                    Expanded(
                      child: Text(
                        isEdit ? 'Editar dirección' : 'Agregar dirección',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: kFeyamLabel,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: inProgress
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(fontSize: 17, color: kFeyamTint),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 0.5, color: kFeyamSepLight),
              // Fields
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CupertinoSlidingSegmentedControl<String>(
                      groupValue: _type,
                      children: const <String, Widget>{
                        'Shipment': Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('Envío'),
                        ),
                        'Billing': Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text('Facturación'),
                        ),
                      },
                      onValueChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    const SizedBox(height: 16),
                    _SheetField(
                      label: 'País (código de 2 letras)',
                      placeholder: 'VE',
                      controller: _country,
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
                      errorText: countryError,
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < _lines.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: _SheetField(
                                label: 'Línea ${i + 1}',
                                placeholder: 'Calle, número, apto',
                                controller: _lines[i],
                                errorText: i == 0 ? linesError : null,
                              ),
                            ),
                            if (_lines.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 22,
                                  left: 4,
                                ),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _removeLine(i),
                                  child: const Icon(
                                    CupertinoIcons.minus_circle_fill,
                                    color: kFeyamRed,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (_lines.length < 5)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _addLine,
                          child: const Text(
                            'Agregar línea',
                            style: TextStyle(fontSize: 15, color: kFeyamTint),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    _SheetField(
                      label: 'Ciudad / Estado',
                      placeholder: 'Medellín, Antioquia',
                      controller: _subdivision,
                    ),
                    const SizedBox(height: 16),
                    _SheetField(
                      label: 'Código postal',
                      placeholder: '050021',
                      controller: _zip,
                    ),
                    const SizedBox(height: 16),
                    _SheetField(
                      label: 'Destinatario',
                      placeholder: 'Nombre de quien recibe',
                      controller: _recipient,
                    ),
                    const SizedBox(height: 16),
                    _SheetField(
                      label: 'Instrucciones de entrega',
                      placeholder: 'Portería, referencias…',
                      controller: _instructions,
                    ),
                  ],
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: FeyamButton(
                        label: inProgress ? 'Guardando…' : 'Guardar',
                        onPressed: inProgress ? null : _save,
                      ),
                    ),
                    if (isEdit) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FeyamButton(
                          label: 'Eliminar dirección',
                          variant: FeyamButtonVariant.destructivePlain,
                          onPressed: inProgress
                              ? null
                              : () => widget.onDelete(widget.initial!.id),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FeyamButton(
                        label: 'Cancelar',
                        variant: FeyamButtonVariant.plain,
                        onPressed: inProgress
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.placeholder,
    required this.controller,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
    this.errorText,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, color: kFeyamLabelSec),
        ),
        const SizedBox(height: 4),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: kFeyamCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null ? kFeyamRed : kFeyamSepLight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CupertinoTextField.borderless(
            controller: controller,
            placeholder: placeholder,
            textCapitalization: textCapitalization,
            inputFormatters: maxLength != null
                ? <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(maxLength),
                  ]
                : null,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(fontSize: 12, color: kFeyamRed),
          ),
        ],
      ],
    );
  }
}
