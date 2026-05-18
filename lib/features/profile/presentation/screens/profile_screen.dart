import 'package:feyam/core/widgets/adaptive/adaptive_widgets.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoProfileContent();
    }

    return const _MaterialProfileContent();
  }
}

class _MaterialProfileContent extends StatelessWidget {
  const _MaterialProfileContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 640).clamp(0.54, 1.0);

        return Column(
          children: <Widget>[
            _MaterialProfileHeader(scale: scale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  64 * scale,
                  24 * scale,
                  44 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _MaterialProfileSummary(scale: scale),
                    SizedBox(height: 38 * scale),
                    _MaterialProfileSection(
                      scale: scale,
                      title: l10n.profileAccountSection,
                      rows: <_MaterialProfileRowData>[
                        _MaterialProfileRowData(
                          title: l10n.profileMyAddresses,
                          icon: Icons.location_on_outlined,
                        ),
                        _MaterialProfileRowData(
                          title: l10n.profileMyOrders,
                          icon: Icons.shopping_bag_outlined,
                        ),
                      ],
                    ),
                    SizedBox(height: 30 * scale),
                    _MaterialProfileSection(
                      scale: scale,
                      title: l10n.profilePersonalDetailsSection,
                      rows: <_MaterialProfileRowData>[
                        _MaterialProfileRowData(
                          title: l10n.profilePersonalInformation,
                          icon: Icons.person_outline,
                        ),
                        _MaterialProfileRowData(
                          title: l10n.profilePaymentMethods,
                          icon: Icons.credit_card_outlined,
                        ),
                      ],
                    ),
                    SizedBox(height: 30 * scale),
                    _MaterialProfileSection(
                      scale: scale,
                      title: l10n.profileGeneralSection,
                      rows: <_MaterialProfileRowData>[
                        _MaterialProfileRowData(
                          title: l10n.profileNotifications,
                          icon: Icons.notifications_none,
                        ),
                        _MaterialProfileRowData(
                          title: l10n.profileHelpSupport,
                          icon: Icons.help_outline,
                        ),
                      ],
                    ),
                    SizedBox(height: 62 * scale),
                    _MaterialLogoutButton(
                      label: l10n.profileLogOut,
                      scale: scale,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MaterialProfileHeader extends StatelessWidget {
  const _MaterialProfileHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFE),
        border: Border(bottom: BorderSide(color: Color(0xFFD8DBE3))),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 100 * scale,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28 * scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.navProfile,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF111315),
                  fontSize: 34 * scale,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialProfileSummary extends StatelessWidget {
  const _MaterialProfileSummary({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        Container(
          width: 142 * scale,
          height: 142 * scale,
          padding: EdgeInsets.all(6 * scale),
          decoration: const BoxDecoration(
            color: Color(0xFFE4E6EB),
            shape: BoxShape.circle,
          ),
          child: _MaterialProfileAvatar(scale: scale),
        ),
        SizedBox(height: 28 * scale),
        Text(
          l10n.profileName,
          textAlign: TextAlign.center,
          style: textTheme.displaySmall?.copyWith(
            color: const Color(0xFF111315),
            fontSize: 39 * scale,
            fontWeight: FontWeight.w400,
            height: 1.08,
          ),
        ),
        SizedBox(height: 14 * scale),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFCBEAF3),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              12 * scale,
              7 * scale,
              14 * scale,
              8 * scale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.star_border,
                  color: const Color(0xFF54646B),
                  size: 22 * scale,
                ),
                SizedBox(width: 7 * scale),
                Text(
                  l10n.profileMembershipLevel,
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF54646B),
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialProfileAvatar extends StatelessWidget {
  const _MaterialProfileAvatar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFFE9CDB5),
              Color(0xFF4C3F35),
              Color(0xFF151719),
            ],
            stops: <double>[0, 0.46, 1],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            size: 82 * scale,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

class _MaterialProfileSection extends StatelessWidget {
  const _MaterialProfileSection({
    required this.scale,
    required this.title,
    required this.rows,
  });

  final double scale;
  final String title;
  final List<_MaterialProfileRowData> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 14 * scale, bottom: 16 * scale),
          child: Text(
            title.toUpperCase(),
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF002B45),
              fontSize: 23 * scale,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.6,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(34 * scale),
          child: ColoredBox(
            color: const Color(0xFFF2F1F7),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 38 * scale),
              child: Column(
                children: <Widget>[
                  for (var index = 0; index < rows.length; index++) ...[
                    _MaterialProfileRow(scale: scale, data: rows[index]),
                    if (index < rows.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1 * scale,
                        color: const Color(0xFFDADCE1),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialProfileRow extends StatelessWidget {
  const _MaterialProfileRow({required this.scale, required this.data});

  final double scale;
  final _MaterialProfileRowData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: 82 * scale,
        child: Row(
          children: <Widget>[
            Icon(data.icon, color: const Color(0xFF3A454A), size: 32 * scale),
            SizedBox(width: 28 * scale),
            Expanded(
              child: Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF16181A),
                  fontSize: 27 * scale,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(width: 16 * scale),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF657077),
              size: 36 * scale,
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialLogoutButton extends StatelessWidget {
  const _MaterialLogoutButton({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, size: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFD10000),
          side: BorderSide(color: const Color(0xFFD10000), width: 1.3 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32 * scale),
          ),
          minimumSize: Size(246 * scale, 66 * scale),
          textStyle: textTheme.titleLarge?.copyWith(
            fontSize: 23 * scale,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _MaterialProfileRowData {
  const _MaterialProfileRowData({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class _CupertinoProfileContent extends StatelessWidget {
  const _CupertinoProfileContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 660).clamp(0.54, 1.0);

        return ColoredBox(
          color: const Color(0xFFF2F1F6),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              26 * scale,
              28 * scale,
              26 * scale,
              28 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _CupertinoProfileHeader(scale: scale),
                SizedBox(height: 84 * scale),
                _CupertinoProfileSummary(scale: scale),
                SizedBox(height: 58 * scale),
                _CupertinoProfileSection(
                  scale: scale,
                  title: l10n.profileAccountSection,
                  rows: <_CupertinoProfileRowData>[
                    _CupertinoProfileRowData(
                      title: l10n.profileMyAddresses,
                      icon: CupertinoIcons.location,
                    ),
                    _CupertinoProfileRowData(
                      title: l10n.profileMyOrders,
                      icon: CupertinoIcons.bag,
                    ),
                  ],
                ),
                SizedBox(height: 42 * scale),
                _CupertinoProfileSection(
                  scale: scale,
                  title: l10n.profilePersonalDetailsSection,
                  rows: <_CupertinoProfileRowData>[
                    _CupertinoProfileRowData(
                      title: l10n.profilePersonalInformation,
                    ),
                    _CupertinoProfileRowData(title: l10n.profilePaymentMethods),
                  ],
                ),
                SizedBox(height: 42 * scale),
                _CupertinoProfileSection(
                  scale: scale,
                  title: l10n.profileGeneralSection,
                  rows: <_CupertinoProfileRowData>[
                    _CupertinoProfileRowData(title: l10n.profileNotifications),
                    _CupertinoProfileRowData(title: l10n.profileHelpSupport),
                  ],
                ),
                SizedBox(height: 40 * scale),
                _CupertinoLogoutButton(label: l10n.profileLogOut, scale: scale),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CupertinoProfileHeader extends StatelessWidget {
  const _CupertinoProfileHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Text(
      l10n.navProfile,
      style: theme.textTheme.textStyle.copyWith(
        color: const Color(0xFF002B45),
        fontSize: 28 * scale,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _CupertinoProfileSummary extends StatelessWidget {
  const _CupertinoProfileSummary({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        Container(
          width: 92 * scale,
          height: 92 * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFEFA),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE5E7EE)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x21000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: EdgeInsets.all(15 * scale),
              child: Image.asset(
                'assets/branding/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: 34 * scale),
        Text(
          l10n.profileName,
          textAlign: TextAlign.center,
          style: theme.textTheme.textStyle.copyWith(
            color: const Color(0xFF171A20),
            fontSize: 36 * scale,
            fontWeight: FontWeight.w700,
            height: 1.08,
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          l10n.profileMembershipLevel,
          textAlign: TextAlign.center,
          style: theme.textTheme.textStyle.copyWith(
            color: const Color(0xFF727982),
            fontSize: 25 * scale,
            fontWeight: FontWeight.w400,
            height: 1.16,
          ),
        ),
      ],
    );
  }
}

class _CupertinoProfileSection extends StatelessWidget {
  const _CupertinoProfileSection({
    required this.scale,
    required this.title,
    required this.rows,
  });

  final double scale;
  final String title;
  final List<_CupertinoProfileRowData> rows;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 26 * scale, bottom: 16 * scale),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.textStyle.copyWith(
              color: const Color(0xFF747B84),
              fontSize: 25 * scale,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(18 * scale),
          child: ColoredBox(
            color: CupertinoColors.white,
            child: Column(
              children: <Widget>[
                for (var index = 0; index < rows.length; index++) ...[
                  _CupertinoProfileRow(scale: scale, data: rows[index]),
                  if (index < rows.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1 * scale,
                      color: const Color(0xFFE9EBEF),
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

class _CupertinoProfileRow extends StatelessWidget {
  const _CupertinoProfileRow({required this.scale, required this.data});

  final double scale;
  final _CupertinoProfileRowData data;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoButton(
      minimumSize: Size(0, 96 * scale),
      padding: EdgeInsets.fromLTRB(28 * scale, 0, 26 * scale, 0),
      onPressed: () {},
      child: Row(
        children: <Widget>[
          if (data.icon != null) ...[
            Icon(data.icon, color: const Color(0xFF002B45), size: 31 * scale),
            SizedBox(width: 26 * scale),
          ],
          Expanded(
            child: Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.textStyle.copyWith(
                color: CupertinoColors.black,
                fontSize: 28 * scale,
                fontWeight: FontWeight.w400,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(width: 16 * scale),
          Icon(
            CupertinoIcons.chevron_forward,
            color: const Color(0xFF717A80),
            size: 30 * scale,
          ),
        ],
      ),
    );
  }
}

class _CupertinoLogoutButton extends StatelessWidget {
  const _CupertinoLogoutButton({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18 * scale),
      child: ColoredBox(
        color: CupertinoColors.white,
        child: CupertinoButton(
          minimumSize: Size(0, 96 * scale),
          padding: EdgeInsets.zero,
          onPressed: () {},
          child: Text(
            label,
            style: theme.textTheme.textStyle.copyWith(
              color: CupertinoColors.systemRed,
              fontSize: 26 * scale,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _CupertinoProfileRowData {
  const _CupertinoProfileRowData({required this.title, this.icon});

  final String title;
  final IconData? icon;
}
