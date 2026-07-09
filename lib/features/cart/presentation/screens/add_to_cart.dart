import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/cart/domain/failures/cart_failure.dart';
import 'package:feyam/features/cart/domain/usecases/get_cart.dart';
import 'package:feyam/features/cart/presentation/bloc/add_to_cart_bloc.dart';
import 'package:feyam/features/cart/presentation/bloc/add_to_cart_event.dart';
import 'package:feyam/features/cart/presentation/bloc/add_to_cart_state.dart';
import 'package:feyam/features/cart/presentation/screens/checkout_screen.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// ── MD3 design tokens ────────────────────────────────────────────────────────
const _kSurface = Color(0xFFF7F8FB);
const _kCard = Color(0xFFFFFFFF);
const _kPrimary = Color(0xFF005997);
const _kPrimaryTint = Color(0x14005997);
const _kOnSurface = Color(0xFF1A1C1E);
const _kOnSurfaceVar = Color(0xFF5A5F66);
const _kOutline = Color(0xFFDDE1EA);
const _kGreen = Color(0xFF3E7A18);
const _kGreenTint = Color(0x1F5FA121);

String _storeNameFromUrl(String url) {
  try {
    final host = Uri.parse(url).host.toLowerCase();
    if (host.contains('amazon')) return 'Amazon';
    if (host.contains('ebay')) return 'eBay';
    if (host.contains('walmart')) return 'Walmart';
    if (host.contains('bestbuy')) return 'Best Buy';
    if (host.contains('target')) return 'Target';
    if (host.contains('aliexpress')) return 'AliExpress';
    return host.replaceFirst('www.', '').split('.').first;
  } catch (_) {
    return 'Store';
  }
}

String _shortenUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final host = uri.host.replaceFirst('www.', '');
    final path = uri.path;
    final full = '$host$path';
    return full.length > 32 ? '${full.substring(0, 32)}…' : full;
  } catch (_) {
    return url.length > 32 ? '${url.substring(0, 32)}…' : url;
  }
}

// ── Public entry point ────────────────────────────────────────────────────────

class AddToCartScreen extends StatelessWidget {
  const AddToCartScreen({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddToCartBloc>(),
      child: _AddToCartView(initialUrl: initialUrl),
    );
  }
}

class _AddToCartView extends StatefulWidget {
  const _AddToCartView({this.initialUrl});

  final String? initialUrl;

  @override
  State<_AddToCartView> createState() => _AddToCartViewState();
}

class _AddToCartViewState extends State<_AddToCartView> {
  final _productNameController = TextEditingController();
  late final _urlController = TextEditingController(
    text: widget.initialUrl ?? '',
  );
  final _priceController = TextEditingController();

  // Material: quantity stepper + talla/color fields + notes field
  int _quantity = 1;
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  bool _sizeNotApplicable = false;
  bool _colorNotApplicable = false;
  String? _sizeError;
  String? _colorError;
  final _notesController = TextEditingController();

  bool _pendingCheckout = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _urlController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Submit helpers ────────────────────────────────────────────────────────

  bool _validateVariants(AppLocalizations l10n) {
    setState(() {
      _sizeError =
          (!_sizeNotApplicable && _sizeController.text.trim().isEmpty)
              ? l10n.addToCartSizeRequiredError
              : null;
      _colorError =
          (!_colorNotApplicable && _colorController.text.trim().isEmpty)
              ? l10n.addToCartColorRequiredError
              : null;
    });
    return _sizeError == null && _colorError == null;
  }

  Map<String, String> _buildVariantAttributes(
    AppLocalizations l10n, {
    required bool sizeNotApplicable,
    required bool colorNotApplicable,
    required String sizeText,
    required String colorText,
  }) {
    return {
      l10n.addToCartSizeLabel:
          sizeNotApplicable ? l10n.addToCartNotApplicable : sizeText,
      l10n.addToCartColorLabel:
          colorNotApplicable ? l10n.addToCartNotApplicable : colorText,
    };
  }

