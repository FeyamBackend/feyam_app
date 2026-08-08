import 'package:feyam/core/theme/app_theme_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color tokens — Feyam brand (navy / green / lime) ───────────────────────

const kFeyamTint = ConciergeProPalette.primary; // #0D3B66 navy
const kFeyamTintPressed = Color(0xFF0A2E52);
const kFeyamTintBg = Color(0x1F0D3B66);
const kFeyamSecondary =
    ConciergeProPalette.secondary; // #4CAF50 green — CTAs, success
const kFeyamSecondaryPressed = Color(0xFF3D8B40);
const kFeyamSecondaryBg = Color(0x1F4CAF50);
const kFeyamTertiary =
    ConciergeProPalette.tertiary; // dark-olive lime accent (accessible on white)
const kFeyamBg = Color(0xFFF5F6F8);
const kFeyamCard = Color(0xFFFFFFFF);
const kFeyamLabel = Color(0xFF1A1D21);
const kFeyamLabelSec = Color(0xFF6B7280);
const kFeyamLabelTer = Color(0xFF9AA0A6);
const kFeyamSepLight = Color(0xFFEEF0F2);
const kFeyamFillTer = Color(0xFFF5F6F8);
const kFeyamFillQuat = Color(0xFFEEF0F2);
const kFeyamRed = ConciergeProPalette.error;
const kFeyamOrange = Color(0xFFA8710F);
const kFeyamGreen = ConciergeProPalette.secondary;
const kFeyamTeal = Color(0xFF1A5FC4);

