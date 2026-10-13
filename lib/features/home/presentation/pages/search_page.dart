import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/widgets/search_result_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() {});
  }

  void _clearQuery() {
    _queryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _queryController.text;
    final catalog = buildSearchCatalog(l10n, Theme.of(context).colorScheme);
    final results = filterSearchCatalog(catalog, query);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.searchTitle),
      ),
      body: SafeArea(
        child: ResponsiveLayout(
          phone: _SearchBody(
            maxWidth: 520,
            l10n: l10n,
            queryController: _queryController,
            query: query,
            results: results,
            onClearQuery: _clearQuery,
          ),
          tablet: _SearchBody(
            maxWidth: 760,
            l10n: l10n,
            queryController: _queryController,
            query: query,
            results: results,
            onClearQuery: _clearQuery,
          ),
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.maxWidth,
    required this.l10n,
    required this.queryController,
    required this.query,
    required this.results,
    required this.onClearQuery,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final TextEditingController queryController;
  final String query;
  final List<SearchCatalogEntry> results;
  final VoidCallback onClearQuery;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasQuery = query.trim().isNotEmpty;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: responsivePagePadding(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: queryController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.homeSearchHint,
                  prefixIcon: Icon(
                    Icons.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: hasQuery
                      ? IconButton(
                          tooltip: l10n.searchClearQuery,
                          onPressed: onClearQuery,
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: !hasQuery
                    ? _SearchMessageState(
                        icon: Icons.manage_search_outlined,
                        title: l10n.searchInitialTitle,
                        body: l10n.searchInitialBody,
                      )
                    : results.isEmpty
                        ? _SearchMessageState(
                            icon: Icons.search_off_outlined,
                            title: l10n.searchEmptyTitle,
                            body: l10n.searchEmptyBody,
                          )
                        : ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: results.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return SearchResultTile(entry: results[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchMessageState extends StatelessWidget {
  const _SearchMessageState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