  void _submitMaterial({required bool checkout}) {
    final l10n = AppLocalizations.of(context)!;
    if (!_validateVariants(l10n)) return;
    _pendingCheckout = checkout;
    final notesText = _notesController.text.trim();
    context.read<AddToCartBloc>().add(
          AddToCartSubmitted(
            productName: _productNameController.text.trim(),
            productUrl: _urlController.text.trim(),
            quantity: _quantity,
            unitPriceAmount:
                double.tryParse(_priceController.text) ?? 0.0,
            notes: notesText.isEmpty ? null : notesText,
            variantAttributes: _buildVariantAttributes(
              l10n,
              sizeNotApplicable: _sizeNotApplicable,
              colorNotApplicable: _colorNotApplicable,
              sizeText: _sizeController.text.trim(),
              colorText: _colorController.text.trim(),
            ),
          ),
        );
  }

  // Cupertino submit path
  void _submit(int qty, Map<String, String> variantAttributes) {
    context.read<AddToCartBloc>().add(
          AddToCartSubmitted(
            productName: _productNameController.text.trim(),
            productUrl: _urlController.text.trim(),
            quantity: qty,
            unitPriceAmount:
                double.tryParse(_priceController.text) ?? 0.0,
            variantAttributes: variantAttributes,
          ),
        );
  }

  void _submitContinue(int qty, Map<String, String> variantAttributes) {
    _pendingCheckout = false;
    _submit(qty, variantAttributes);
  }

