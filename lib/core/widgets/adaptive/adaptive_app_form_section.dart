import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveAppFormSection extends StatelessWidget {
  const AdaptiveAppFormSection({
    super.key,
    required this.children,
    this.title,
    this.footer,
    this.spacing = 16,
    this.padding,
  });

  final List<Widget> children;
  final String? title;
  final String? footer;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _spacedChildren(),
    );

    if (AdaptivePlatform.isCupertino(context)) {
      final theme = CupertinoTheme.of(context);

      return Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title != null) ...<Widget>[
              Text(
                title!,
                style: theme.textTheme.textStyle.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
            ],
            content,
            if (footer != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                footer!,
                style: theme.textTheme.textStyle.copyWith(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(
              title!,
              style: textTheme.titleSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          content,
          if (footer != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              footer!,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _spacedChildren() {
    return <Widget>[
      for (var index = 0; index < children.length; index++) ...<Widget>[
        if (index > 0) SizedBox(height: spacing),
        children[index],
      ],
    ];
  }
}
