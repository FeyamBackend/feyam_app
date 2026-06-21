import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/entities/cart_item_entity.dart';
import 'package:feyam/features/cart/presentation/screens/checkout_success_screen.dart';
import 'package:feyam/features/payments/domain/failures/payment_failure.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_event.dart';
import 'package:feyam/features/payments/presentation/bloc/payment_state.dart';
import 'package:feyam/features/profile/domain/entities/address_entity.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_bloc.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_event.dart';
import 'package:feyam/features/profile/presentation/bloc/addresses_state.dart';
import 'package:feyam/features/profile/presentation/screens/addresses_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const double _kEstimatedShipping = 18.50;

/// Backend AddressType for shipping addresses (only these are valid at checkout).
const String _kShipmentType = 'Shipment';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({required this.cart, super.key});

  final CartEntity cart;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
        BlocProvider<AddressesBloc>(create: (_) => sl<AddressesBloc>()),
      ],
      child: _CheckoutView(cart: cart),
    );
  }
}

class _CheckoutView extends StatefulWidget {
  const _CheckoutView({required this.cart});

  final CartEntity cart;

  @override
  State<_CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<_CheckoutView> {
  /// Dirección de envío seleccionada. Hasta que haya una, no se permite pagar.
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    // El locale se lee tras el primer frame (Localizations no está en initState).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final lang = Localizations.localeOf(context).languageCode;
      context.read<AddressesBloc>().add(AddressesLoadRequested(lang));
    });
  }

  List<AddressEntity> _shipmentsOf(AddressesState state) =>
      state.addresses.where((a) => a.type == _kShipmentType).toList();

  /// Autoselecciona la primera dirección de envío y descarta una selección que
  /// ya no exista (p. ej. tras borrarla).
  void _syncSelection(List<AddressEntity> shipments) {
    final stillValid =
        _selectedAddressId != null && shipments.any((a) => a.id == _selectedAddressId);
    if (stillValid) return;
    final next = shipments.isNotEmpty ? shipments.first.id : null;
    if (next != _selectedAddressId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedAddressId = next);
      });
    }
  }

  Future<void> _addAddress() async {
    // Reutiliza la pantalla de gestión de direcciones (con su propio bloc).
    await Navigator.push(
      context,
      AdaptivePlatform.pageRoute<void>(
        context: context,
        builder: (_) => BlocProvider<AddressesBloc>(
          create: (_) => sl<AddressesBloc>(),
          child: const AddressesScreen(),
        ),
      ),
    );
    if (!mounted) return;
    // Al volver, recargamos para reflejar lo que el usuario haya creado.
    final lang = Localizations.localeOf(context).languageCode;
    context.read<AddressesBloc>().add(AddressesLoadRequested(lang));
  }

  void _onState(BuildContext context, PaymentState state) {
    final l10n = AppLocalizations.of(context)!;
    switch (state.status) {
      case PaymentStatus.success:
        Navigator.pushReplacement(
          context,
          AdaptivePlatform.pageRoute<void>(
            context: context,
            builder: (_) => const CheckoutSuccessScreen(),
          ),
        );
      case PaymentStatus.pendingConfirmation:
        // El cobro se realizó; el backend lo confirmará por webhook.
        Navigator.pushReplacement(
          context,
          AdaptivePlatform.pageRoute<void>(
            context: context,
            builder: (_) => const CheckoutSuccessScreen(pending: true),
          ),
        );
      case PaymentStatus.cancelled:
        // El usuario cerró el sheet a propósito: volvemos sin error intrusivo.
        break;
      case PaymentStatus.failure:
        {
          final code = state.failure?.code;
          if (code == PaymentFailureCode.sessionExpired ||
              code == PaymentFailureCode.unauthorized) {
            // El logout es global (AuthenticatedHttpClient → AuthBloc): no
            // mostramos diálogo, MainScreen navega a LoginScreen.
            break;
          }
          _showError(context, _failureMessage(l10n, state.failure));
        }
      case PaymentStatus.initial:
      case PaymentStatus.processing:
      case PaymentStatus.verifying:
        break;
    }
  }

  String _failureMessage(AppLocalizations l10n, PaymentFailure? failure) {
    switch (failure?.code) {
      case PaymentFailureCode.networkError:
        return l10n.paymentErrorNetwork;
      case PaymentFailureCode.sessionExpired:
      case PaymentFailureCode.unauthorized:
        return l10n.paymentErrorSession;
      case PaymentFailureCode.cancelled:
        return l10n.paymentCancelled;
      case PaymentFailureCode.serverError:
      case PaymentFailureCode.unknown:
      case null:
        return l10n.paymentErrorGeneric;
    }
  }

  void _showError(BuildContext context, String message) {
    showAdaptiveDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentBloc, PaymentState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _onState,
      builder: (context, paymentState) {
        return BlocBuilder<AddressesBloc, AddressesState>(
          builder: (context, addressState) {
            final shipments = _shipmentsOf(addressState);
            _syncSelection(shipments);

            final busy = paymentState.status == PaymentStatus.processing ||
                paymentState.status == PaymentStatus.verifying;
            final canPay = !busy && _selectedAddressId != null;
            final onPay = canPay
                ? () => context
                    .read<PaymentBloc>()
                    .add(PaymentCheckoutRequested(_selectedAddressId!))
                : null;

            final addressSection = _AddressSelection(
              status: addressState.status,
              shipments: shipments,
              selectedAddressId: _selectedAddressId,
              onSelect: (id) => setState(() => _selectedAddressId = id),
              onAdd: _addAddress,
              onRetry: () {
                final lang = Localizations.localeOf(context).languageCode;
                context.read<AddressesBloc>().add(AddressesLoadRequested(lang));
              },
            );

            if (AdaptivePlatform.isCupertino(context)) {
              return _CupertinoCheckoutContent(
                cart: widget.cart,
                busy: busy,
                verifying: paymentState.status == PaymentStatus.verifying,
                onPay: onPay,
                addressSection: addressSection,
              );
            }

            return _MaterialCheckoutContent(
              cart: widget.cart,
              busy: busy,
              verifying: paymentState.status == PaymentStatus.verifying,
              onPay: onPay,
              addressSection: addressSection,
            );
          },
        );
      },
    );
  }
}

