import 'dart:async';

import 'package:feyam/core/di/injection_container.dart';
import 'package:feyam/core/widgets/adaptive/adaptive_platform.dart';
import 'package:feyam/core/widgets/cupertino/feyam_cupertino_kit.dart';
import 'package:feyam/core/widgets/feyam_hero_header.dart';
import 'package:feyam/features/cart/presentation/screens/add_to_cart.dart';
import 'package:feyam/features/product_search/domain/entities/product_search_item_entity.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_bloc.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_event.dart';
import 'package:feyam/features/product_search/presentation/bloc/product_search_state.dart';
import 'package:feyam/features/product_search/presentation/widgets/paste_link_fallback_card.dart';
import 'package:feyam/features/product_search/presentation/widgets/product_result_tile.dart';
import 'package:feyam/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

/// Real product search backed by Zinc, replacing the home screen's previous
/// paste-link-only entry point. Pass [initialRetailer] to open pre-filtered
/// to one store (e.g. from the stores list).
class ProductSearchScreen extends StatelessWidget {
  const ProductSearchScreen({super.key, this.initialRetailer});

  final String? initialRetailer;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<ProductSearchBloc>();
        final retailer = initialRetailer;
        if (retailer != null && retailer.isNotEmpty) {
          bloc.add(ProductSearchRetailerChanged(retailer));
        }
        return bloc;
      },
      child: const _ProductSearchView(),
    );
  }
}

class _ProductSearchView extends StatefulWidget {
  const _ProductSearchView();

  @override
  State<_ProductSearchView> createState() => _ProductSearchViewState();
}

