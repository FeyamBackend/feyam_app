import 'package:flutter/cupertino.dart';

// ── Color tokens ──────────────────────────────────────────────────────────────

const kFeyamTint = Color(0xFF1B6DE0);
const kFeyamTintBg = Color(0x1F1B6DE0);
const kFeyamBg = Color(0xFFF2F2F7);
const kFeyamCard = Color(0xFFFFFFFF);
const kFeyamLabel = Color(0xFF000000);
const kFeyamLabelSec = Color(0x993C3C43);
const kFeyamLabelTer = Color(0x4D3C3C43);
const kFeyamSepLight = Color(0x1F3C3C43);
const kFeyamFillTer = Color(0x1F787880);
const kFeyamFillQuat = Color(0x14787880);
const kFeyamRed = Color(0xFFFF3B30);
const kFeyamOrange = Color(0xFFFF9500);
const kFeyamGreen = Color(0xFF34C759);
const kFeyamTeal = Color(0xFF30B0C7);

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
                style: const TextStyle(
                  fontSize: 13,
                  color: kFeyamLabelSec,
                  letterSpacing: -0.08,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kFeyamCard,
              borderRadius: BorderRadius.circular(12),
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
                style: const TextStyle(
                  fontSize: 13,
                  color: kFeyamLabelSec,
                  height: 1.4,
                  fontFamily: '.SF Pro Text',
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
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
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
                            bottom: BorderSide(color: kFeyamSepLight, width: 0.5),
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
                              style: TextStyle(
                                fontSize: 17,
                                letterSpacing: -0.41,
                                color: widget.destructive ? kFeyamRed : kFeyamLabel,
                                fontFamily: '.SF Pro Text',
                              ),
                              child: widget.title,
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 1),
                              DefaultTextStyle(
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: kFeyamLabelSec,
                                  letterSpacing: -0.24,
                                  height: 1.33,
                                  fontFamily: '.SF Pro Text',
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: kFeyamRed,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                widget.badge!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          if (widget.detail != null)
                            DefaultTextStyle(
                              style: const TextStyle(
                                fontSize: 17,
                                color: kFeyamLabelSec,
                                letterSpacing: -0.41,
                                fontFamily: '.SF Pro Text',
                              ),
                              child: widget.detail!,
                            ),
                          if (widget.trailing != null) widget.trailing!,
                          if (widget.chevron && widget.onTap != null)
                            const Padding(
                              padding: EdgeInsets.only(left: 6, right: 16),
                              child: Icon(
                                CupertinoIcons.chevron_forward,
                                size: 14,
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
    case 'payment': return FeyamOrderStatus.porPagar;
    case 'shipping': return FeyamOrderStatus.enCamino;
    case 'delivered': return FeyamOrderStatus.entregado;
    default: return FeyamOrderStatus.enRevision;
  }
}

class FeyamStatusBadge extends StatelessWidget {
  const FeyamStatusBadge({super.key, required this.status});

  final FeyamOrderStatus status;

  static const _map = {
    FeyamOrderStatus.enRevision: (
      bg: Color(0x1FFF9500),
      fg: Color(0xFFC77700),
      icon: CupertinoIcons.clock_fill,
      label: 'En revisión',
    ),
    FeyamOrderStatus.porPagar: (
      bg: kFeyamTintBg,
      fg: kFeyamTint,
      icon: CupertinoIcons.creditcard_fill,
      label: 'Por pagar',
    ),
    FeyamOrderStatus.enCamino: (
      bg: Color(0x1F30B0C7),
      fg: Color(0xFF1E8FA6),
      icon: CupertinoIcons.airplane,
      label: 'En camino',
    ),
    FeyamOrderStatus.entregado: (
      bg: Color(0x1F34C759),
      fg: Color(0xFF248A3D),
      icon: CupertinoIcons.checkmark_circle_fill,
      label: 'Entregado',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _map[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: s.bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(s.icon, size: 13, color: s.fg),
          const SizedBox(width: 5),
          Text(
            s.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.08,
              color: s.fg,
              fontFamily: '.SF Pro Text',
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
        borderRadius: BorderRadius.circular(7),
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
            Icon(icon, size: 56, color: kFeyamLabelTer),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.41,
                color: kFeyamLabel,
                fontFamily: '.SF Pro Display',
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: kFeyamLabelSec,
                  letterSpacing: -0.24,
                  height: 1.33,
                  fontFamily: '.SF Pro Text',
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── FeyamNavBar ── standard nav bar (mimics CupertinoNavigationBar) ───────────

class FeyamNavBar extends StatelessWidget implements ObstructingPreferredSizeWidget {
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
      leading: backLabel != null
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(CupertinoIcons.chevron_back, size: 18),
                  const SizedBox(width: 2),
                  Text(
                    backLabel!,
                    style: const TextStyle(fontSize: 17),
                  ),
                ],
              ),
            )
          : null,
      middle: Text(title),
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
                    style: const TextStyle(
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
                      ? [BoxShadow(color: CupertinoColors.black.withValues(alpha: 0.10), blurRadius: 3, offset: const Offset(0, 1))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? kFeyamLabel : kFeyamLabelSec,
                      letterSpacing: -0.08,
                      fontFamily: '.SF Pro Text',
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

enum FeyamButtonVariant { filled, tinted, plain, destructivePlain }

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
      case FeyamButtonVariant.filled: return _pressed ? const Color(0xFF155BBD) : kFeyamTint;
      case FeyamButtonVariant.tinted: return _pressed ? const Color(0x381B6DE0) : kFeyamTintBg;
      case FeyamButtonVariant.plain: return CupertinoColors.transparent;
      case FeyamButtonVariant.destructivePlain: return CupertinoColors.transparent;
    }
  }

  Color get _fg {
    if (widget.disabled) return kFeyamLabelTer;
    switch (widget.variant) {
      case FeyamButtonVariant.filled: return CupertinoColors.white;
      case FeyamButtonVariant.tinted: return kFeyamTint;
      case FeyamButtonVariant.plain: return kFeyamTint;
      case FeyamButtonVariant.destructivePlain: return kFeyamRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.disabled ? null : () => setState(() => _pressed = false),
      onTap: widget.disabled ? null : widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed && (widget.variant == FeyamButtonVariant.plain || widget.variant == FeyamButtonVariant.destructivePlain) ? 0.6 : 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: widget.small ? 9 : 14,
          ),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.icon != null) ...[
                Icon(widget.icon, size: widget.small ? 16 : 18, color: _fg),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.small ? 15 : 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                  color: _fg,
                  fontFamily: '.SF Pro Text',
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