// ── Shipping address selection (adaptive) ──────────────────────────────────────

String _addressTitle(AddressEntity a) =>
    (a.recipient != null && a.recipient!.isNotEmpty) ? a.recipient! : a.lines.first;

String _addressSubtitle(AddressEntity a) {
  final parts = <String>[
    if (a.recipient != null && a.recipient!.isNotEmpty)
      ...a.lines
    else
      ...a.lines.skip(1),
    ...a.subdivisions.map((s) => s.name),
    if (a.zipCode != null && a.zipCode!.isNotEmpty) a.zipCode!,
    a.countryCode,
  ];
  return parts.join(', ');
}

/// Selector adaptive de dirección de envío. Bloquea el pago cuando no hay
/// ninguna seleccionada (la responsabilidad de deshabilitar el botón vive en
/// el padre, que pone onPay = null sin selección).
class _AddressSelection extends StatelessWidget {
  const _AddressSelection({
    required this.status,
    required this.shipments,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onAdd,
    required this.onRetry,
  });

  final AddressesStatus status;
  final List<AddressEntity> shipments;
  final String? selectedAddressId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cupertino = AdaptivePlatform.isCupertino(context);

    if (status == AddressesStatus.loading && shipments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: cupertino
              ? const CupertinoActivityIndicator()
              : const CircularProgressIndicator(),
        ),
      );
    }

    if (status == AddressesStatus.failure && shipments.isEmpty) {
      return _AddressMessageCard(
        message: l10n.addressLoadError,
        actionLabel: l10n.addressRetry,
        onAction: onRetry,
      );
    }

    if (shipments.isEmpty) {
      return _AddressMessageCard(
        message: l10n.checkoutNoShippingAddress,
        actionLabel: l10n.addressAdd,
        onAction: onAdd,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final a in shipments)
          _AddressOption(
            address: a,
            selected: a.id == selectedAddressId,
            onTap: () => onSelect(a.id),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: cupertino
              ? CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onPressed: onAdd,
                  child: Text(l10n.addressAdd),
                )
              : TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.addressAdd),
                ),
        ),
      ],
    );
  }
}