class _ProductSearchViewState extends State<_ProductSearchView> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<ProductSearchBloc>().add(ProductSearchQueryChanged(value));
    });
  }

  void _openResult(ProductSearchItemEntity item) {
    Navigator.of(context).push(
      AdaptivePlatform.pageRoute(
        context: context,
        builder: (_) => AddToCartScreen(
          initialUrl: item.url,
          initialProductName: item.title,
          initialPriceAmount: item.price,
          initialImageUrl: item.imageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdaptivePlatform.isCupertino(context)
        ? _CupertinoProductSearch(
            controller: _controller,
            onQueryChanged: _onQueryChanged,
            onOpenResult: _openResult,
          )
        : _MaterialProductSearch(
            controller: _controller,
            onQueryChanged: _onQueryChanged,
            onOpenResult: _openResult,
          );
  }
}

// ── Material ─────────────────────────────────────────────────────────────────

class _MaterialProductSearch extends StatelessWidget {
  const _MaterialProductSearch({
    required this.controller,
    required this.onQueryChanged,
    required this.onOpenResult,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ProductSearchItemEntity> onOpenResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Column(
        children: <Widget>[
          FeyamHeroHeader(showBackButton: true, title: l10n.productSearchTitle),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(decoration: TextDecoration.none),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.outlineVariant),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        onChanged: onQueryChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.productSearchFieldHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: controller,
                            builder: (context, value, _) => value.text.isEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () {
                                      controller.clear();
                                      context.read<ProductSearchBloc>().add(
                                        const ProductSearchCleared(),
                                      );
                                    },
                                  ),
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: BlocBuilder<ProductSearchBloc, ProductSearchState>(
                      builder: (context, state) {
                        return switch (state.status) {
                          ProductSearchStatus.initial => _MaterialMessage(
                            icon: Icons.search_rounded,
                            title: l10n.productSearchInitialHint,
                          ),
                          ProductSearchStatus.loading => Center(
                            child: CircularProgressIndicator(
                              color: colors.primary,
                            ),
                          ),
                          ProductSearchStatus.failure => _MaterialMessage(
                            icon: Icons.error_outline_rounded,
                            title: l10n.productSearchErrorTitle,
                            actions: <Widget>[
                              FilledButton.tonal(
                                onPressed: () => context
                                    .read<ProductSearchBloc>()
                                    .add(const ProductSearchRetried()),
                                child: Text(l10n.productSearchRetry),
                              ),
                              const SizedBox(height: 12),
                              const PasteLinkFallbackCard(),
                            ],
                          ),
                          ProductSearchStatus.empty => _MaterialMessage(
                            icon: Icons.search_off_rounded,
                            title: l10n.productSearchEmptyTitle,
                            subtitle: l10n.productSearchEmptyBody,
                            actions: const <Widget>[PasteLinkFallbackCard()],
                          ),
                          ProductSearchStatus.loaded => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              if (state.isPartial)
                                _PartialBanner(
                                  text: l10n.productSearchPartialBanner,
                                ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    8,
                                  ),
                                  itemCount: state.items.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == state.items.length) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            if (state.nextPage != null)
                                              state.isLoadingMore
                                                  ? CircularProgressIndicator(
                                                      color: colors.primary,
                                                    )
                                                  : TextButton(
                                                      onPressed: () => context
                                                          .read<
                                                            ProductSearchBloc
                                                          >()
                                                          .add(
                                                            const ProductSearchNextPageRequested(),
                                                          ),
                                                      child: Text(
                                                        l10n.productSearchLoadMore,
                                                      ),
                                                    ),
                                            const SizedBox(height: 8),
                                            const PasteLinkFallbackCard(),
                                          ],
                                        ),
                                      );
                                    }
                                    final item = state.items[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: ProductResultTile(
                                        item: item,
                                        onTap: () => onOpenResult(item),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        };
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialMessage extends StatelessWidget {
  const _MaterialMessage({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            if (actions.isNotEmpty) ...[const SizedBox(height: 16), ...actions],
          ],
        ),
      ),
    );
  }
}

class _PartialBanner extends StatelessWidget {
  const _PartialBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

// ── Cupertino ────────────────────────────────────────────────────────────────

class _CupertinoProductSearch extends StatelessWidget {
  const _CupertinoProductSearch({
    required this.controller,
    required this.onQueryChanged,
    required this.onOpenResult,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<ProductSearchItemEntity> onOpenResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: kFeyamBg,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            FeyamNavBar(title: l10n.productSearchTitle, backLabel: 'Inicio'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: CupertinoSearchTextField(
                controller: controller,
                placeholder: l10n.productSearchFieldHint,
                autofocus: true,
                onChanged: onQueryChanged,
                onSuffixTap: () {
                  controller.clear();
                  context.read<ProductSearchBloc>().add(
                    const ProductSearchCleared(),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<ProductSearchBloc, ProductSearchState>(
                builder: (context, state) {
                  return switch (state.status) {
                    ProductSearchStatus.initial => FeyamEmptyState(
                      icon: CupertinoIcons.search,
                      title: l10n.productSearchInitialHint,
                    ),
                    ProductSearchStatus.loading => const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                    ProductSearchStatus.failure => FeyamEmptyState(
                      icon: CupertinoIcons.exclamationmark_triangle,
                      title: l10n.productSearchErrorTitle,
                      action: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FeyamButton(
                            label: l10n.productSearchRetry,
                            variant: FeyamButtonVariant.tinted,
                            onPressed: () => context
                                .read<ProductSearchBloc>()
                                .add(const ProductSearchRetried()),
                          ),
                          const SizedBox(height: 12),
                          const PasteLinkFallbackCard(),
                        ],
                      ),
                    ),
                    ProductSearchStatus.empty => FeyamEmptyState(
                      icon: CupertinoIcons.search,
                      title: l10n.productSearchEmptyTitle,
                      subtitle: l10n.productSearchEmptyBody,
                      action: const PasteLinkFallbackCard(),
                    ),
                    ProductSearchStatus.loaded => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (state.isPartial)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              l10n.productSearchPartialBanner,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: kFeyamLabelSec,
                              ),
                            ),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                FeyamListSection(
                                  children: <Widget>[
                                    for (var i = 0; i < state.items.length; i++)
                                      _CupertinoResultTile(
                                        item: state.items[i],
                                        isLast: i == state.items.length - 1,
                                        onTap: () =>
                                            onOpenResult(state.items[i]),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      if (state.nextPage != null)
                                        state.isLoadingMore
                                            ? const CupertinoActivityIndicator()
                                            : FeyamButton(
                                                label:
                                                    l10n.productSearchLoadMore,
                                                variant:
                                                    FeyamButtonVariant.plain,
                                                onPressed: () => context
                                                    .read<ProductSearchBloc>()
                                                    .add(
                                                      const ProductSearchNextPageRequested(),
                                                    ),
                                              ),
                                      const SizedBox(height: 8),
                                      const PasteLinkFallbackCard(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoResultTile extends StatelessWidget {
  const _CupertinoResultTile({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final ProductSearchItemEntity item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = item.price;

    return FeyamListTile(
      isLast: isLast,
      onTap: onTap,
      chevron: false,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          color: kFeyamFillTer,
          child: item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    CupertinoIcons.cube_box,
                    color: kFeyamLabelSec,
                  ),
                )
              : const Icon(CupertinoIcons.cube_box, color: kFeyamLabelSec),
        ),
      ),
      title: Text(item.title),
      subtitle: Text(item.retailer),
      trailing: Text(
        price != null
            ? '\$${price.toStringAsFixed(2)}'
            : l10n.productSearchPriceUnknown,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
