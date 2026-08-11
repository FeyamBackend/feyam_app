import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/features/payments/domain/entities/payment_method_entity.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_methods_bloc.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_methods_event.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_methods_state.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaymentMethodsBloc>().add(const PaymentMethodsLoadRequested());
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  void _requestAdd() {
    context.read<PaymentMethodsBloc>().add(const PaymentMethodAddRequested());
  }

  Future<void> _confirmDelete(PaymentMethodEntity method) async {
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<PaymentMethodsBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.paymentDeleteConfirmTitle),
        content: Text(l10n.paymentDeleteConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.addressCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: Text(l10n.addressDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(PaymentMethodDeleteRequested(method.id));
    }
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
          body: Column(
            children: <Widget>[
              FeyamHeroHeader(
                scale: scale,
                showBackButton: true,
                title: l10n.paymentTitle,
              ),
              Expanded(
                child: BlocConsumer<PaymentMethodsBloc, PaymentMethodsState>(
                  listenWhen: (prev, curr) =>
                      prev.actionStatus != curr.actionStatus,
                  listener: (context, state) {
                    switch (state.actionStatus) {
                      case PaymentMethodActionStatus.success:
                        switch (state.actionKind) {
                          case PaymentMethodActionKind.delete:
                            _toast(l10n.paymentDeleteSuccess);
                          case PaymentMethodActionKind.setDefault:
                            _toast(l10n.paymentSetDefaultSuccess);
                          case PaymentMethodActionKind.add:
                          case PaymentMethodActionKind.none:
                            break;
                        }
                      case PaymentMethodActionStatus.failure:
                        switch (state.actionKind) {
                          case PaymentMethodActionKind.add:
                            _toast(l10n.paymentAddError);
                          case PaymentMethodActionKind.delete:
                            _toast(l10n.paymentDeleteError);
                          case PaymentMethodActionKind.setDefault:
                            _toast(l10n.paymentSetDefaultError);
                          case PaymentMethodActionKind.none:
                            break;
                        }
                      case PaymentMethodActionStatus.idle:
                      case PaymentMethodActionStatus.inProgress:
                      case PaymentMethodActionStatus.cancelled:
                        break;
                    }
                  },
                  builder: (context, state) {
                    if (state.status == PaymentMethodsStatus.loading &&
                        state.paymentMethods.isEmpty) {
                      return Center(
                        child: SizedBox(
                          width: 28 * scale,
                          height: 28 * scale,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.primary,
                          ),
                        ),
                      );
                    }

                    if (state.status == PaymentMethodsStatus.failure &&
                        state.paymentMethods.isEmpty) {
                      return _ErrorState(
                        scale: scale,
                        message: l10n.paymentLoadError,
                        onRetry: () => context.read<PaymentMethodsBloc>().add(
                          const PaymentMethodsLoadRequested(),
                        ),
                      );
                    }

                    final adding =
                        state.actionStatus ==
                            PaymentMethodActionStatus.inProgress &&
                        state.actionKind == PaymentMethodActionKind.add;

                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16 * scale,
                            14 * scale,
                            16 * scale,
                            0,
                          ),
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
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 18 * scale,
                                    color: colors.onTertiaryContainer,
                                  ),
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
                          child: state.paymentMethods.isEmpty
                              ? _EmptyMethods(
                                  scale: scale,
                                  onAdd: adding ? null : _requestAdd,
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(16 * scale),
                                  itemCount: state.paymentMethods.length,
                                  itemBuilder: (context, index) {
                                    final method = state.paymentMethods[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 10 * scale,
                                      ),
                                      child: _MethodCard(
                                        scale: scale,
                                        method: method,
                                        onSetDefault: () => context
                                            .read<PaymentMethodsBloc>()
                                            .add(
                                              PaymentMethodSetDefaultRequested(
                                                method.id,
                                              ),
                                            ),
                                        onDelete: () => _confirmDelete(method),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (state.paymentMethods.isNotEmpty)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              border: Border(
                                top: BorderSide(color: colors.outlineVariant),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16 * scale,
                                12 * scale,
                                16 * scale,
                                20 * scale,
                              ),
                              child: SizedBox(
                                height: 48 * scale,
                                child: FilledButton.tonal(
                                  onPressed: adding ? null : _requestAdd,
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        12 * scale,
                                      ),
                                    ),
                                    textStyle: textTheme.labelLarge?.copyWith(
                                      fontSize: 15 * scale,
                                    ),
                                  ),
                                  child: adding
                                      ? SizedBox(
                                          width: 20 * scale,
                                          height: 20 * scale,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.onSecondaryContainer,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.add_rounded,
                                              size: 20 * scale,
                                            ),
                                            SizedBox(width: 8 * scale),
                                            Text(l10n.paymentAdd),
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
    required this.onSetDefault,
    required this.onDelete,
  });

  final double scale;
  final PaymentMethodEntity method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final expiry =
        '${method.expMonth.toString().padLeft(2, '0')}/'
        '${(method.expYear % 100).toString().padLeft(2, '0')}';

    return DecoratedBox(
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
        padding: EdgeInsets.all(14 * scale),
        child: Row(
          children: <Widget>[
            Container(
              width: 44 * scale,
              height: 44 * scale,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Icon(
                Icons.credit_card_rounded,
                size: 22 * scale,
                color: colors.onSurface,
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
                          '${_capitalize(method.brand)} •••• ${method.last4}',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 15 * scale,
                          ),
                        ),
                      ),
                      if (method.isDefault) ...[
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
                    '${l10n.paymentExpiryLabel} $expiry',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 13 * scale,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<_MethodMenuAction>(
              icon: Icon(
                Icons.more_vert_rounded,
                size: 20 * scale,
                color: colors.onSurfaceVariant,
              ),
              onSelected: (action) {
                switch (action) {
                  case _MethodMenuAction.setDefault:
                    onSetDefault();
                  case _MethodMenuAction.delete:
                    onDelete();
                }
              },
              itemBuilder: (context) => <PopupMenuEntry<_MethodMenuAction>>[
                if (!method.isDefault)
                  PopupMenuItem(
                    value: _MethodMenuAction.setDefault,
                    child: Text(l10n.paymentSetDefault),
                  ),
                PopupMenuItem(
                  value: _MethodMenuAction.delete,
                  child: Text(
                    l10n.addressDelete,
                    style: TextStyle(color: colors.error),
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

enum _MethodMenuAction { setDefault, delete }

class _EmptyMethods extends StatelessWidget {
  const _EmptyMethods({required this.scale, required this.onAdd});

  final double scale;
  final VoidCallback? onAdd;

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
            Icon(
              Icons.credit_card_off_rounded,
              size: 56 * scale,
              color: colors.onSurfaceVariant,
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
              child: onAdd == null
                  ? SizedBox(
                      width: 18 * scale,
                      height: 18 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onSecondaryContainer,
                      ),
                    )
                  : Row(
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
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 14 * scale,
              ),
            ),
            SizedBox(height: 12 * scale),
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
