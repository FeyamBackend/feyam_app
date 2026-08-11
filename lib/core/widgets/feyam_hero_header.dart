import 'package:flutter/material.dart';

/// The navy "hero" band at the top of every Material screen in the app
/// (logo + optional back button + optional title + optional trailing
/// action). Centralized so the logo sits at the exact same size and
/// vertical position everywhere — hand-copying this header per screen let
/// the back button and trailing action drift to different intrinsic sizes
/// (a bare `IconButton` defaults to a 48x48 tap target unless constrained),
/// which shifted the logo's vertical center from screen to screen.
class FeyamHeroHeader extends StatelessWidget {
  const FeyamHeroHeader({
    super.key,
    this.showBackButton = false,
    this.title,
    this.titleFontSize = 20,
    this.subtitle,
    this.trailing,
    this.scale = 1,
  });

  /// Whether to show the leading back arrow (pops the current route).
  final bool showBackButton;

  /// Title shown below the logo row, in white. Omit for tab-root screens
  /// (Home, Carrito, Perfil) whose greeting/title lives in the body instead.
  final String? title;

  /// Override for the title's font size — only Checkout's hero moment uses
  /// something other than the standard 20.
  final double titleFontSize;

  /// Optional second line under [title], in translucent white. Ignored if
  /// [title] is null.
  final String? subtitle;

  /// A fully-formed tappable trailing widget (e.g. an `IconButton` wrapping
  /// a `Badge.count`, or a `TextButton`). Always force-fit into a fixed
  /// 36-tall slot so it never changes the row's height regardless of its
  /// own default tap-target size.
  final Widget? trailing;

  final double scale;

  static const double _iconSlot = 36;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16 * scale,
            8 * scale,
            16 * scale,
            (title != null ? 20 : 8) * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (showBackButton) ...[
                    SizedBox(
                      width: _iconSlot * scale,
                      height: _iconSlot * scale,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: colors.onPrimary,
                          size: 22 * scale,
                        ),
                      ),
                    ),
                    SizedBox(width: 4 * scale),
                  ],
                  Image.asset(
                    'assets/branding/logo_white.png',
                    height: 22 * scale,
                  ),
                  const Spacer(),
                  if (trailing != null)
                    SizedBox(height: _iconSlot * scale, child: trailing),
                ],
              ),
              if (title != null) ...[
                SizedBox(height: 14 * scale),
                Text(
                  title!,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: titleFontSize * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4 * scale),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: colors.onPrimary.withValues(alpha: 0.85),
                      fontSize: 13.5 * scale,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