  void _submitCheckout(int qty, Map<String, String> variantAttributes) {
    _pendingCheckout = true;
    _submit(qty, variantAttributes);
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  Future<void> _navigateToCheckout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final useCupertino = AdaptivePlatform.isCupertino(context);
    try {
      final cart = await sl<GetCartUseCase>()();
      if (!mounted) return;
      if (cart != null && cart.items.isNotEmpty) {
        navigator.pushReplacement(
          useCupertino
              ? CupertinoPageRoute<void>(
                  builder: (_) => CheckoutScreen(cart: cart),
                )
              : MaterialPageRoute<void>(
                  builder: (_) => CheckoutScreen(cart: cart),
                ),
        );
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    navigator.pop(true);
  }

  void _onStateChange(BuildContext context, AddToCartState state) {
    if (state.status == AddToCartStatus.success) {
      if (_pendingCheckout) {
        _navigateToCheckout(context);
      } else {
        Navigator.of(context).pop(true);
      }
      return;
    }
    if (state.status == AddToCartStatus.failure) {
      final failure = state.failure!;
      if (failure.code == CartFailureCode.sessionExpired) return;
      final message = _failureMessage(context, failure);
      if (AdaptivePlatform.isCupertino(context)) {
        showCupertinoDialog<void>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  String _failureMessage(BuildContext context, CartFailure failure) {
    final l10n = AppLocalizations.of(context)!;
    return switch (failure.code) {
      CartFailureCode.unauthorized => l10n.addToCartErrorUnauthorized,
      CartFailureCode.sessionExpired => l10n.addToCartErrorUnauthorized,
      CartFailureCode.networkError => l10n.addToCartErrorNetwork,
      CartFailureCode.serverError => l10n.addToCartErrorServer,
      CartFailureCode.unknown => l10n.addToCartErrorUnknown,
    };
  }

  // ── Async helpers ─────────────────────────────────────────────────────────

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      try {
        await launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddToCartBloc, AddToCartState>(
      listener: _onStateChange,
      child: BlocBuilder<AddToCartBloc, AddToCartState>(
        builder: (context, state) {
          final isLoading = state.status == AddToCartStatus.loading;
          final l10n = AppLocalizations.of(context)!;

          if (AdaptivePlatform.isCupertino(context)) {
            return _CupertinoProductFormContent(
              productNameController: _productNameController,
              urlController: _urlController,
              priceController: _priceController,
              isLoading: isLoading,
              pendingCheckout: _pendingCheckout,
              onSubmitAndContinue: _submitContinue,
              onSubmitAndCheckout: _submitCheckout,
            );
          }

          final hasUrl = widget.initialUrl?.isNotEmpty ?? false;

          return Scaffold(
            backgroundColor: _kSurface,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  // ── App bar ──────────────────────────────────────────────
                  _MD3AppBar(onBack: () => Navigator.pop(context), l10n: l10n),

                  // ── Scrollable body ──────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // Source card (when URL comes from deep link)
                          if (hasUrl) ...<Widget>[
                            _MD3SourceCard(
                              url: widget.initialUrl!,
                              l10n: l10n,
                              onOpen: () => _openUrl(widget.initialUrl!),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Section label
                          Text(
                            l10n.addToCartSectionLabel,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: _kOnSurfaceVar,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Product name
                          _MD3OutlinedField(
                            label: l10n.addToCartProductNameLabel,
                            controller: _productNameController,
                            hint: l10n.addToCartProductNamePlaceholder,
                          ),
                          const SizedBox(height: 14),

                          // URL field (only when no detected link)
                          if (!hasUrl) ...<Widget>[
                            _MD3OutlinedField(
                              label: l10n.addToCartProductLinkLabel,
                              controller: _urlController,
                              keyboardType: TextInputType.url,
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Price + helper
                          _MD3OutlinedField(
                            label: l10n.addToCartPriceLabel,
                            controller: _priceController,
                            prefixText: '\$ ',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            suffix: Container(
                              margin: const EdgeInsets.only(right: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kSurface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'USD',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _kOnSurfaceVar,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Icon(Icons.verified_outlined,
                                    size: 14, color: _kGreen),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    l10n.addToCartPriceHelper,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: _kOnSurfaceVar,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Quantity stepper
                          _MD3QuantityRow(
                            label: l10n.addToCartQuantityLabel,
                            quantity: _quantity,
                            onDecrement: () =>
                                setState(() => _quantity = (_quantity - 1).clamp(1, 3)),
                            onIncrement: _quantity < 3
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // Talla (required, with "No aplica")
                          _MD3VariantField(
                            label: l10n.addToCartSizeLabel,
                            controller: _sizeController,
                            hint: l10n.addToCartSizePlaceholder,
                            notApplicable: _sizeNotApplicable,
                            notApplicableLabel: l10n.addToCartNotApplicable,
                            errorText: _sizeError,
                            onToggleNotApplicable: (v) => setState(() {
                              _sizeNotApplicable = v;
                              _sizeError = null;
                            }),
                          ),
                          const SizedBox(height: 14),

                          // Color (required, with "No aplica")
                          _MD3VariantField(
                            label: l10n.addToCartColorLabel,
                            controller: _colorController,
                            hint: l10n.addToCartColorPlaceholder,
                            notApplicable: _colorNotApplicable,
                            notApplicableLabel: l10n.addToCartNotApplicable,
                            errorText: _colorError,
                            onToggleNotApplicable: (v) => setState(() {
                              _colorNotApplicable = v;
                              _colorError = null;
                            }),
                          ),
                          const SizedBox(height: 14),

                          // Notes
                          _MD3OutlinedField(
                            label: l10n.addToCartNotesLabel,
                            controller: _notesController,
                            hint: l10n.addToCartNotesPlaceholder,
                            minLines: 2,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom bar ───────────────────────────────────────────
                  _MD3BottomBar(
                    l10n: l10n,
                    isLoading: isLoading,
                    pendingCheckout: _pendingCheckout,
                    onAddToCart: () => _submitMaterial(checkout: false),
                    onGoToCheckout: () => _submitMaterial(checkout: true),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── MD3 Components ────────────────────────────────────────────────────────────

class _MD3AppBar extends StatelessWidget {
  const _MD3AppBar({required this.onBack, required this.l10n});

  final VoidCallback onBack;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(bottom: BorderSide(color: _kOutline)),
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: _kOnSurface),
            ),
            const SizedBox(width: 4),
            Text(
              l10n.addToCartTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kOnSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MD3SourceCard extends StatelessWidget {
  const _MD3SourceCard({
    required this.url,
    required this.l10n,
    required this.onOpen,
  });

  final String url;
  final AppLocalizations l10n;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final storeName = _storeNameFromUrl(url);
    final shortUrl = _shortenUrl(url);

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        border: Border.all(color: _kOutline),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          // Thumbnail
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 26,
              color: _kOnSurfaceVar,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 7,
                  runSpacing: 4,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.storefront,
                            size: 17, color: _kPrimary),
                        const SizedBox(width: 5),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kOnSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kGreenTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.addToCartLinkDetected,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: _kGreen,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  shortUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _kOnSurfaceVar,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          // Open button
          IconButton(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new,
                size: 20, color: _kOnSurfaceVar),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

class _MD3OutlinedField extends StatelessWidget {
  const _MD3OutlinedField({
    required this.label,
    required this.controller,
    this.hint,
    this.prefixText,
    this.suffix,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? prefixText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final int? minLines;
  final int maxLines;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: _kOutline),
  );
  static const _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: _kPrimary, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffix: suffix,
        labelStyle: const TextStyle(color: _kOnSurfaceVar),
        filled: true,
        fillColor: _kCard,
        border: _border,
        enabledBorder: _border,
        focusedBorder: _focusedBorder,
        floatingLabelStyle: const TextStyle(color: _kPrimary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

class _MD3QuantityRow extends StatelessWidget {
  const _MD3QuantityRow({
    required this.label,
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        border: Border.all(color: _kOutline),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kOnSurface,
              ),
            ),
          ),
          // Stepper pill
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: _kPrimaryTint,
              borderRadius: BorderRadius.circular(999),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  onTap: quantity > 1 ? onDecrement : null,
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.remove,
                      size: 20,
                      color: quantity > 1
                          ? _kPrimary
                          : _kPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _kOnSurface,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onIncrement,
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.add,
                      size: 20,
                      color: onIncrement != null
                          ? _kPrimary
                          : _kPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MD3VariantField extends StatelessWidget {
  const _MD3VariantField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.notApplicable,
    required this.notApplicableLabel,
    required this.onToggleNotApplicable,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool notApplicable;
  final String notApplicableLabel;
  final ValueChanged<bool> onToggleNotApplicable;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: controller,
          enabled: !notApplicable,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: errorText,
            labelStyle: const TextStyle(color: _kOnSurfaceVar),
            filled: true,
            fillColor: notApplicable ? _kSurface : _kCard,
            border: _MD3OutlinedField._border,
            enabledBorder: _MD3OutlinedField._border,
            focusedBorder: _MD3OutlinedField._focusedBorder,
            floatingLabelStyle: const TextStyle(color: _kPrimary),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onToggleNotApplicable(!notApplicable),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Checkbox(
                value: notApplicable,
                onChanged: (v) => onToggleNotApplicable(v ?? false),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 4),
              Text(
                notApplicableLabel,
                style: const TextStyle(fontSize: 13, color: _kOnSurfaceVar),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MD3BottomBar extends StatelessWidget {
  const _MD3BottomBar({
    required this.l10n,
    required this.isLoading,
    required this.pendingCheckout,
    required this.onAddToCart,
    required this.onGoToCheckout,
  });

  final AppLocalizations l10n;
  final bool isLoading;
  final bool pendingCheckout;
  final VoidCallback onAddToCart;
  final VoidCallback onGoToCheckout;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _kCard,
        border: Border(top: BorderSide(color: _kOutline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Primary: Add to cart
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onAddToCart,
                  icon: (isLoading && !pendingCheckout)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.add_shopping_cart_outlined,
                          size: 21),
                  label: Text(l10n.addToCartButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              // Secondary: Add & go to checkout
              SizedBox(
                height: 46,
                child: TextButton.icon(
                  onPressed: isLoading ? null : onGoToCheckout,
                  icon: (isLoading && pendingCheckout)
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: _kPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.shopping_cart_checkout_outlined,
                          size: 19),
                  label: Text(l10n.addToCartButtonGoToCheckout),
                  style: TextButton.styleFrom(
                    foregroundColor: _kPrimary,
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cupertino ─────────────────────────────────────────────────────────────────

class _CupertinoProductFormContent extends StatefulWidget {
  const _CupertinoProductFormContent({
    required this.productNameController,
    required this.urlController,
    required this.priceController,
    required this.isLoading,
    required this.pendingCheckout,
    required this.onSubmitAndContinue,
    required this.onSubmitAndCheckout,
  });

  final TextEditingController productNameController;
  final TextEditingController urlController;
  final TextEditingController priceController;
  final bool isLoading;
  final bool pendingCheckout;
  final void Function(int qty, Map<String, String> variantAttributes)
      onSubmitAndContinue;
  final void Function(int qty, Map<String, String> variantAttributes)
      onSubmitAndCheckout;

  @override
  State<_CupertinoProductFormContent> createState() =>
      _CupertinoProductFormContentState();
}

class _CupertinoProductFormContentState
    extends State<_CupertinoProductFormContent> {
  int _qty = 1;
  final _sizeController = TextEditingController();
  final _colorController = TextEditingController();
  bool _sizeNotApplicable = false;
  bool _colorNotApplicable = false;
  String? _sizeError;
  String? _colorError;

  @override
  void dispose() {
    _sizeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  bool _validateVariants(AppLocalizations l10n) {
    setState(() {
      _sizeError =
          (!_sizeNotApplicable && _sizeController.text.trim().isEmpty)
              ? l10n.addToCartSizeRequiredError
              : null;
      _colorError =
          (!_colorNotApplicable && _colorController.text.trim().isEmpty)
              ? l10n.addToCartColorRequiredError
              : null;
    });
    return _sizeError == null && _colorError == null;
  }

  Map<String, String> _variantAttributes(AppLocalizations l10n) => {
        l10n.addToCartSizeLabel: _sizeNotApplicable
            ? l10n.addToCartNotApplicable
            : _sizeController.text.trim(),
        l10n.addToCartColorLabel: _colorNotApplicable
            ? l10n.addToCartNotApplicable
            : _colorController.text.trim(),
      };

  void _handleContinue(AppLocalizations l10n) {
    if (!_validateVariants(l10n)) return;
    widget.onSubmitAndContinue(_qty, _variantAttributes(l10n));
  }

  void _handleCheckout(AppLocalizations l10n) {
    if (!_validateVariants(l10n)) return;
    widget.onSubmitAndCheckout(_qty, _variantAttributes(l10n));
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
            children: <Widget>[
              CupertinoNavigationBar(
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(CupertinoIcons.chevron_back, size: 18),
                      SizedBox(width: 2),
                      Text('Inicio', style: TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
                middle: const Text('Detalles del producto'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 160 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * scale,
                          16 * scale,
                          16 * scale,
                          0,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * scale,
                            vertical: 10 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: kFeyamTintBg,
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                CupertinoIcons.link,
                                size: 18 * scale,
                                color: kFeyamTint,
                              ),
                              SizedBox(width: 10 * scale),
                              Expanded(
                                child: Text(
                                  widget.urlController.text.isNotEmpty
                                      ? widget.urlController.text
                                      : 'https://www.amazon.com/dp/B09XS7JWHH',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13 * scale,
                                    color: kFeyamTint,
                                    fontFamily: '.SF Pro Text',
                                  ),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Icon(
                                CupertinoIcons.checkmark_circle_fill,
                                size: 18 * scale,
                                color: kFeyamGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      FeyamListSection(
                        header: 'Detalles del producto',
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(12 * scale),
                            child: _CupertinoField(
                              label: l10n.addToCartProductNameLabel,
                              placeholder: l10n.addToCartProductNamePlaceholder,
                              controller: widget.productNameController,
                            ),
                          ),
                          Container(
                            height: 0.5,
                            color: kFeyamSepLight,
                            margin: EdgeInsets.only(left: 16 * scale),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12 * scale),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: _CupertinoField(
                                    label: l10n.addToCartPriceLabel,
                                    placeholder: '0.00',
                                    controller: widget.priceController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    helper: 'En la moneda de la tienda',
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                SizedBox(
                                  width: 90 * scale,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Cantidad',
                                        style: TextStyle(
                                          fontSize: 13 * scale,
                                          color: kFeyamLabelSec,
                                          fontFamily: '.SF Pro Text',
                                        ),
                                      ),
                                      SizedBox(height: 4 * scale),
                                      Container(
                                        height: 44 * scale,
                                        decoration: BoxDecoration(
                                          color: kFeyamCard,
                                          borderRadius: BorderRadius.circular(
                                            10 * scale,
                                          ),
                                          border: Border.all(
                                            color: kFeyamSepLight,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () => setState(
                                                () => _qty =
                                                    (_qty - 1).clamp(1, 3),
                                              ),
                                              child: Icon(
                                                CupertinoIcons.minus_circled,
                                                size: 22 * scale,
                                                color: _qty <= 1
                                                    ? kFeyamLabelTer
                                                    : kFeyamTint,
                                              ),
                                            ),
                                            Text(
                                              '$_qty',
                                              style: TextStyle(
                                                fontSize: 17 * scale,
                                                fontWeight: FontWeight.w600,
                                                color: kFeyamLabel,
                                                fontFamily: '.SF Pro Text',
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _qty < 3
                                                  ? () =>
                                                      setState(() => _qty++)
                                                  : null,
                                              child: Icon(
                                                CupertinoIcons.plus_circled,
                                                size: 22 * scale,
                                                color: _qty < 3
                                                    ? kFeyamTint
                                                    : kFeyamLabelTer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      FeyamListSection(
                        header: 'Talla y color',
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(12 * scale),
                            child: _CupertinoVariantField(
                              label: l10n.addToCartSizeLabel,
                              placeholder: l10n.addToCartSizePlaceholder,
                              controller: _sizeController,
                              notApplicable: _sizeNotApplicable,
                              notApplicableLabel: l10n.addToCartNotApplicable,
                              errorText: _sizeError,
                              onToggleNotApplicable: (v) => setState(() {
                                _sizeNotApplicable = v;
                                _sizeError = null;
                              }),
                            ),
                          ),
                          Container(
                            height: 0.5,
                            color: kFeyamSepLight,
                            margin: EdgeInsets.only(left: 16 * scale),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12 * scale),
                            child: _CupertinoVariantField(
                              label: l10n.addToCartColorLabel,
                              placeholder: l10n.addToCartColorPlaceholder,
                              controller: _colorController,
                              notApplicable: _colorNotApplicable,
                              notApplicableLabel: l10n.addToCartNotApplicable,
                              errorText: _colorError,
                              onToggleNotApplicable: (v) => setState(() {
                                _colorNotApplicable = v;
                                _colorError = null;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  12 * scale,
                  16 * scale,
                  28 * scale,
                ),
                decoration: const BoxDecoration(
                  color: kFeyamCard,
                  border: Border(
                    top: BorderSide(color: kFeyamSepLight, width: 0.5),
                  ),
                ),
                child: widget.isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          FeyamButton(
                            label: l10n.addToCartButtonCheckout,
                            icon: CupertinoIcons.cart_badge_plus,
                            onPressed: () => _handleCheckout(l10n),
                          ),
                          SizedBox(height: 10 * scale),
                          FeyamButton(
                            label: l10n.addToCartButtonContinue,
                            icon: CupertinoIcons.arrow_left,
                            variant: FeyamButtonVariant.tinted,
                            onPressed: () => _handleContinue(l10n),
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

class _CupertinoVariantField extends StatelessWidget {
  const _CupertinoVariantField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.notApplicable,
    required this.notApplicableLabel,
    required this.onToggleNotApplicable,
    this.errorText,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool notApplicable;
  final String notApplicableLabel;
  final ValueChanged<bool> onToggleNotApplicable;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Opacity(
          opacity: notApplicable ? 0.4 : 1,
          child: IgnorePointer(
            ignoring: notApplicable,
            child: _CupertinoField(
              label: label,
              placeholder: placeholder,
              controller: controller,
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onToggleNotApplicable(!notApplicable),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                notApplicable
                    ? CupertinoIcons.checkmark_square_fill
                    : CupertinoIcons.square,
                size: 20,
                color: notApplicable ? kFeyamTint : kFeyamLabelTer,
              ),
              const SizedBox(width: 6),
              Text(
                notApplicableLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: kFeyamLabelSec,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemRed,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ],
      ],
    );
  }
}

class _CupertinoField extends StatefulWidget {
  const _CupertinoField({
    this.label,
    required this.placeholder,
    required this.controller,
    this.helper,
    this.keyboardType,
  });

  final String? label;
  final String placeholder;
  final TextEditingController controller;
  final String? helper;
  final TextInputType? keyboardType;

  @override
  State<_CupertinoField> createState() => _CupertinoFieldState();
}

class _CupertinoFieldState extends State<_CupertinoField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _focused ? kFeyamTint : kFeyamSepLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 13,
              color: kFeyamLabelSec,
              fontFamily: '.SF Pro Text',
            ),
          ),
          const SizedBox(height: 4),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: kFeyamCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
            boxShadow: _focused
                ? <BoxShadow>[
                    BoxShadow(
                      color: kFeyamTint.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: CupertinoTextField.borderless(
            controller: widget.controller,
            placeholder: widget.placeholder,
            keyboardType: widget.keyboardType,
            onTap: () => setState(() => _focused = true),
            onTapOutside: (_) => setState(() => _focused = false),
          ),
        ),
        if (widget.helper != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            widget.helper!,
            style: const TextStyle(
              fontSize: 13,
              color: kFeyamLabelTer,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ],
      ],
    );
  }
}
