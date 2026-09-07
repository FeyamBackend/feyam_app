import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/features/cart/domain/entities/cart_entity.dart';
import 'package:feyam/features/cart/domain/entities/cart_item_entity.dart';
import 'package:feyam/features/cart/presentation/screens/checkout_success_screen.dart';
import 'package:feyam/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:feyam/features/payments/domain/entities/checkout_pricing_entity.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.read<PaymentBloc>().add(const PaymentPricingRequested());
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
        _selectedAddressId != null &&
        shipments.any((a) => a.id == _selectedAddressId);
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

  /// Bottom sheet con las direcciones de envío disponibles para elegir.
  Future<void> _showAddressPicker(List<AddressEntity> shipments) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.checkoutAddress,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final a in shipments)
                _AddressOption(
                  address: a,
                  selected: a.id == _selectedAddressId,
                  onTap: () {
                    setState(() => _selectedAddressId = a.id);
                    Navigator.pop(sheetContext);
                  },
                ),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _addAddress();
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.addressAdd),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      case PaymentFailureCode.notFound:
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

            final busy =
                paymentState.status == PaymentStatus.processing ||
                paymentState.status == PaymentStatus.verifying;
            final pricingReady =
                paymentState.pricingStatus == CheckoutPricingStatus.loaded &&
                paymentState.pricing != null;
            final canPay = !busy && pricingReady && _selectedAddressId != null;
            final onPay = canPay
                ? () => context.read<PaymentBloc>().add(
                    PaymentCheckoutRequested(_selectedAddressId!),
                  )
                : null;
            void onRetryPricing() => context.read<PaymentBloc>().add(
              const PaymentPricingRequested(),
            );

            final addressSection = _AddressSummaryCard(
              status: addressState.status,
              shipments: shipments,
              selectedAddressId: _selectedAddressId,
              onEdit: () => _showAddressPicker(shipments),
              onAdd: _addAddress,
              onRetry: () {
                final lang = Localizations.localeOf(context).languageCode;
                context.read<AddressesBloc>().add(AddressesLoadRequested(lang));
              },
            );

            return _CheckoutContent(
              cart: widget.cart,
              pricingStatus: paymentState.pricingStatus,
              pricing: paymentState.pricing,
              onRetryPricing: onRetryPricing,
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

// ── Shipping address selection ────────────────────────────────────────────────

String _addressTitle(AddressEntity a) =>
    (a.recipient != null && a.recipient!.isNotEmpty)
    ? a.recipient!
    : a.lines.first;

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

AddressEntity? _selectedOf(List<AddressEntity> shipments, String? id) {
  for (final a in shipments) {
    if (a.id == id) return a;
  }
  return null;
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

/// Card que resume la dirección de envío seleccionada, con acceso a un
/// selector (bottom sheet) cuando hay más de una guardada.
class _AddressSummaryCard extends StatelessWidget {
  const _AddressSummaryCard({
    required this.status,
    required this.shipments,
    required this.selectedAddressId,
    required this.onEdit,
    required this.onAdd,
    required this.onRetry,
  });

  final AddressesStatus status;
  final List<AddressEntity> shipments;
  final String? selectedAddressId;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget body;
    Widget? action;

    if (status == AddressesStatus.loading && shipments.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ),
      );
    } else if (status == AddressesStatus.failure && shipments.isEmpty) {
      body = Text(
        l10n.addressLoadError,
        style: textTheme.bodySmall?.copyWith(color: colors.error, height: 1.4),
      );
      action = TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ),
        onPressed: onRetry,
        child: Text(l10n.addressRetry),
      );
    } else if (shipments.isEmpty) {
      body = Text(
        l10n.checkoutNoShippingAddress,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
          height: 1.4,
        ),
      );
      action = TextButton.icon(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ),
        onPressed: onAdd,
        icon: const Icon(Icons.add_location_alt_rounded, size: 16),
        label: Text(l10n.addressAdd),
      );
    } else {
      final selected =
          _selectedOf(shipments, selectedAddressId) ?? shipments.first;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _addressTitle(selected),
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _addressSubtitle(selected),
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
              fontSize: 12.5,
            ),
          ),
        ],
      );
      action = TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
        ),
        onPressed: onEdit,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.checkoutEdit,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: colors.primary),
          ],
        ),
      );
    }

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoCardHeader(
            icon: Icons.location_on_rounded,
            iconColor: colors.secondary,
            iconBg: colors.secondaryContainer,
            title: l10n.checkoutAddress,
            action: action,
          ),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}

