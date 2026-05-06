import 'package:feyam/features/cart/presentation/screens/add_to_cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return Center(
        child: CupertinoButton.filled(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(builder: (_) => const AddToCartScreen()),
            );
          },
          child: const Text('Ver solicitar pedido'),
        ),
      );
    }

    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AddToCartScreen()),
          );
        },
        child: const Text('Ver solicitar pedido'),
      ),
    );
  }
}
