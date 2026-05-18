import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AddToCartScreen extends StatefulWidget {
  const AddToCartScreen({super.key});

  @override
  State<AddToCartScreen> createState() => _AddToCartScreenState();
}

class _AddToCartScreenState extends State<AddToCartScreen> {
  final _urlController = TextEditingController(
    text: 'https://feyam.com/product/123',
  );
  final _priceController = TextEditingController(text: '120.00');
  final _quantityController = TextEditingController(text: '1');
  final _variantsController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _variantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      final l10n = AppLocalizations.of(context)!;
      return AdaptiveAppScaffold(
        largeTitle: l10n.addToCartTitle,
        body: Center(child: Text(l10n.addToCartPlaceholder)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 688).clamp(0.54, 1.0);
        return Scaffold(
          backgroundColor: const Color(0xFFFAF9FE),
          body: Column(
            children: <Widget>[
              _MaterialAddToCartHeader(scale: scale),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    28 * scale,
                    28 * scale,
                    28 * scale,
                    40 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _MaterialAddToCartForm(
                        scale: scale,
                        urlController: _urlController,
                        priceController: _priceController,
                        quantityController: _quantityController,
                        variantsController: _variantsController,
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

class _MaterialAddToCartHeader extends StatelessWidget {
  const _MaterialAddToCartHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9FE),
        border: Border(bottom: BorderSide(color: Color(0xFFD8DBE3))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 100 * scale,
          child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Text(
                  l10n.addToCartTitle,
                  style: textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF002B45),
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_back,
                      color: const Color(0xFF002B45),
                      size: 32 * scale,
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

class _MaterialAddToCartForm extends StatelessWidget {
  const _MaterialAddToCartForm({
    required this.scale,
    required this.urlController,
    required this.priceController,
    required this.quantityController,
    required this.variantsController,
  });

  final double scale;
  final TextEditingController urlController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController variantsController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final fieldStyle = textTheme.bodyLarge?.copyWith(
      color: const Color(0xFF111315),
      fontSize: 26 * scale,
      fontWeight: FontWeight.w400,
    );
    final labelStyle = TextStyle(
      color: const Color(0xFF62676E),
      fontSize: 20 * scale,
      fontWeight: FontWeight.w400,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6 * scale),
      borderSide: const BorderSide(color: Color(0xFF62676E)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.addToCartSectionLabel,
          style: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF4A7A87),
            fontSize: 16 * scale,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 14 * scale),
        TextField(
          controller: urlController,
          keyboardType: TextInputType.url,
          style: fieldStyle,
          decoration: InputDecoration(
            labelText: l10n.addToCartProductLinkLabel,
            labelStyle: labelStyle,
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6 * scale),
              borderSide: const BorderSide(color: Color(0xFF002B45), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18 * scale,
              vertical: 20 * scale,
            ),
          ),
        ),
        SizedBox(height: 22 * scale),
        TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: fieldStyle,
          decoration: InputDecoration(
            labelText: l10n.addToCartPriceLabel,
            labelStyle: labelStyle,
            prefixText: r'$ ',
            prefixStyle: fieldStyle,
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6 * scale),
              borderSide: const BorderSide(color: Color(0xFF002B45), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18 * scale,
              vertical: 20 * scale,
            ),
          ),
        ),
        SizedBox(height: 22 * scale),
        TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          style: fieldStyle,
          decoration: InputDecoration(
            labelText: l10n.addToCartQuantityLabel,
            labelStyle: labelStyle,
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6 * scale),
              borderSide: const BorderSide(color: Color(0xFF002B45), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18 * scale,
              vertical: 20 * scale,
            ),
          ),
        ),
        SizedBox(height: 22 * scale),
        TextField(
          controller: variantsController,
          style: fieldStyle,
          decoration: InputDecoration(
            labelText: l10n.addToCartVariantsLabel,
            labelStyle: labelStyle,
            hintText: l10n.addToCartVariantsPlaceholder,
            hintStyle: labelStyle.copyWith(color: const Color(0xFF999CA5)),
            border: border,
            enabledBorder: border,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6 * scale),
              borderSide: const BorderSide(color: Color(0xFF002B45), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18 * scale,
              vertical: 20 * scale,
            ),
          ),
        ),
        SizedBox(height: 48 * scale),
        SizedBox(
          height: 90 * scale,
          child: FilledButton.icon(
            onPressed: () {},
            icon: Icon(Icons.shopping_cart_outlined, size: 28 * scale),
            label: Text(l10n.addToCartButton),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF002B45),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              textStyle: textTheme.headlineSmall?.copyWith(
                fontSize: 28 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
