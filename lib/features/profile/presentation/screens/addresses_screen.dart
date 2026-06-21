import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/domain/entities/address_params.dart';
import 'package:feyam/features/profile/domain/entities/address_subdivision_entity.dart';
import 'package:feyam/features/profile/domain/entities/country_entity.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_bloc.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_event.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_state.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tipos de dirección soportados por el backend (AddressType).
const List<String> _addressTypes = <String>['Shipment', 'Billing'];

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    // El locale se lee tras el primer frame: Localizations no está disponible
    // en initState. Determina el idioma de los nombres de país (Accept-Language).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lang = Localizations.localeOf(context).languageCode;
      context.read<AddressesBloc>().add(AddressesLoadRequested(lang));
    });
  }

  void _openSheet({AddressEntity? initial}) {
    final bloc = context.read<AddressesBloc>();
    _sheetOpen = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<AddressesBloc>.value(
        value: bloc,
        child: _AddressSheet(
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

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
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
          backgroundColor: colors.surfaceContainerLowest,
          appBar: AppBar(
            backgroundColor: colors.surfaceContainer,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_rounded, size: 24 * scale),
            ),
            title: Text(
              l10n.addressesTitle,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: BlocConsumer<AddressesBloc, AddressesState>(
            listenWhen: (prev, curr) =>
                prev.actionStatus != curr.actionStatus,
            listener: (context, state) {
              switch (state.actionStatus) {
                case AddressActionStatus.success:
                  if (_sheetOpen) Navigator.pop(context);
                  _toast(l10n.addressSave);
                case AddressActionStatus.failure:
                  _toast(l10n.addressSaveError);
                case AddressActionStatus.idle:
                case AddressActionStatus.inProgress:
                  break;
              }
            },
            builder: (context, state) {
              if (state.status == AddressesStatus.loading &&
                  state.addresses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == AddressesStatus.failure &&
                  state.addresses.isEmpty) {
                return _ErrorState(
                  scale: scale,
                  message: l10n.addressLoadError,
                  onRetry: () => context.read<AddressesBloc>().add(
                        AddressesLoadRequested(
                          Localizations.localeOf(context).languageCode,
                        ),
                      ),
                );
              }

              return Column(
                children: <Widget>[
                  Expanded(
                    child: state.addresses.isEmpty
                        ? _EmptyAddresses(scale: scale, onAdd: () => _openSheet())
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(
                                16 * scale, 12 * scale, 16 * scale, 8 * scale),
                            itemCount: state.addresses.length,
                            itemBuilder: (context, index) => Padding(
                              padding: EdgeInsets.only(bottom: 10 * scale),
                              child: _AddressCard(
                                scale: scale,
                                address: state.addresses[index],
                                isDefault: index == 0,
                                onTap: () =>
                                    _openSheet(initial: state.addresses[index]),
                              ),
                            ),
                          ),
                  ),
                  if (state.addresses.isNotEmpty)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(
                            top: BorderSide(color: colors.outlineVariant)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            16 * scale, 12 * scale, 16 * scale, 20 * scale),
                        child: SizedBox(
                          height: 48 * scale,
                          child: FilledButton.tonal(
                            onPressed: () => _openSheet(),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              textStyle: textTheme.labelLarge
                                  ?.copyWith(fontSize: 15 * scale),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.add_rounded, size: 20 * scale),
                                SizedBox(width: 8 * scale),
                                Text(l10n.addressAdd),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.scale,
    required this.address,
    required this.isDefault,
    required this.onTap,
  });

  final double scale;
  final AddressEntity address;
  final bool isDefault;
  final VoidCallback onTap;

  String _typeLabel(AppLocalizations l10n) =>
      address.type == 'Billing' ? l10n.addressTypeBilling : l10n.addressTypeShipment;

  String get _subtitle {
    final parts = <String>[
      ...address.lines,
      ...address.subdivisions.map((s) => s.name),
      if (address.zipCode != null && address.zipCode!.isNotEmpty)
        address.zipCode!,
      address.countryCode,
    ];
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final title = (address.recipient?.trim().isNotEmpty ?? false)
        ? address.recipient!.trim()
        : _typeLabel(l10n);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Padding(
          padding: EdgeInsets.all(14 * scale),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: isDefault
                      ? colors.primaryContainer
                      : colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 22 * scale,
                  color: isDefault
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                              fontSize: 15 * scale,
                            ),
                          ),
                        ),
                        if (isDefault) ...[
                          SizedBox(width: 8 * scale),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(99 * scale),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * scale,
                                vertical: 2 * scale,
                              ),
                              child: Text(
                                l10n.addressDefault,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontSize: 11 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      _subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 13 * scale,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(0, -2 * scale),
                child: SizedBox(
                  width: 36 * scale,
                  height: 36 * scale,
                  child: Icon(Icons.edit_rounded,
                      size: 18 * scale, color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  final double scale;
  final String message;
  final VoidCallback onRetry;

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
            Icon(Icons.cloud_off_rounded,
                size: 40 * scale, color: colors.onSurfaceVariant),
            SizedBox(height: 16 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 14 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(l10n.addressRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  const _EmptyAddresses({required this.scale, required this.onAdd});

  final double scale;
  final VoidCallback onAdd;

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
              width: 72 * scale,
              height: 72 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceContainerHigh,
              ),
              child: Icon(Icons.location_off_rounded,
                  size: 32 * scale, color: colors.onSurfaceVariant),
            ),
            SizedBox(height: 16 * scale),
            Text(
              l10n.addressNoneTitle,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 17 * scale,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              l10n.addressNoneBody,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 14 * scale,
                height: 1.4,
              ),
            ),
            SizedBox(height: 20 * scale),
            FilledButton.tonal(
              onPressed: onAdd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.add_rounded, size: 20 * scale),
                  SizedBox(width: 8 * scale),
                  Text(l10n.addressAdd),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSheet extends StatefulWidget {
  const _AddressSheet({
    this.initial,
    required this.onSave,
    required this.onDelete,
  });

  final AddressEntity? initial;
  final void Function(String? id, AddressParams params) onSave;
  final void Function(String id) onDelete;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  late String _type;
  late String? _countryCode;
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
    _countryCode = initial?.countryCode ?? 'CO';
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
    _instructions =
        TextEditingController(text: initial?.deliveryInstructions ?? '');
  }

  @override
  void dispose() {
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
    setState(() {
      _lines.removeAt(index).dispose();
    });
  }

  void _save() {
    setState(() => _submitted = true);

    final country = _countryCode;
    final lines = _lines
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (country == null || country.length != 2 || lines.isEmpty) return;

    final subName = _subdivision.text.trim();
    final subdivisions = subName.isEmpty
        ? const <AddressSubdivisionEntity>[]
        : <AddressSubdivisionEntity>[
            // El backend exige code no nulo; usamos el nombre como código.
            AddressSubdivisionEntity(
                type: 'Other', code: subName, name: subName),
          ];

    final params = AddressParams(
      type: _type,
      countryCode: country.toUpperCase(),
      lines: lines,
      zipCode: _zip.text.trim().isEmpty ? null : _zip.text.trim(),
      recipient:
          _recipient.text.trim().isEmpty ? null : _recipient.text.trim(),
      deliveryInstructions:
          _instructions.text.trim().isEmpty ? null : _instructions.text.trim(),
      subdivisions: subdivisions,
    );

    widget.onSave(widget.initial?.id, params);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final inProgress = context.select<AddressesBloc, bool>(
      (b) => b.state.actionStatus == AddressActionStatus.inProgress,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.initial != null ? l10n.addressEdit : l10n.addressAdd,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: InputDecoration(
                    labelText: l10n.addressType,
                    border: const OutlineInputBorder(),
                  ),
                  items: _addressTypes
                      .map((t) => DropdownMenuItem<String>(
                            value: t,
                            child: Text(t == 'Billing'
                                ? l10n.addressTypeBilling
                                : l10n.addressTypeShipment),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                const SizedBox(height: 16),
                _countryField(context, l10n),
                const SizedBox(height: 16),
                ..._buildLineFields(context, l10n),
                if (_lines.length < 5)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addLine,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.addressLineAdd),
                    ),
                  ),
                const SizedBox(height: 8),
                _field(context, _subdivision, l10n.addressSubdivision),
                const SizedBox(height: 16),
                _field(context, _zip, l10n.addressZip),
                const SizedBox(height: 16),
                _field(context, _recipient, l10n.addressRecipient),
                const SizedBox(height: 16),
                _field(context, _instructions, l10n.addressInstructions,
                    maxLines: 2),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    if (widget.initial != null)
                      TextButton(
                        onPressed: inProgress
                            ? null
                            : () => widget.onDelete(widget.initial!.id),
                        style:
                            TextButton.styleFrom(foregroundColor: colors.error),
                        child: Text(l10n.addressDelete),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed:
                          inProgress ? null : () => Navigator.pop(context),
                      child: Text(l10n.addressCancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: inProgress ? null : _save,
                      child: inProgress
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.addressSave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Selector de país poblado con los países consultados al backend. Si el país
  /// actual (p. ej. de una dirección existente) ya no figura en la lista activa,
  /// se agrega como opción extra para no perder el valor guardado.
  Widget _countryField(BuildContext context, AppLocalizations l10n) {
    final countries = context.select<AddressesBloc, List<CountryEntity>>(
      (b) => b.state.countries,
    );

    final items = <DropdownMenuItem<String>>[
      for (final c in countries)
        DropdownMenuItem<String>(value: c.code, child: Text(c.name)),
    ];

    final current = _countryCode;
    if (current != null && !countries.any((c) => c.code == current)) {
      items.insert(
        0,
        DropdownMenuItem<String>(value: current, child: Text(current)),
      );
    }

    final loading = countries.isEmpty && current == null;

    return DropdownButtonFormField<String>(
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.addressCountry,
        border: const OutlineInputBorder(),
        errorText:
            _submitted && _countryCode == null ? l10n.addressCountryInvalid : null,
      ),
      items: items,
      onChanged: loading
          ? null
          : (v) => setState(() => _countryCode = v ?? _countryCode),
    );
  }

  List<Widget> _buildLineFields(BuildContext context, AppLocalizations l10n) {
    final widgets = <Widget>[];
    for (var i = 0; i < _lines.length; i++) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _field(
                  context,
                  _lines[i],
                  '${l10n.addressLine} ${i + 1}',
                  error: _submitted && i == 0 && _lines[0].text.trim().isEmpty
                      ? l10n.addressRequired
                      : null,
                ),
              ),
              if (_lines.length > 1)
                IconButton(
                  onPressed: () => _removeLine(i),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _field(
    BuildContext context,
    TextEditingController ctrl,
    String label, {
    String? error,
    int? maxLength,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
  }) {
    return TextField(
      controller: ctrl,
      maxLength: maxLength,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      onChanged: (_) {
        if (_submitted) setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        counterText: '',
        border: const OutlineInputBorder(),
      ),
    );
  }
}