class _AddressOption extends StatelessWidget {
  const _AddressOption({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final AddressEntity address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? colors.primaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _addressTitle(address),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _addressSubtitle(address),
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
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

class _AddressMessageCard extends StatelessWidget {
  const _AddressMessageCard({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                onPressed: onAction,
                icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                label: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Material ──────────────────────────────────────────────────────────────────

class _MaterialCheckoutContent extends StatelessWidget {
  const _MaterialCheckoutContent({
    required this.cart,
    required this.busy,
    required this.verifying,
    required this.onPay,
    required this.addressSection,
  });

  final CartEntity cart;
  final bool busy;
  final bool verifying;
  final VoidCallback? onPay;
  final Widget addressSection;

  double get _subtotal => cart.total;
  double get _total => _subtotal + _kEstimatedShipping;

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
              l10n.checkoutTitle,
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    14 * scale,
                    16 * scale,
                    24 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutAddress,
                        child: addressSection,
                      ),
                      SizedBox(height: 20 * scale),
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutSummary,
                        child: Column(
                          children: cart.items
                              .map((it) => Padding(
                                    padding: EdgeInsets.only(bottom: 8 * scale),
                                    child: _ItemRow(scale: scale, item: it),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutPayMethod,
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
                                  Icons.credit_card_rounded,
                                  size: 20 * scale,
                                  color: colors.onTertiaryContainer,
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Text(
                                    l10n.cartSecurePayment,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colors.onTertiaryContainer,
                                      fontSize: 13 * scale,
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      _CoSection(
                        scale: scale,
                        label: l10n.checkoutEstPrice,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14 * scale),
                            child: Column(
                              children: <Widget>[
                                _PriceRow(scale: scale, k: l10n.checkoutSubtotal, v: _fmt(_subtotal)),
                                _PriceRow(scale: scale, k: l10n.checkoutShipping, v: _fmt(_kEstimatedShipping)),
                                Divider(height: 1 + 16 * scale, color: colors.outlineVariant),
                                _PriceRow(
                                  scale: scale,
                                  k: l10n.checkoutTotal,
                                  v: _fmt(_total),
                                  strong: true,
                                  accent: true,
                                ),
                                SizedBox(height: 10 * scale),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 13 * scale,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    SizedBox(width: 5 * scale),
                                    Expanded(
                                      child: Text(
                                        l10n.checkoutDisclaimer,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 11 * scale,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(top: BorderSide(color: colors.outlineVariant)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (onPay == null && !busy) ...[
                        Text(
                          l10n.checkoutSelectAddress,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 12 * scale,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            l10n.checkoutTotal,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 13 * scale,
                            ),
                          ),
                          Text(
                            _fmt(_total),
                            style: textTheme.titleLarge?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18 * scale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12 * scale),
                      SizedBox(
                        height: 52 * scale,
                        child: FilledButton.icon(
                          onPressed: onPay,
                          icon: busy
                              ? SizedBox(
                                  width: 18 * scale,
                                  height: 18 * scale,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.lock_rounded),
                          label: Text(
                            busy
                                ? (verifying
                                    ? l10n.checkoutVerifying
                                    : l10n.checkoutProcessing)
                                : l10n.checkoutPayButton,
                          ),
                          style: FilledButton.styleFrom(
                            textStyle: textTheme.labelLarge?.copyWith(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
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

  String _fmt(double v) => _formatCurrency(v);
}

class _CoSection extends StatelessWidget {
  const _CoSection({required this.scale, required this.label, required this.child});

  final double scale;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 2 * scale, bottom: 8 * scale),
          child: Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 11 * scale,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.scale, required this.item});

  final double scale;
  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
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
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Icon(Icons.inventory_2_rounded, size: 24 * scale, color: colors.onSurfaceVariant),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.productName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 14 * scale,
                      height: 1.35,
                    ),
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    SizedBox(height: 2 * scale),
                    Text(
                      item.notes!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                  SizedBox(height: 4 * scale),
                  Text(
                    '${l10n.addToCartQuantityLabel}: ${item.quantity}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 12 * scale,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatCurrency(item.totalPrice),
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 15 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.scale,
    required this.k,
    required this.v,
    this.strong = false,
    this.accent = false,
  });

  final double scale;
  final String k;
  final String v;
  final bool strong;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            k,
            style: textTheme.bodyMedium?.copyWith(
              color: strong ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
              fontSize: strong ? 15 * scale : 13 * scale,
            ),
          ),
          Text(
            v,
            style: textTheme.bodyLarge?.copyWith(
              color: accent ? colors.primary : colors.onSurface,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
              fontSize: strong ? 17 * scale : 13 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cupertino ─────────────────────────────────────────────────────────────────

class _CupertinoCheckoutContent extends StatelessWidget {
  const _CupertinoCheckoutContent({
    required this.cart,
    required this.busy,
    required this.verifying,
    required this.onPay,
    required this.addressSection,
  });

  final CartEntity cart;
  final bool busy;
  final bool verifying;
  final VoidCallback? onPay;
  final Widget addressSection;

  double get _subtotal => cart.total;
  double get _total => _subtotal + _kEstimatedShipping;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return ColoredBox(
          color: kFeyamBg,
          child: Column(
            children: <Widget>[
              CupertinoNavigationBar(
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(CupertinoIcons.chevron_back, size: 18),
                      const SizedBox(width: 2),
                      Text(l10n.navCart, style: const TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
                middle: Text(l10n.checkoutTitle),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 8 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 16 * scale),
                      FeyamListSection(
                        header: l10n.checkoutAddress,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(16 * scale),
                            child: addressSection,
                          ),
                        ],
                      ),
                      FeyamListSection(
                        header: l10n.checkoutSummary,
                        children: <Widget>[
                          for (var i = 0; i < cart.items.length; i++)
                            FeyamListTile(
                              title: Text(cart.items[i].productName),
                              subtitle: Text(
                                '${l10n.addToCartQuantityLabel}: ${cart.items[i].quantity}',
                              ),
                              detail: Text(_formatCurrency(cart.items[i].totalPrice)),
                              chevron: false,
                              isLast: i == cart.items.length - 1,
                            ),
                        ],
                      ),
                      FeyamListSection(
                        header: l10n.checkoutEstPrice,
                        children: <Widget>[
                          FeyamListTile(
                            title: Text(l10n.checkoutSubtotal),
                            detail: Text(_formatCurrency(_subtotal)),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: Text(l10n.checkoutShipping),
                            detail: Text(_formatCurrency(_kEstimatedShipping)),
                            chevron: false,
                          ),
                          FeyamListTile(
                            title: Text(
                              l10n.checkoutTotal,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            detail: Text(
                              _formatCurrency(_total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: kFeyamTint,
                              ),
                            ),
                            chevron: false,
                            isLast: true,
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(32 * scale, 4, 32 * scale, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(CupertinoIcons.info_circle, size: 14, color: kFeyamLabelTer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.checkoutDisclaimer,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: kFeyamLabelTer,
                                  height: 1.4,
                                  fontFamily: '.SF Pro Text',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 28 * scale),
                decoration: const BoxDecoration(
                  color: kFeyamCard,
                  border: Border(top: BorderSide(color: kFeyamSepLight, width: 0.5)),
                ),
                child: busy
                    ? Column(
                        children: <Widget>[
                          const CupertinoActivityIndicator(),
                          SizedBox(height: 8 * scale),
                          Text(
                            verifying ? l10n.checkoutVerifying : l10n.checkoutProcessing,
                            style: const TextStyle(fontSize: 13, color: kFeyamLabelSec),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (onPay == null) ...[
                            Text(
                              l10n.checkoutSelectAddress,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: kFeyamLabelSec),
                            ),
                            SizedBox(height: 8 * scale),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: FeyamButton(
                              label: l10n.checkoutPayButton,
                              icon: CupertinoIcons.lock_fill,
                              onPressed: onPay ?? () {},
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String _formatCurrency(double v) =>
    '\$ ${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