// ── Shared card chrome ────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _InfoCardHeader extends StatelessWidget {
  const _InfoCardHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        ?action,
      ],
    );
  }
}

// ── Retailer badge (derivado de la URL del producto) ──────────────────────────

({String name, Color color}) _storeInfoFromUrl(String url, String fallback) {
  String host;
  try {
    host = Uri.parse(url).host.toLowerCase().replaceFirst('www.', '');
  } catch (_) {
    return (name: fallback, color: const Color(0xFF6B7280));
  }
  if (host.isEmpty) return (name: fallback, color: const Color(0xFF6B7280));
  if (host.contains('amazon'))
    return (name: 'Amazon', color: const Color(0xFFFF9900));
  if (host.contains('ebay'))
    return (name: 'eBay', color: const Color(0xFFE53238));
  if (host.contains('walmart'))
    return (name: 'Walmart', color: const Color(0xFF0071DC));
  if (host.contains('bestbuy'))
    return (name: 'Best Buy', color: const Color(0xFF0A4ABF));
  if (host.contains('target'))
    return (name: 'Target', color: const Color(0xFFCC0000));
  if (host.contains('aliexpress')) {
    return (name: 'AliExpress', color: const Color(0xFFE62E04));
  }
  final base = host.split('.').first;
  if (base.isEmpty) return (name: fallback, color: const Color(0xFF6B7280));
  final name = '${base[0].toUpperCase()}${base.substring(1)}';
  return (name: name, color: const Color(0xFF6B7280));
}

