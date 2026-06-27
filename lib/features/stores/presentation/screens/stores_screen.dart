import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/features/stores/domain/entities/store_entity.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_event.dart';
import 'package:feyam/features/stores/presentation/bloc/stores_state.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              appBar: AppBar(
                backgroundColor: colors.surfaceContainer,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back_rounded, size: 24 * scale),
                ),
                title: Text(
                  l10n.storesTitle,
                  style: textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              body: switch (state.status) {
                StoresStatus.initial || StoresStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                StoresStatus.failure => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 48, color: colors.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          l10n.storesLoadError,
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context
                            .read<StoresBloc>()
                            .add(const StoresLoadRequested()),
                          child: Text(l10n.storesRetry),
                        ),
                      ],
                    ),
                  ),
                StoresStatus.loaded => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            20 * scale, 12 * scale, 20 * scale, 4 * scale),
                        child: Text(
                          l10n.storesHint,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 14 * scale,
                            height: 1.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding:
                              EdgeInsets.symmetric(vertical: 8 * scale),
                          itemCount: state.stores.length,
                          itemBuilder: (context, index) {
                            return _StoreListTile(
                              scale: scale,
                              store: state.stores[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              },
            );
          },
        );
      },
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

    return InkWell(
      onTap: () => _openStore(store.host),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 8 * scale, vertical: 4 * scale),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8 * scale),
              child: Container(
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
            ),
            SizedBox(width: 4 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    store.name,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 16 * scale,
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
            Padding(
              padding: EdgeInsets.all(12 * scale),
              child: Icon(
                Icons.open_in_new_rounded,
                size: 20 * scale,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
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
                  StoresStatus.failure => const Center(
                      child: Text(
                        'No se pudieron cargar las tiendas.',
                        style: TextStyle(
                            fontSize: 15,
                            color: kFeyamLabelSec,
                            fontFamily: '.SF Pro Text'),
                      ),
                    ),
                  StoresStatus.loaded => SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.fromLTRB(32, 12, 32, 4),
                            child: Text(
                              'Tocá una tienda para abrirla en tu navegador. Copiá el link del producto y pegalo en Feyam.',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: kFeyamLabelSec,
                                  height: 1.4,
                                  fontFamily: '.SF Pro Text'),
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
                                  trailing: const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Icon(
                                        CupertinoIcons.arrow_up_right_square,
                                        size: 18,
                                        color: kFeyamTint),
                                  ),
                                  chevron: false,
                                  isLast: i == state.stores.length - 1,
                                  onTap: () => _openStore(state.stores[i].host),
                                ),
                            ],
                          ),
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '¿No encontrás tu tienda? Contactanos por Ayuda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: kFeyamLabelTer,
                                  fontFamily: '.SF Pro Text'),
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
