import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<_Address> _addresses = const <_Address>[
    _Address(id: 1, label: 'Casa', line: 'Cra. 43A #1-50, Apto 1204', city: 'Medellín, Antioquia'),
    _Address(id: 2, label: 'Oficina', line: 'Calle 7 #39-197, Torre Sur P.8', city: 'Medellín, Antioquia'),
  ];

  void _openSheet({_Address? initial}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddressSheet(
        initial: initial,
        onSave: (a) {
          setState(() {
            if (initial != null) {
              _addresses = _addresses.map((x) => x.id == a.id ? a : x).toList();
            } else {
              _addresses = [..._addresses, a];
            }
          });
          Navigator.pop(context);
          _toast(initial != null
              ? AppLocalizations.of(context)!.addressesTitle
              : AppLocalizations.of(context)!.addressAdd);
        },
        onDelete: (id) {
          setState(() {
            _addresses = _addresses.where((x) => x.id != id).toList();
          });
          Navigator.pop(context);
        },
      ),
    );
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
          body: Column(
            children: <Widget>[
              Expanded(
                child: _addresses.isEmpty
                    ? _EmptyAddresses(scale: scale, onAdd: () => _openSheet())
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 8 * scale),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(bottom: 10 * scale),
                          child: _AddressCard(
                            scale: scale,
                            address: _addresses[index],
                            isDefault: index == 0,
                            onTap: () => _openSheet(initial: _addresses[index]),
                          ),
                        ),
                      ),
              ),
              if (_addresses.isNotEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(top: BorderSide(color: colors.outlineVariant)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 20 * scale),
                    child: SizedBox(
                      height: 48 * scale,
                      child: FilledButton.tonal(
                        onPressed: () => _openSheet(),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15 * scale),
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
  final _Address address;
  final bool isDefault;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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
                  color: isDefault ? colors.primaryContainer : colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 22 * scale,
                  color: isDefault ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          address.label,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
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
                      '${address.line}\n${address.city}',
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
                  child: Icon(Icons.edit_rounded, size: 18 * scale, color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
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
              child: Icon(Icons.location_off_rounded, size: 32 * scale, color: colors.onSurfaceVariant),
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
  const _AddressSheet({this.initial, required this.onSave, required this.onDelete});

  final _Address? initial;
  final void Function(_Address) onSave;
  final void Function(int) onDelete;

  @override
  State<_AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<_AddressSheet> {
  late final TextEditingController _label;
  late final TextEditingController _line;
  late final TextEditingController _city;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.initial?.label ?? '');
    _line = TextEditingController(text: widget.initial?.line ?? '');
    _city = TextEditingController(text: widget.initial?.city ?? '');
  }

  @override
  void dispose() {
    _label.dispose();
    _line.dispose();
    _city.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _submitted = true);
    if (_label.text.trim().isEmpty || _line.text.trim().isEmpty || _city.text.trim().isEmpty) return;
    widget.onSave(_Address(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch,
      label: _label.text.trim(),
      line: _line.text.trim(),
      city: _city.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
              _field(context, _label, l10n.addressLabelField, l10n.addressRequired),
              const SizedBox(height: 16),
              _field(context, _line, l10n.addressStreet, l10n.addressRequired),
              const SizedBox(height: 16),
              _field(context, _city, l10n.addressCity, l10n.addressRequired),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  if (widget.initial != null)
                    TextButton(
                      onPressed: () => widget.onDelete(widget.initial!.id),
                      style: TextButton.styleFrom(foregroundColor: colors.error),
                      child: Text(l10n.addressDelete),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.addressCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: Text(l10n.addressSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, TextEditingController ctrl, String label, String req) {
    final l10n = AppLocalizations.of(context)!;
    final err = _submitted && ctrl.text.trim().isEmpty ? l10n.addressRequired : null;
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        errorText: err,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _Address {
  const _Address({required this.id, required this.label, required this.line, required this.city});

  final int id;
  final String label;
  final String line;
  final String city;
}