class _StoreBadge extends StatelessWidget {
  const _StoreBadge({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Hero header ────────────────────────────────────────────────────────────────

// ── Checkout content ──────────────────────────────────────────────────────────

class _CheckoutContent extends StatelessWidget {
  const _CheckoutContent({
    required this.cart,
    required this.pricingStatus,
    required this.pricing,
    required this.onRetryPricing,
    required this.busy,
    required this.verifying,
    required this.onPay,
    required this.addressSection,
  });

  final CartEntity cart;
  final CheckoutPricingStatus pricingStatus;
  final CheckoutPricingEntity? pricing;
  final VoidCallback onRetryPricing;
  final bool busy;
  final bool verifying;
  final VoidCallback? onPay;
  final Widget addressSection;

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
                title: l10n.checkoutHeroTitle,
                titleFontSize: 26,
                subtitle: l10n.checkoutHeroSubtitle,
                trailing: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    AdaptivePlatform.pageRoute<void>(
                      context: context,
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: colors.onPrimary,
                    size: 22 * scale,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    16 * scale,
                    16 * scale,
                    24 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      addressSection,
                      SizedBox(height: 14 * scale),
                      _PayMethodCard(l10n: l10n),
                      SizedBox(height: 14 * scale),
                      _ShippingMethodCard(l10n: l10n),
                      SizedBox(height: 14 * scale),
                      _ItemsSummaryCard(l10n: l10n, cart: cart),
                      SizedBox(height: 14 * scale),
                      _InfoCard(
                        child: _PriceBreakdown(
                          status: pricingStatus,
                          pricing: pricing,
                          onRetry: onRetryPricing,
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      _CouponRow(l10n: l10n),
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
                  padding: EdgeInsets.fromLTRB(
                    16 * scale,
                    12 * scale,
                    16 * scale,
                    16 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (onPay == null &&
                          !busy &&
                          pricingStatus == CheckoutPricingStatus.loaded) ...[
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
                            pricing != null
                                ? _formatCurrency(pricing!.total)
                                : '—',
                            style: textTheme.titleLarge?.copyWith(
                              color: colors.secondary,
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
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation(
                                      colors.onSecondary,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.lock_rounded),
                          label: Text(
                            busy
                                ? (verifying
                                      ? l10n.checkoutVerifying
                                      : l10n.checkoutProcessing)
                                : l10n.checkoutConfirm,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.secondary,
                            foregroundColor: colors.onSecondary,
                            textStyle: textTheme.labelLarge?.copyWith(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: const StadiumBorder(),
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

/// Card estática con información sobre cómo se procesa el pago. La app no
/// guarda tarjetas: Stripe gestiona la selección/entrada de la tarjeta en su
/// propio sheet nativo al confirmar el pedido.
class _PayMethodCard extends StatelessWidget {
  const _PayMethodCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoCardHeader(
            icon: Icons.credit_card_rounded,
            iconColor: colors.primary,
            iconBg: colors.primaryContainer,
            title: l10n.checkoutPayMethod,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.checkoutPayMethodDesc,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card estática con el único método de envío que ofrece Feyam hoy. No hay
/// selector porque no existen otras opciones de envío en el backend.
class _ShippingMethodCard extends StatelessWidget {
  const _ShippingMethodCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoCardHeader(
            icon: Icons.local_shipping_rounded,
            iconColor: colors.secondary,
            iconBg: colors.secondaryContainer,
            title: l10n.checkoutShippingMethodTitle,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.checkoutShippingStandardLabel,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n.checkoutDelivery}: ${l10n.checkoutDeliveryTime}',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsSummaryCard extends StatelessWidget {
  const _ItemsSummaryCard({required this.l10n, required this.cart});

  final AppLocalizations l10n;
  final CartEntity cart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoCardHeader(
            icon: Icons.shopping_bag_rounded,
            iconColor: colors.primary,
            iconBg: colors.primaryContainer,
            title:
                '${l10n.checkoutSummary} '
                '(${cart.items.length} ${l10n.checkoutProductsUnit})',
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < cart.items.length; i++) ...<Widget>[
            _ItemRow(l10n: l10n, item: cart.items[i]),
            if (i != cart.items.length - 1) ...<Widget>[
              const SizedBox(height: 10),
              Divider(height: 1, color: colors.outlineVariant),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.l10n, required this.item});

  final AppLocalizations l10n;
  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final store = _storeInfoFromUrl(item.productUrl, l10n.checkoutGenericStore);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.productImageUrl != null
              ? Image.network(
                  item.productImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.inventory_2_rounded,
                    size: 24,
                    color: colors.onSurfaceVariant,
                  ),
                )
              : Icon(
                  Icons.inventory_2_rounded,
                  size: 24,
                  color: colors.onSurfaceVariant,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _StoreBadge(name: store.name, color: store.color),
              const SizedBox(height: 4),
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${l10n.addToCartQuantityLabel}: ${item.quantity}',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatCurrency(item.totalPrice),
          style: textTheme.bodyLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// Desglose de precio. Los montos vienen siempre de [pricing]
/// (GET /api/payments/checkout/pricing) — nunca se calculan en el cliente,
/// para que jamás difieran del monto que Stripe cobra.
class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({
    required this.status,
    required this.pricing,
    required this.onRetry,
  });

  final CheckoutPricingStatus status;
  final CheckoutPricingEntity? pricing;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (status == CheckoutPricingStatus.failure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.checkoutPriceLoadError,
            style: textTheme.bodyMedium?.copyWith(color: colors.error),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onRetry,
              child: Text(l10n.checkoutPriceRetry),
            ),
          ),
        ],
      );
    }

    if (status != CheckoutPricingStatus.loaded || pricing == null) {
      return Row(
        children: <Widget>[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.checkoutPriceLoading,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final p = pricing!;
    return Column(
      children: <Widget>[
        _PriceRow(
          k: l10n.checkoutSubtotal,
          v: _formatCurrency(p.productsAmount),
        ),
        _PriceRow(k: l10n.checkoutService, v: _formatCurrency(p.feyamFee)),
        _PriceRow(
          k: l10n.checkoutShipping,
          v: _formatCurrency(p.estimatedLogistics),
        ),
        Divider(height: 24, color: colors.outlineVariant),
        _PriceRow(
          k: l10n.checkoutTotal,
          v: _formatCurrency(p.total),
          strong: true,
          accent: true,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                l10n.checkoutDisclaimer,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.k,
    required this.v,
    this.strong = false,
    this.accent = false,
  });

  final String k;
  final String v;
  final bool strong;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              k,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: strong ? colors.onSurface : colors.onSurfaceVariant,
                fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
                fontSize: strong ? 15 : 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            v,
            style: textTheme.bodyLarge?.copyWith(
              color: accent ? colors.secondary : colors.onSurface,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
              fontSize: strong ? 17 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de cupón/nota deshabilitada: la funcionalidad todavía no existe en el
/// backend, así que se muestra atenuada con un rótulo "Próximamente" en vez de
/// simular un flujo que no lleva a ningún lado.
class _CouponRow extends StatelessWidget {
  const _CouponRow({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimmed = colors.onSurfaceVariant.withValues(alpha: 0.6);

    return _InfoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Icon(Icons.sell_outlined, size: 18, color: dimmed),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.checkoutCouponTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: dimmed,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.checkoutCouponSoon,
                  style: textTheme.bodySmall?.copyWith(
                    color: dimmed,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: dimmed),
        ],
      ),
    );
  }
}

String _formatCurrency(double v) =>
    '\$ ${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
