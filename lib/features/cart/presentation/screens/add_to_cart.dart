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

  // Cupertino: variants as free text
  final _variantsController = TextEditingController();

  // Material: quantity stepper + variants chips + notes field
  int _quantity = 1;
  final List<String> _variants = [];
  final _notesController = TextEditingController();

  bool _pendingCheckout = false;

  @override
  void dispose() {
    _productNameController.dispose();
    _urlController.dispose();
    _priceController.dispose();
    _variantsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Submit helpers ────────────────────────────────────────────────────────

  void _submitMaterial({required bool checkout}) {
    _pendingCheckout = checkout;
    final variantText = _variants.join(', ');
    final notesText = _notesController.text.trim();
    final notes = [variantText, notesText]
        .where((s) => s.isNotEmpty)
        .join('\n');
    context.read<AddToCartBloc>().add(
          AddToCartSubmitted(
            productName: _productNameController.text.trim(),
            productUrl: _urlController.text.trim(),
            quantity: _quantity,
            unitPriceAmount:
                double.tryParse(_priceController.text) ?? 0.0,
            notes: notes.isEmpty ? null : notes,
          ),
        );
  }

  // Cupertino submit path (unchanged)
  void _submit(int qty) {
    context.read<AddToCartBloc>().add(
          AddToCartSubmitted(
            productName: _productNameController.text.trim(),
            productUrl: _urlController.text.trim(),
            quantity: qty,
            unitPriceAmount:
                double.tryParse(_priceController.text) ?? 0.0,
            notes: _variantsController.text.trim().isEmpty
                ? null
                : _variantsController.text.trim(),
          ),
        );
  }

  void _submitContinue(int qty) {
    _pendingCheckout = false;
    _submit(qty);
  }

  void _submitCheckout(int qty) {
    _pendingCheckout = true;
    _submit(qty);
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

  Future<void> _showAddVariantDialog() async {
    // Use the State's own context (stable), not the BlocBuilder's builder context.
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addToCartVariantAdd),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.addToCartVariantsPlaceholder,
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) Navigator.of(ctx).pop(v.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) Navigator.of(ctx).pop(v);
            },
            child: Text(l10n.addToCartVariantAdd),
          ),
        ],
      ),
    );
    // Defer disposal until after the dialog's exit animation completes.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.dispose());
    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _variants.add(result));
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
              variantsController: _variantsController,
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
                                setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
                            onIncrement: () =>
                                setState(() => _quantity++),
                          ),
                          const SizedBox(height: 14),

                          // Variants chips
                          _MD3VariantsSection(
                            label: l10n.addToCartVariantsLabel,
                            addLabel: l10n.addToCartVariantAdd,
                            variants: _variants,
                            onRemove: (i) =>
                                setState(() => _variants.removeAt(i)),
                            onAdd: _showAddVariantDialog,
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
                Row(
                  children: <Widget>[
                    const Icon(Icons.storefront,
                        size: 17, color: _kPrimary),
                    const SizedBox(width: 5),
                    Text(
                      storeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kOnSurface,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kGreenTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.addToCartLinkDetected,
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
  final VoidCallback onIncrement;

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
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(Icons.add, size: 20, color: _kPrimary),
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

class _MD3VariantsSection extends StatelessWidget {
  const _MD3VariantsSection({
    required this.label,
    required this.addLabel,
    required this.variants,
    required this.onRemove,
    required this.onAdd,
  });

  final String label;
  final String addLabel;
  final List<String> variants;
  final void Function(int index) onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: _kOnSurfaceVar,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (int i = 0; i < variants.length; i++)
              _MD3VariantChip(
                label: variants[i],
                onRemove: () => onRemove(i),
              ),
            // Add chip
            GestureDetector(
              onTap: onAdd,
              child: Container(
                height: 34,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _kOutline),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.add,
                        size: 17, color: _kOnSurfaceVar),
                    const SizedBox(width: 4),
                    Text(
                      addLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kOnSurfaceVar,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MD3VariantChip extends StatelessWidget {
  const _MD3VariantChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: _kPrimaryTint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kPrimary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 16, color: _kPrimary),
          ),
        ],
      ),
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
    required this.variantsController,
    required this.isLoading,
    required this.pendingCheckout,
    required this.onSubmitAndContinue,
    required this.onSubmitAndCheckout,
  });

  final TextEditingController productNameController;
  final TextEditingController urlController;
  final TextEditingController priceController;
  final TextEditingController variantsController;
  final bool isLoading;
  final bool pendingCheckout;
  final void Function(int qty) onSubmitAndContinue;
  final void Function(int qty) onSubmitAndCheckout;

  @override
  State<_CupertinoProductFormContent> createState() =>
      _CupertinoProductFormContentState();
}

class _CupertinoProductFormContentState
    extends State<_CupertinoProductFormContent> {
  int _qty = 1;

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
                                                    (_qty - 1).clamp(1, 99),
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
                                              onTap: () =>
                                                  setState(() => _qty++),
                                              child: Icon(
                                                CupertinoIcons.plus_circled,
                                                size: 22 * scale,
                                                color: kFeyamTint,
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
                        header: 'Variantes u observaciones · opcional',
                        footer: 'Ej: color negro, talle M, versión internacional…',
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(12 * scale),
                            child: _CupertinoField(
                              placeholder: 'Color, talle, versión…',
                              controller: widget.variantsController,
                              multiline: true,
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
                            onPressed: () =>
                                widget.onSubmitAndCheckout(_qty),
                          ),
                          SizedBox(height: 10 * scale),
                          FeyamButton(
                            label: l10n.addToCartButtonContinue,
                            icon: CupertinoIcons.arrow_left,
                            variant: FeyamButtonVariant.tinted,
                            onPressed: () =>
                                widget.onSubmitAndContinue(_qty),
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

class _CupertinoField extends StatefulWidget {
  const _CupertinoField({
    this.label,
    required this.placeholder,
    required this.controller,
    this.helper,
    this.keyboardType,
    this.multiline = false,
  });

  final String? label;
  final String placeholder;
  final TextEditingController controller;
  final String? helper;
  final TextInputType? keyboardType;
  final bool multiline;

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
          child: widget.multiline
              ? CupertinoTextField.borderless(
                  controller: widget.controller,
                  placeholder: widget.placeholder,
                  minLines: 4,
                  maxLines: 6,
                  onTap: () => setState(() => _focused = true),
                  onTapOutside: (_) => setState(() => _focused = false),
                )
              : CupertinoTextField.borderless(
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
