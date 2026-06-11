import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/profile/presentation/screens/addresses_screen.dart';
import 'package:feyam/features/profile/presentation/screens/payment_methods_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoProfileContent();
    }

    return const _MaterialProfileContent();
  }
}

class _MaterialProfileContent extends StatelessWidget {
  const _MaterialProfileContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return Column(
          children: <Widget>[
            _MaterialProfileHeader(scale: scale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  24 * scale,
                  24 * scale,
                  44 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _MaterialProfileSummary(scale: scale),
                    SizedBox(height: 32 * scale),
                    _MaterialProfileSection(
                      scale: scale,
                      title: l10n.profileAccountSection,
                      rows: <_MaterialProfileRowData>[
                        _MaterialProfileRowData(
                          title: l10n.profileMyAddresses,
                          icon: Icons.location_on_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const AddressesScreen(),
                            ),
                          ),
                        ),
                        _MaterialProfileRowData(
                          title: l10n.profilePaymentMethods,
                          icon: Icons.credit_card_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => const PaymentMethodsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24 * scale),
                    _MaterialLogoutButton(label: l10n.profileLogOut, scale: scale),
                  ],
                ),
              ),
            ),
          ],
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
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.navProfile,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialProfileSummary extends StatelessWidget {
  const _MaterialProfileSummary({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        Container(
          width: 88 * scale,
          height: 88 * scale,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              l10n.profileName.isNotEmpty
                  ? l10n.profileName[0].toUpperCase()
                  : '?',
              style: textTheme.headlineLarge?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 36 * scale,
              ),
            ),
          ),
        ),
        SizedBox(height: 16 * scale),
        Text(
          l10n.profileName,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          l10n.profileEmail,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontSize: 13 * scale,
          ),
        ),
        SizedBox(height: 12 * scale),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.tertiaryContainer,
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              10 * scale,
              5 * scale,
              12 * scale,
              5 * scale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.star_rounded,
                  color: colors.onTertiaryContainer,
                  size: 16 * scale,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  l10n.profileMembershipLevel,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onTertiaryContainer,
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialProfileSection extends StatelessWidget {
  const _MaterialProfileSection({
    required this.scale,
    required this.title,
    required this.rows,
  });

  final double scale;
  final String title;
  final List<_MaterialProfileRowData> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 4 * scale, bottom: 10 * scale),
          child: Text(
            title,
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: <Widget>[
              for (var index = 0; index < rows.length; index++) ...[
                _MaterialProfileRow(scale: scale, data: rows[index]),
                if (index < rows.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16 * scale,
                    endIndent: 16 * scale,
                    color: colors.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MaterialProfileRow extends StatelessWidget {
  const _MaterialProfileRow({required this.scale, required this.data});

  final double scale;
  final _MaterialProfileRowData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16 * scale),
      onTap: data.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 14 * scale,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              data.icon,
              color: colors.onSurfaceVariant,
              size: 22 * scale,
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onSurface,
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w400,
                ),
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
    );
  }
}