/// Shared Poppins text-style helper for this kit — keeps every label on the
/// brand typeface without repeating the GoogleFonts call at each site.
TextStyle _feyamText({
  required double fontSize,
  FontWeight fontWeight = FontWeight.w400,
  required Color color,
  double letterSpacing = 0,
  double? height,
}) {
  return GoogleFonts.poppins(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

// ── FeyamListSection ── inset grouped section ─────────────────────────────────

class FeyamListSection extends StatelessWidget {
  const FeyamListSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  final String? header;
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 6),
              child: Text(
                header!.toUpperCase(),
                style: _feyamText(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kFeyamLabelSec,
                  letterSpacing: -0.08,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kFeyamCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F14192E),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
                BoxShadow(
                  color: Color(0x0F14192E),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 6, 32, 0),
              child: Text(
                footer!,
                style: _feyamText(
                  fontSize: 13,
                  color: kFeyamLabelSec,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── FeyamListTile ─────────────────────────────────────────────────────────────

class FeyamListTile extends StatefulWidget {
  const FeyamListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.detail,
    this.chevron = true,
    this.onTap,
    this.destructive = false,
    this.isLast = false,
    this.badge,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? detail;
  final bool chevron;
  final VoidCallback? onTap;
  final bool destructive;
  final bool isLast;
  final String? badge;

  @override
  State<FeyamListTile> createState() => _FeyamListTileState();
}

class _FeyamListTileState extends State<FeyamListTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _pressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _pressed = false)
          : null,
      onTap: widget.onTap,
      child: ColoredBox(
        color: _pressed ? kFeyamFillQuat : CupertinoColors.transparent,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: <Widget>[
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    border: widget.isLast
                        ? null
                        : const Border(
                            bottom: BorderSide(
                              color: kFeyamSepLight,
                              width: 0.5,
                            ),
                          ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            DefaultTextStyle(
                              style: _feyamText(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                color: widget.destructive
                                    ? kFeyamRed
                                    : kFeyamLabel,
                              ),
                              child: widget.title,
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 1),
                              DefaultTextStyle(
                                style: _feyamText(
                                  fontSize: 13,
                                  color: kFeyamLabelSec,
                                  height: 1.33,
                                ),
                                child: widget.subtitle!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (widget.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: kFeyamRed,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                widget.badge!,
                                style: _feyamText(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          if (widget.detail != null)
                            DefaultTextStyle(
                              style: _feyamText(
                                fontSize: 15,
                                color: kFeyamLabelSec,
                              ),
                              child: widget.detail!,
                            ),
                          if (widget.trailing != null) widget.trailing!,
                          if (widget.chevron && widget.onTap != null)
                            const Padding(
                              padding: EdgeInsets.only(left: 6, right: 16),
                              child: Icon(
                                CupertinoIcons.chevron_forward,
                                size: 16,
                                color: kFeyamLabelTer,
                              ),
                            )
                          else
                            const SizedBox(width: 16),
                        ],
                      ),
                    ],
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

// ── FeyamStatusBadge ──────────────────────────────────────────────────────────

enum FeyamOrderStatus { enRevision, porPagar, enCamino, entregado }

FeyamOrderStatus feyamStatusFromString(String s) {
  switch (s) {
    case 'payment':
      return FeyamOrderStatus.porPagar;
    case 'shipping':
      return FeyamOrderStatus.enCamino;
    case 'delivered':
      return FeyamOrderStatus.entregado;
    default:
      return FeyamOrderStatus.enRevision;
  }
}

class FeyamStatusBadge extends StatelessWidget {
  const FeyamStatusBadge({super.key, required this.status});

  final FeyamOrderStatus status;

  // Colors match the STATUS table in the Feyam MD3 Design System (md3.jsx).
  static const _map = {
    FeyamOrderStatus.enRevision: (
      bg: Color(0xFFFDF1E0),
      fg: Color(0xFFA8710F),
      icon: CupertinoIcons.clock_fill,
      label: 'En revisión',
    ),
    FeyamOrderStatus.porPagar: (
      bg: Color(0xFFDEE8C3),
      fg: Color(0xFF5C6600),
      icon: CupertinoIcons.creditcard_fill,
      label: 'Por pagar',
    ),
    FeyamOrderStatus.enCamino: (
      bg: Color(0xFFDBE8FB),
      fg: kFeyamTeal,
      icon: CupertinoIcons.airplane,
      label: 'En camino',
    ),
    FeyamOrderStatus.entregado: (
      bg: Color(0xFFD2EAD1),
      fg: Color(0xFF1F6B26),
      icon: CupertinoIcons.checkmark_circle_fill,
      label: 'Entregado',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _map[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(s.icon, size: 13, color: s.fg),
          const SizedBox(width: 5),
          Text(
            s.label,
            style: _feyamText(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: s.fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── FeyamIconTile ─────────────────────────────────────────────────────────────

class FeyamIconTile extends StatelessWidget {
  const FeyamIconTile({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 17, color: CupertinoColors.white),
    );
  }
}

// ── FeyamEmptyState ───────────────────────────────────────────────────────────

class FeyamEmptyState extends StatelessWidget {
  const FeyamEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: ConciergeProPalette.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: kFeyamTint),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: _feyamText(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kFeyamLabel,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: _feyamText(
                  fontSize: 14,
                  color: kFeyamLabelSec,
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

// ── FeyamNavBar ── standard nav bar (mimics CupertinoNavigationBar) ───────────

class FeyamNavBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const FeyamNavBar({
    super.key,
    required this.title,
    this.backLabel,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? backLabel;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: kFeyamCard,
      border: const Border(
        bottom: BorderSide(color: kFeyamSepLight, width: 1),
      ),
      leading: backLabel != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    CupertinoIcons.chevron_back,
                    size: 18,
                    color: kFeyamLabel,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    backLabel!,
                    style: _feyamText(fontSize: 15, color: kFeyamLabel),
                  ),
                ],
              ),
            )
          : null,
      middle: Text(
        title,
        style: _feyamText(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: kFeyamLabel,
        ),
      ),
      trailing: trailing,
    );
  }
}

// ── FeyamCartButton ── cart icon with badge ───────────────────────────────────

class FeyamCartButton extends StatelessWidget {
  const FeyamCartButton({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Icon(CupertinoIcons.cart_fill, size: 22, color: kFeyamTint),
          if (count > 0)
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: kFeyamRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: _feyamText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── FeyamNotificationsButton ── bell icon with badge ──────────────────────────

class FeyamNotificationsButton extends StatelessWidget {
  const FeyamNotificationsButton({
    super.key,
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          const Icon(CupertinoIcons.bell, size: 22, color: kFeyamTint),
          if (count > 0)
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: kFeyamRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: _feyamText(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── FeyamSegmented ─────────────────────────────────────────────────────────────

class FeyamSegmented<T> extends StatelessWidget {
  const FeyamSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<({T value, String label})> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: kFeyamFillTer,
        borderRadius: BorderRadius.circular(9),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: options.map((opt) {
          final active = opt.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: active ? kFeyamCard : CupertinoColors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(
                              alpha: 0.10,
                            ),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opt.label,
                    style: _feyamText(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? kFeyamLabel : kFeyamLabelSec,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── FeyamButton ───────────────────────────────────────────────────────────────

enum FeyamButtonVariant {
  filled,
  secondary,
  tinted,
  plain,
  destructivePlain,
}

class FeyamButton extends StatefulWidget {
  const FeyamButton({
    super.key,
    required this.label,
    this.icon,
    this.variant = FeyamButtonVariant.filled,
    required this.onPressed,
    this.disabled = false,
    this.small = false,
  });

  final String label;
  final IconData? icon;
  final FeyamButtonVariant variant;
  final VoidCallback? onPressed;
  final bool disabled;
  final bool small;

  @override
  State<FeyamButton> createState() => _FeyamButtonState();
}

class _FeyamButtonState extends State<FeyamButton> {
  bool _pressed = false;

  Color get _bg {
    if (widget.disabled) return kFeyamFillTer;
    switch (widget.variant) {
      case FeyamButtonVariant.filled:
        return _pressed ? kFeyamTintPressed : kFeyamTint;
      case FeyamButtonVariant.secondary:
        return _pressed ? kFeyamSecondaryPressed : kFeyamSecondary;
      case FeyamButtonVariant.tinted:
        return _pressed ? const Color(0x380D3B66) : kFeyamTintBg;
      case FeyamButtonVariant.plain:
        return CupertinoColors.transparent;
      case FeyamButtonVariant.destructivePlain:
        return CupertinoColors.transparent;
    }
  }

  Color get _fg {
    if (widget.disabled) return kFeyamLabelTer;
    switch (widget.variant) {
      case FeyamButtonVariant.filled:
      case FeyamButtonVariant.secondary:
        return CupertinoColors.white;
      case FeyamButtonVariant.tinted:
        return kFeyamTint;
      case FeyamButtonVariant.plain:
        return kFeyamTint;
      case FeyamButtonVariant.destructivePlain:
        return kFeyamRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.disabled
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.disabled ? null : widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity:
            _pressed &&
                (widget.variant == FeyamButtonVariant.plain ||
                    widget.variant == FeyamButtonVariant.destructivePlain)
            ? 0.6
            : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: widget.small ? 9 : 14,
          ),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.small ? 16 : 18, color: _fg),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: _feyamText(
                  fontSize: widget.small ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: _fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FeyamActivityIndicator ────────────────────────────────────────────────────

class FeyamActivityIndicator extends StatelessWidget {
  const FeyamActivityIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoActivityIndicator();
  }
}
