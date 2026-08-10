import 'package:feyam/core/utils/zinc_retailer_slug.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/product_search/presentation/screens/product_search_screen.dart';
import 'package:feyam/features/stores/domain/entities/store_entity.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_event.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_state.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoresBloc>().add(const StoresLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AdaptivePlatform.isCupertino(context)) {
      return const _CupertinoStoresContent();
    }

    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<StoresBloc, StoresState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final scale = (constraints.maxWidth / 390).clamp(0.9, 1.1);

            return Scaffold(
              backgroundColor: colors.surface,
              body: Column(
                children: <Widget>[
                  _StoresHeroHeader(scale: scale),
                  Expanded(
                    child: switch (state.status) {
                      StoresStatus.initial ||
                      StoresStatus.loading => Center(
                        child: SizedBox(
                          width: 28 * scale,
                          height: 28 * scale,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      StoresStatus.failure => Center(
                        child: Padding(
                          padding: EdgeInsets.all(24 * scale),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                l10n.storesLoadError,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 14 * scale,
                                ),
                              ),
                              SizedBox(height: 12 * scale),
                              FilledButton.tonal(
                                onPressed: () => context.read<StoresBloc>().add(
                                  const StoresLoadRequested(),
                                ),
                                child: Text(l10n.storesRetry),
                              ),
                            ],
                          ),
                        ),
                      ),
                      StoresStatus.loaded => ListView.separated(
                        padding: EdgeInsets.all(16 * scale),
                        itemCount: state.stores.length + 1,
                        separatorBuilder: (_, _) => SizedBox(height: 10 * scale),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 4 * scale),
                              child: Text(
                                l10n.storesHint,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13.5 * scale,
                                  height: 1.4,
                                ),
                              ),
                            );
                          }
                          return _StoreListTile(
                            scale: scale,
                            store: state.stores[index - 1],
                          );
                        },
                      ),
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StoresHeroHeader extends StatelessWidget {
  const _StoresHeroHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            12 * scale,
            6 * scale,
            16 * scale,
            20 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 36 * scale,
                      minHeight: 36 * scale,
                    ),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: colors.onPrimary,
                      size: 22 * scale,
                    ),
                  ),
                  Image.asset(
                    'assets/branding/logo_white.png',
                    height: 22 * scale,
                  ),
                ],
              ),
              SizedBox(height: 14 * scale),
              Text(
                l10n.storesTitle,
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openStore(String host) async {
  final uri = Uri.parse('https://$host');
  try {
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } on PlatformException {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _openStoreSearch(BuildContext context, String host) {
  Navigator.of(context).push(
    AdaptivePlatform.pageRoute(
      context: context,
      builder: (_) => ProductSearchScreen(initialRetailer: zincRetailerSlugFromHost(host)),
    ),
  );
}

IconData _materialIconFromName(String iconName) => switch (iconName) {
      'shopping_bag' => Icons.shopping_bag_rounded,
      'gavel' => Icons.gavel_rounded,
      'storefront' => Icons.storefront_rounded,
      'devices' => Icons.devices_rounded,
      'checkroom' => Icons.checkroom_rounded,
      'local_mall' => Icons.local_mall_rounded,
      _ => Icons.store_rounded,
    };

Color _colorFromHex(String hex) =>
    Color(int.parse('FF$hex', radix: 16));

class _StoreListTile extends StatelessWidget {
  const _StoreListTile({required this.scale, required this.store});

  final double scale;
  final StoreEntity store;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final searchable = zincRetailerSlugFromHost(store.host) != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => searchable
            ? _openStoreSearch(context, store.host)
            : _openStore(store.host),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 10 * scale,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: _colorFromHex(store.colorHex),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(
                  _materialIconFromName(store.iconName),
                  color: Colors.white,
                  size: 22 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      store.name,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 15 * scale,
                      ),
                    ),
                    Text(
                      store.host,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 13 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _openStore(store.host),
                tooltip: store.host,
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 20 * scale,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cupertino Stores ──────────────────────────────────────────────────────────

IconData _cupertinoIconFromName(String iconName) => switch (iconName) {
      'shopping_bag' => CupertinoIcons.bag_fill,
      'gavel' => CupertinoIcons.hammer_fill,
      'storefront' => CupertinoIcons.building_2_fill,
      'devices' => CupertinoIcons.desktopcomputer,
      'checkroom' => CupertinoIcons.tag_fill,
      'local_mall' => CupertinoIcons.bag_fill,
      _ => CupertinoIcons.bag,
    };

class _CupertinoStoresContent extends StatefulWidget {
  const _CupertinoStoresContent();

  @override
  State<_CupertinoStoresContent> createState() =>
      _CupertinoStoresContentState();
}

class _CupertinoStoresContentState extends State<_CupertinoStoresContent> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresBloc, StoresState>(
      builder: (context, state) {
        return ColoredBox(
          color: kFeyamBg,
          child: Column(
            children: <Widget>[
              CupertinoNavigationBar(
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(CupertinoIcons.chevron_back, size: 18),
                      SizedBox(width: 2),
                      Text('Inicio', style: TextStyle(fontSize: 17)),
                    ],
                  ),
                ),
                middle: const Text('Tiendas soportadas'),
              ),
              Expanded(
                child: switch (state.status) {
                  StoresStatus.initial ||
                  StoresStatus.loading =>
                    const Center(child: CupertinoActivityIndicator()),
                  StoresStatus.failure => Center(
                      child: Text(
                        'No se pudieron cargar las tiendas.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: kFeyamLabelSec,
                        ),
                      ),
                    ),
                  StoresStatus.loaded => SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 12, 32, 4),
                            child: Text(
                              'Tocá una tienda para buscar productos ahí. Usá el ícono para abrirla en tu navegador.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: kFeyamLabelSec,
                                height: 1.4,
                              ),
                            ),
                          ),
                          FeyamListSection(
                            children: <Widget>[
                              for (var i = 0;
                                  i < state.stores.length;
                                  i++)
                                FeyamListTile(
                                  title: Text(state.stores[i].name),
                                  detail: Text(state.stores[i].host),
                                  leading: FeyamIconTile(
                                    icon: _cupertinoIconFromName(
                                        state.stores[i].iconName),
                                    color: _colorFromHex(
                                        state.stores[i].colorHex),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () =>
                                        _openStore(state.stores[i].host),
                                    child: const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(
                                          CupertinoIcons.arrow_up_right_square,
                                          size: 18,
                                          color: kFeyamTint),
                                    ),
                                  ),
                                  chevron: false,
                                  isLast: i == state.stores.length - 1,
                                  onTap: () => zincRetailerSlugFromHost(
                                              state.stores[i].host) !=
                                          null
                                      ? _openStoreSearch(
                                          context, state.stores[i].host)
                                      : _openStore(state.stores[i].host),
                                ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '¿No encontrás tu tienda? Contactanos por Ayuda',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: kFeyamLabelTer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
