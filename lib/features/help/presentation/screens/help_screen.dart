import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoHelpContent();
    }
    return const _MaterialHelpContent();
  }
}

class _MaterialHelpContent extends StatelessWidget {
  const _MaterialHelpContent();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

        return ColoredBox(
          color: colors.surface,
          child: Column(
            children: <Widget>[
              _HelpHeader(scale: scale),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    24 * scale,
                    20 * scale,
                    32 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _FaqSection(scale: scale),
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

class _HelpHeader extends StatelessWidget {
  const _HelpHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.navHelp,
                style: textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final faqs = <_FaqItem>[
      _FaqItem(
        question: l10n.helpFaq1Question,
        answer: l10n.helpFaq1Answer,
      ),
      _FaqItem(
        question: l10n.helpFaq2Question,
        answer: l10n.helpFaq2Answer,
      ),
      _FaqItem(
        question: l10n.helpFaq3Question,
        answer: l10n.helpFaq3Answer,
      ),
      _FaqItem(
        question: l10n.helpFaq4Question,
        answer: l10n.helpFaq4Answer,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.helpFaqsTitle,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16 * scale,
          ),
        ),
        SizedBox(height: 12 * scale),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16 * scale),
            child: Column(
              children: <Widget>[
                for (var i = 0; i < faqs.length; i++) ...[
                  _FaqTile(scale: scale, faq: faqs[i]),
                  if (i < faqs.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.scale, required this.faq});

  final double scale;
  final _FaqItem faq;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20 * widget.scale,
          16 * widget.scale,
          20 * widget.scale,
          16 * widget.scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 15 * widget.scale,
                    ),
                  ),
                ),
                SizedBox(width: 8 * widget.scale),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: colors.onSurfaceVariant,
                    size: 22 * widget.scale,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              SizedBox(height: 8 * widget.scale),
              Text(
                widget.faq.answer,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 14 * widget.scale,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

// ── Cupertino Help ────────────────────────────────────────────────────────────

class _CupertinoHelpContent extends StatelessWidget {
  const _CupertinoHelpContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);
        return ColoredBox(
          color: kFeyamBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Large title nav bar
              Container(
                color: kFeyamBg,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 0),
                  child: Text(
                    l10n.navHelp,
                    style: TextStyle(
                      fontSize: 34 * scale,
                      fontWeight: FontWeight.w700,
                      color: kFeyamLabel,
                      letterSpacing: 0.37,
                      fontFamily: '.SF Pro Display',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: 16 * scale),
                      FeyamListSection(
                        header: 'Preguntas frecuentes',
                        children: <Widget>[
                          _CupertinoFaqTile(
                            icon: CupertinoIcons.link,
                            iconColor: const Color(0xFF1B6DE0),
                            question: l10n.helpFaq1Question,
                            answer: l10n.helpFaq1Answer,
                          ),
                          _CupertinoFaqTile(
                            icon: CupertinoIcons.creditcard_fill,
                            iconColor: const Color(0xFFAF52DE),
                            question: l10n.helpFaq2Question,
                            answer: l10n.helpFaq2Answer,
                          ),
                          _CupertinoFaqTile(
                            icon: CupertinoIcons.airplane,
                            iconColor: const Color(0xFF30B0C7),
                            question: l10n.helpFaq3Question,
                            answer: l10n.helpFaq3Answer,
                          ),
                          _CupertinoFaqTile(
                            icon: CupertinoIcons.building_2_fill,
                            iconColor: const Color(0xFFFF9500),
                            question: l10n.helpFaq4Question,
                            answer: l10n.helpFaq4Answer,
                            isLast: true,
                          ),
                        ],
                      ),
                      FeyamListSection(
                        header: 'Contacto',
                        children: <Widget>[
                          FeyamListTile(
                            title: const Text('Términos y condiciones'),
                            leading: FeyamIconTile(icon: CupertinoIcons.doc_text_fill, color: kFeyamLabelSec),
                            isLast: true,
                            onTap: () {},
                          ),
                        ],
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

class _CupertinoFaqTile extends StatefulWidget {
  const _CupertinoFaqTile({
    required this.icon,
    required this.iconColor,
    required this.question,
    required this.answer,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String question;
  final String answer;
  final bool isLast;

  @override
  State<_CupertinoFaqTile> createState() => _CupertinoFaqTileState();
}

class _CupertinoFaqTileState extends State<_CupertinoFaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: ColoredBox(
        color: kFeyamCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: <Widget>[
                  FeyamIconTile(icon: widget.icon, color: widget.iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: widget.isLast && !_open
                            ? null
                            : const Border(bottom: BorderSide(color: kFeyamSepLight, width: 0.5)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.question,
                                  style: const TextStyle(fontSize: 17, color: kFeyamLabel, letterSpacing: -0.41, fontFamily: '.SF Pro Text'),
                                ),
                                if (_open) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.answer,
                                    style: const TextStyle(fontSize: 15, color: kFeyamLabelSec, height: 1.33, letterSpacing: -0.24, fontFamily: '.SF Pro Text'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              _open ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                              size: 14,
                              color: kFeyamLabelTer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_open && widget.isLast)
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