class _MaterialLogoutButton extends StatelessWidget {
  const _MaterialLogoutButton({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(Icons.logout_rounded, size: 18 * scale),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error, width: scale),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scale),
        ),
        minimumSize: Size(double.infinity, 48 * scale),
        textStyle: textTheme.labelLarge?.copyWith(
          fontSize: 15 * scale,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MaterialProfileRowData {
  const _MaterialProfileRowData({
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
}

class _CupertinoProfileContent extends StatefulWidget {
  const _CupertinoProfileContent();

  @override
  State<_CupertinoProfileContent> createState() => _CupertinoProfileContentState();
}

class _CupertinoProfileContentState extends State<_CupertinoProfileContent> {
  static const _addresses = <_CupertinoAddress>[
    _CupertinoAddress(id: 1, label: 'Casa',    line: 'Cra. 45 #26-12, Apto 304',  city: 'Medellín, Antioquia'),
    _CupertinoAddress(id: 2, label: 'Oficina', line: 'Calle 50 #12-34, Piso 8',   city: 'Bogotá, Cundinamarca'),
  ];

  void _showAddressSheet(BuildContext context, {_CupertinoAddress? initial}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _AddressSheet(initial: initial),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Vas a salir de tu cuenta de Feyam en este dispositivo.'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 0),
                  child: Text(
                    l10n.navProfile,
                    style: TextStyle(fontSize: 34 * scale, fontWeight: FontWeight.w700, color: kFeyamLabel, letterSpacing: 0.37, fontFamily: '.SF Pro Display'),
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
                            title: const Text('María'),
                            subtitle: const Text('maria@feyam.com'),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(color: kFeyamTint, shape: BoxShape.circle),
                              child: const Center(
                                child: Text('M', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CupertinoColors.white)),
                              ),
                            ),
                            chevron: false,
                            isLast: true,
                          ),
                        ],
                      ),
                      // Addresses
                      FeyamListSection(
                        header: 'Mis direcciones',
                        footer: _addresses.isEmpty ? 'Todavía no agregaste direcciones.' : null,
                        children: <Widget>[
                          for (var i = 0; i < _addresses.length; i++)
                            FeyamListTile(
                              title: Text(_addresses[i].label),
                              subtitle: Text('${_addresses[i].line} · ${_addresses[i].city}'),
                              leading: FeyamIconTile(
                                icon: _addresses[i].label.toLowerCase().contains('casa') ? CupertinoIcons.house_fill : CupertinoIcons.bag_fill,
                                color: _addresses[i].label.toLowerCase().contains('casa') ? kFeyamGreen : kFeyamTint,
                              ),
                              isLast: false,
                              onTap: () => _showAddressSheet(context, initial: _addresses[i]),
                            ),
                          FeyamListTile(
                            title: const Text('Agregar dirección'),
                            leading: FeyamIconTile(icon: CupertinoIcons.plus_circle_fill, color: kFeyamGreen),
                            isLast: true,
                            onTap: () => _showAddressSheet(context),
                          ),
                        ],
                      ),
                      // Settings
                      FeyamListSection(
                        header: 'Configuración',
                        children: <Widget>[
                          FeyamListTile(
                            title: const Text('Notificaciones'),
                            leading: FeyamIconTile(icon: CupertinoIcons.bell_fill, color: kFeyamRed),
                            onTap: () {},
                          ),
                          FeyamListTile(
                            title: const Text('Seguridad y acceso'),
                            leading: FeyamIconTile(icon: CupertinoIcons.lock_fill, color: kFeyamLabelSec),
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
                            leading: FeyamIconTile(icon: CupertinoIcons.square_arrow_right_fill, color: kFeyamRed),
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
                          style: const TextStyle(fontSize: 12, color: kFeyamLabelTer, fontFamily: '.SF Pro Text'),
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

class _CupertinoAddress {
  const _CupertinoAddress({required this.id, required this.label, required this.line, required this.city});
  final int id;
  final String label;
  final String line;
  final String city;
}

// ── Address Sheet ─────────────────────────────────────────────────────────────

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({this.initial});
  final _CupertinoAddress? initial;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  late final TextEditingController _labelCtrl;
  late final TextEditingController _lineCtrl;
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.initial?.label ?? '');
    _lineCtrl  = TextEditingController(text: widget.initial?.line  ?? '');
    _cityCtrl  = TextEditingController(text: widget.initial?.city  ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _lineCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;

    return Container(
      decoration: const BoxDecoration(
        color: kFeyamCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Drag handle + title
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 36, height: 5,
              decoration: BoxDecoration(color: kFeyamFillTer, borderRadius: BorderRadius.circular(3)),
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
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kFeyamLabel),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar', style: TextStyle(fontSize: 17, color: kFeyamTint)),
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
              children: <Widget>[
                _SheetField(label: 'Etiqueta', placeholder: 'Casa, Oficina…', controller: _labelCtrl),
                const SizedBox(height: 16),
                _SheetField(label: 'Dirección', placeholder: 'Calle, número, apto', controller: _lineCtrl),
                const SizedBox(height: 16),
                _SheetField(label: 'Ciudad', placeholder: 'Ciudad, provincia', controller: _cityCtrl),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: FeyamButton(label: 'Guardar', onPressed: () => Navigator.of(context).pop()),
                ),
                if (isEdit) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FeyamButton(label: 'Eliminar dirección', variant: FeyamButtonVariant.destructivePlain, onPressed: () => Navigator.of(context).pop()),
                  ),
                ],
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FeyamButton(label: 'Cancelar', variant: FeyamButtonVariant.plain, onPressed: () => Navigator.of(context).pop()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.label, required this.placeholder, required this.controller});
  final String label;
  final String placeholder;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 13, color: kFeyamLabelSec, fontFamily: '.SF Pro Text')),
        const SizedBox(height: 4),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: kFeyamCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kFeyamSepLight),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CupertinoTextField.borderless(
            controller: controller,
            placeholder: placeholder,
          ),
        ),
      ],
    );
  }
}
