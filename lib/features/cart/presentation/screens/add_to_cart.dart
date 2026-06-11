import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
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
      return _CupertinoProductFormContent(
        urlController: _urlController,
        priceController: _priceController,
        quantityController: _quantityController,
        variantsController: _variantsController,
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

// ── Cupertino ProductForm ─────────────────────────────────────────────────────

class _CupertinoProductFormContent extends StatefulWidget {
  const _CupertinoProductFormContent({
    required this.urlController,
    required this.priceController,
    required this.quantityController,
    required this.variantsController,
  });

  final TextEditingController urlController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController variantsController;

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
                  padding: EdgeInsets.only(bottom: 100 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Link banner
                      Padding(
                        padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 0),
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
                              Icon(CupertinoIcons.link, size: 18 * scale, color: kFeyamTint),
                              SizedBox(width: 10 * scale),
                              Expanded(
                                child: Text(
                                  widget.urlController.text.isNotEmpty
                                      ? widget.urlController.text
                                      : 'https://www.amazon.com/dp/B09XS7JWHH',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13 * scale, color: kFeyamTint, fontFamily: '.SF Pro Text'),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Icon(CupertinoIcons.checkmark_circle_fill, size: 18 * scale, color: kFeyamGreen),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20 * scale),
                      // Detalles
                      FeyamListSection(
                        header: 'Detalles del producto',
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(12 * scale),
                            child: _CupertinoField(
                              label: l10n.addToCartProductLinkLabel,
                              placeholder: 'Como aparece en la tienda',
                              controller: TextEditingController(text: 'Auriculares Sony WH-1000XM5'),
                              error: null,
                            ),
                          ),
                          Container(height: 0.5, color: kFeyamSepLight, margin: EdgeInsets.only(left: 16 * scale)),
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
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    helper: 'En la moneda de la tienda',
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                SizedBox(
                                  width: 90 * scale,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Cantidad',
                                        style: TextStyle(fontSize: 13 * scale, color: kFeyamLabelSec, fontFamily: '.SF Pro Text'),
                                      ),
                                      SizedBox(height: 4 * scale),
                                      Container(
                                        height: 44 * scale,
                                        decoration: BoxDecoration(
                                          color: kFeyamCard,
                                          borderRadius: BorderRadius.circular(10 * scale),
                                          border: Border.all(color: kFeyamSepLight),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () => setState(() => _qty = (_qty - 1).clamp(1, 99)),
                                              child: Icon(
                                                CupertinoIcons.minus_circled,
                                                size: 22 * scale,
                                                color: _qty <= 1 ? kFeyamLabelTer : kFeyamTint,
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
                                              onTap: () => setState(() => _qty++),
                                              child: Icon(CupertinoIcons.plus_circled, size: 22 * scale, color: kFeyamTint),
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
                      // Variantes
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
              // Sticky footer
              Container(
                padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 28 * scale),
                decoration: const BoxDecoration(
                  color: kFeyamCard,
                  border: Border(top: BorderSide(color: kFeyamSepLight, width: 0.5)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FeyamButton(
                    label: l10n.addToCartButton,
                    icon: CupertinoIcons.cart_fill,
                    onPressed: () => Navigator.of(context).pop(),
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

class _CupertinoField extends StatefulWidget {
  const _CupertinoField({
    this.label,
    required this.placeholder,
    required this.controller,
    this.error,
    this.helper,
    this.keyboardType,
    this.multiline = false,
  });

  final String? label;
  final String placeholder;
  final TextEditingController controller;
  final String? error;
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
    final borderColor = widget.error != null
        ? kFeyamRed
        : _focused
            ? kFeyamTint
            : kFeyamSepLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(fontSize: 13, color: kFeyamLabelSec, fontFamily: '.SF Pro Text'),
          ),
          const SizedBox(height: 4),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: kFeyamCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
            boxShadow: _focused && widget.error == null
                ? [BoxShadow(color: kFeyamTint.withValues(alpha: 0.15), blurRadius: 4)]
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
        if (widget.error != null) ...[
          const SizedBox(height: 4),
          Text(widget.error!, style: const TextStyle(fontSize: 13, color: kFeyamRed, fontFamily: '.SF Pro Text')),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 4),
          Text(widget.helper!, style: const TextStyle(fontSize: 13, color: kFeyamLabelTer, fontFamily: '.SF Pro Text')),
        ],
      ],
    );
  }
}
