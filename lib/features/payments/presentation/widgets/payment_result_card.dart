import 'package:flutter/material.dart';

/// Result card shown after a payment attempt (success, pending confirmation,
/// failure, or cancellation). Shared by [OrderPaymentScreen] and the checkout
/// flow, which both drive the same [OrderPaymentBloc] and render its terminal
/// states with this same widget instead of duplicating the layout.
class PaymentResultCard extends StatelessWidget {
  const PaymentResultCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.primaryAction = true,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;
  final bool primaryAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
          child: Icon(icon, size: 40, color: iconColor),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: primaryAction
              ? FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.secondary,
                    foregroundColor: colors.onSecondary,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(actionLabel),
                )
              : FilledButton.tonal(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  child: Text(actionLabel),
                ),
        ),
      ],
    );
  }
}
