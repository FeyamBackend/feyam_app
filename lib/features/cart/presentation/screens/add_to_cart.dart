import 'package:flutter/cupertino.dart';

class AddToCartScreen extends StatefulWidget {
  const AddToCartScreen({super.key});

  @override
  State<AddToCartScreen> createState() => _AddToCartScreenState();
}

class _AddToCartScreenState extends State<AddToCartScreen> {
  @override
  Widget build(BuildContext context) {
    return AddToCartCupertinoScreen();
  }
}

class AddToCartCupertinoScreen extends StatelessWidget {
  const AddToCartCupertinoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: const CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            leading: Icon(CupertinoIcons.cart),
            largeTitle: Text('Agregar al carrito'),
          ),
          SliverFillRemaining(child: Text('data')),
        ],
      ),
    );
  }
}
