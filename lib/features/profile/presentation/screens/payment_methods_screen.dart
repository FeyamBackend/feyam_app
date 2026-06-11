import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<_PaymentMethod> _methods = const <_PaymentMethod>[
    _PaymentMethod(id: 1, type: _PmType.nequi, label: 'Nequi', detail: '300 456 7890'),
    _PaymentMethod(id: 2, type: _PmType.bank, label: 'Bancolombia', detail: 'Ahorros · ****4521'),
  ];

  void _openSheet({_PaymentMethod? initial}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaymentSheet(
        initial: initial,
        onSave: (m) {
          setState(() {
            if (initial != null) {
              _methods = _methods.map((x) => x.id == m.id ? m : x).toList();
            } else {
              _methods = [..._methods, m];
            }
          });
          Navigator.pop(context);
        },
        onDelete: (id) {
          setState(() {
            _methods = _methods.where((x) => x.id != id).toList();
          });
          Navigator.pop(context);
        },
      ),
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
              l10n.paymentTitle,
              style: textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              // Info banner
              Padding(
                padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14 * scale),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(Icons.info_outline_rounded, size: 18 * scale, color: colors.onTertiaryContainer),
                        SizedBox(width: 10 * scale),
                        Expanded(
                          child: Text(
                            l10n.paymentInfo,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onTertiaryContainer,
                              fontSize: 13 * scale,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _methods.isEmpty
                    ? _EmptyMethods(scale: scale, onAdd: () => _openSheet())
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 8 * scale),
                        itemCount: _methods.length,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(bottom: 10 * scale),
                          child: _MethodCard(
                            scale: scale,
                            method: _methods[index],
                            isPrimary: index == 0,
                            onTap: () => _openSheet(initial: _methods[index]),
                          ),
                        ),
                      ),
              ),
              if (_methods.isNotEmpty)
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
                            Text(l10n.paymentAdd),
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

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.scale,
    required this.method,
    required this.isPrimary,
    required this.onTap,
  });

  final double scale;
  final _PaymentMethod method;
  final bool isPrimary;
  final VoidCallback onTap;

  static const _meta = <_PmType, ({Color bg, Color fg, IconData icon})>{
    _PmType.nequi: (bg: Color(0xFFCEE6FD), fg: Color(0xFF000917), icon: Icons.phone_android_rounded),
    _PmType.bank: (bg: Color(0xFFD6E8D4), fg: Color(0xFF000D00), icon: Icons.account_balance_rounded),
    _PmType.efecty: (bg: Color(0xFFEAE3C8), fg: Color(0xFF0C0800), icon: Icons.payments_rounded),
    _PmType.card: (bg: Color(0xFFE1E2E4), fg: Color(0xFF08090A), icon: Icons.credit_card_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final m = _meta[method.type]!;

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
            children: <Widget>[
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: m.bg,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(m.icon, size: 22 * scale, color: m.fg),
              ),
              SizedBox(width: 14 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          method.label,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                        if (isPrimary) ...[
                          SizedBox(width: 8 * scale),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(99 * scale),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                              child: Text(
                                l10n.paymentDefault,
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
                    SizedBox(height: 3 * scale),
                    Text(
                      method.detail,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 13 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36 * scale,
                height: 36 * scale,
                alignment: Alignment.center,
                child: Icon(Icons.edit_rounded, size: 18 * scale, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMethods extends StatelessWidget {
  const _EmptyMethods({required this.scale, required this.onAdd});

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
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surfaceContainerHigh),
              child: Icon(Icons.credit_card_off_rounded, size: 32 * scale, color: colors.onSurfaceVariant),
            ),
            SizedBox(height: 16 * scale),
            Text(
              l10n.paymentNoneTitle,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 17 * scale,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              l10n.paymentNoneBody,
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
                  Text(l10n.paymentAdd),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({this.initial, required this.onSave, required this.onDelete});

  final _PaymentMethod? initial;
  final void Function(_PaymentMethod) onSave;
  final void Function(int) onDelete;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  late _PmType _type;
  late final TextEditingController _label;
  late final TextEditingController _detail;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initial?.type ?? _PmType.nequi;
    _label = TextEditingController(text: widget.initial?.label ?? '');
    _detail = TextEditingController(text: widget.initial?.detail ?? '');
  }

  @override
  void dispose() {
    _label.dispose();
    _detail.dispose();
    super.dispose();
  }

  void _save() {
    setState(() => _submitted = true);
    if (_label.text.trim().isEmpty || _detail.text.trim().isEmpty) return;
    widget.onSave(_PaymentMethod(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch,
      type: _type,
      label: _label.text.trim(),
      detail: _detail.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final types = <({_PmType type, String label, IconData icon})>[
      (type: _PmType.nequi, label: l10n.paymentTypeNequi, icon: Icons.phone_android_rounded),
      (type: _PmType.bank, label: l10n.paymentTypeBank, icon: Icons.account_balance_rounded),
      (type: _PmType.efecty, label: l10n.paymentTypeEfecty, icon: Icons.payments_rounded),
      (type: _PmType.card, label: l10n.paymentTypeCard, icon: Icons.credit_card_rounded),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
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
                widget.initial != null ? l10n.paymentEdit : l10n.paymentAdd,
                style: textTheme.headlineSmall?.copyWith(color: colors.onSurface, fontSize: 22),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: types.map((t) {
                  final selected = _type == t.type;
                  return GestureDetector(
                    onTap: () => setState(() => _type = t.type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? colors.primaryContainer : Colors.transparent,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: selected ? colors.primary : colors.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            t.icon,
                            size: 16,
                            color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t.label,
                            style: textTheme.labelMedium?.copyWith(
                              color: selected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _label,
                decoration: InputDecoration(
                  labelText: l10n.paymentLabelField,
                  errorText: _submitted && _label.text.trim().isEmpty ? l10n.paymentRequired : null,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _detail,
                decoration: InputDecoration(
                  labelText: l10n.paymentDetailField,
                  errorText: _submitted && _detail.text.trim().isEmpty ? l10n.paymentRequired : null,
                  border: const OutlineInputBorder(),
                ),
              ),
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
                  FilledButton(onPressed: _save, child: Text(l10n.addressSave)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _PmType { nequi, bank, efecty, card }

class _PaymentMethod {
  const _PaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    required this.detail,
  });

  final int id;
  final _PmType type;
  final String label;
  final String detail;
}
