import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveAppScaffold extends StatelessWidget {
  const AdaptiveAppScaffold({
    super.key,
    required this.body,
    this.title,
    this.largeTitle,
    this.bottomNavigationBar,
    this.safeAreaBottom = true,
  });

  final Widget body;
  final String? title;
  final String? largeTitle;
  final Widget? bottomNavigationBar;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return _CupertinoAdaptiveAppScaffold(
        title: title,
        largeTitle: largeTitle,
        bottomNavigationBar: bottomNavigationBar,
        safeAreaBottom: safeAreaBottom,
        body: body,
      );
    }

    return Scaffold(
      appBar: title == null && largeTitle == null
          ? null
          : AppBar(title: Text(title ?? largeTitle!)),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _CupertinoAdaptiveAppScaffold extends StatelessWidget {
  const _CupertinoAdaptiveAppScaffold({
    required this.title,
    required this.largeTitle,
    required this.bottomNavigationBar,
    required this.safeAreaBottom,
    required this.body,
  });

  final String? title;
  final String? largeTitle;
  final Widget? bottomNavigationBar;
  final bool safeAreaBottom;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    if (largeTitle != null) {
      return CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text(largeTitle!),
              middle: title == null ? null : Text(title!),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: SafeArea(
                top: false,
                bottom: safeAreaBottom,
                child: body,
              ),
            ),
          ],
        ),
      );
    }

    final content = bottomNavigationBar == null
        ? SafeArea(bottom: safeAreaBottom, child: body)
        : Column(
            children: <Widget>[
              Expanded(
                child: SafeArea(bottom: false, child: body),
              ),
              SafeArea(top: false, child: bottomNavigationBar!),
            ],
          );

    return CupertinoPageScaffold(
      navigationBar: title == null
          ? null
          : CupertinoNavigationBar(middle: Text(title!)),
      child: content,
    );
  }
}
