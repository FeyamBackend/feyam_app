import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AddToCartScreen extends StatefulWidget {
  const AddToCartScreen({super.key});

  @override
  State<AddToCartScreen> createState() => _AddToCartScreenState();
}

class _AddToCartScreenState extends State<AddToCartScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AdaptiveAppScaffold(
      largeTitle: l10n.addToCartTitle,
      body: Center(
        child: Text(l10n.addToCartPlaceholder),
      ),
    );
  }
}
