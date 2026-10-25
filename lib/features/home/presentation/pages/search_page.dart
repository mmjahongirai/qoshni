import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/responsive/responsive_layout.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/application/qoshni_search_autocomplete_service.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_coordinator.dart';
import 'package:qoshni/features/search/domain/qoshni_search_autocomplete_suggestion.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';
import 'package:qoshni/features/search/domain/qoshni_search_result_item.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';
import 'package:qoshni/core/widgets/primary_navigation_shell.dart';
import 'package:qoshni/features/home/presentation/widgets/search_result_tile.dart';
import 'package:qoshni/features/location/application/qoshni_search_location_selection_controller.dart';
import 'package:qoshni/features/location/application/qoshni_saved_places_controller.dart';
import 'package:qoshni/features/search/domain/qoshni_search_filters.dart';
import 'package:qoshni/features/search/presentation/qoshni_search_nearby_location_bar.dart';
import 'package:qoshni/features/search/application/qoshni_search_map_focus_controller.dart';
import 'package:qoshni/routing/route_paths.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _queryController;
  List<QoshniSearchResultItem> _resultItems = const [];
  String? _nextCursor;
  QoshniSearchExecutionStatus _executionStatus =
      QoshniSearchExecutionStatus.success;
  QoshniSearchQueryUnderstanding? _understanding;
  String _lastQuerySnapshot = '';
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
    _queryController.addListener(_onQueryChanged);
    getIt<QoshniSavedPlacesController>().refresh();
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _queryController.text;
    if (query == _lastQuerySnapshot) {
      return;
    }
    _refreshFirstPage(query);
  }

  void _clearQuery() {
    _queryController.clear();
  }

  void _refreshFirstPage(String query) {
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    final catalog = buildSearchCatalog(l10n, Theme.of(context).colorScheme);
    final processor = getIt<QoshniSearchQueryProcessor>();
    final execution = getIt<QoshniSearchExecutionCoordinator>();
    final understanding = processor.understand(rawQuery: query);
    final selection = getIt<QoshniSearchLocationSelectionController>();
    final filters = selection.applyTo(const QoshniSearchFilters());
    execution
        .execute(
      request: QoshniSearchRequest(rawQuery: query, filters: filters),
      catalog: catalog,
      understanding: understanding,
    )
        .then((page) {
      if (!mounted) {
        return;
      }
      setState(() {
      _lastQuerySnapshot = query;
      _understanding = understanding;
      _executionStatus = page.status;
      _resultItems = page.items;
      _nextCursor = page.nextCursor;
      _loadingMore = false;
      });
    });
  }

  Future<void> _loadMore() async {
    if (_nextCursor == null || _loadingMore) {
      return;
    }
    setState(() => _loadingMore = true);
    final query = _queryController.text;
    final l10n = AppLocalizations.of(context);
    final catalog = buildSearchCatalog(l10n, Theme.of(context).colorScheme);
    final execution = getIt<QoshniSearchExecutionCoordinator>();
    final selection = getIt<QoshniSearchLocationSelectionController>();
    final filters = selection.applyTo(const QoshniSearchFilters());
    final page = await execution.execute(
      request: QoshniSearchRequest(
        rawQuery: query,
        cursor: _nextCursor,
        filters: filters,
      ),
      catalog: catalog,
      understanding: _understanding,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _loadingMore = false;
      if (page.status == QoshniSearchExecutionStatus.success) {
        _resultItems = [..._resultItems, ...page.items];
        _nextCursor = page.nextCursor;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = _queryController.text;
    final autocomplete = getIt<QoshniSearchAutocompleteService>();
    final suggestions = autocomplete.suggest(rawQuery: query);
    final spelling = _understanding?.spellingCorrection;

    return PrimaryNavigationShell(
      destination: PrimaryNavDestination.search,
      body: Scaffold(
        appBar: AppBar(
          leading: primaryTabLeading(context),
          title: Text(l10n.searchTitle),
        ),
        body: SafeArea(
          child: ResponsiveLayout(
            phone: _SearchBody(
              maxWidth: 520,
              l10n: l10n,
              queryController: _queryController,
              query: query,
              resultItems: _resultItems,
              executionStatus: _executionStatus,
              suggestions: suggestions,
              spellingSuggestion: spelling?.suggestedText,
              onClearQuery: _clearQuery,
              hasMore: _nextCursor != null,
              loadingMore: _loadingMore,
              onLoadMore: _loadMore,
              onRetrySearch: () => _refreshFirstPage(query),
              onNearbyChanged: () => _refreshFirstPage(query),
            ),
            tablet: _SearchBody(
              maxWidth: 760,
              l10n: l10n,
              queryController: _queryController,
              query: query,
              resultItems: _resultItems,
              executionStatus: _executionStatus,
              suggestions: suggestions,
              spellingSuggestion: spelling?.suggestedText,
              onClearQuery: _clearQuery,
              hasMore: _nextCursor != null,
              loadingMore: _loadingMore,
              onLoadMore: _loadMore,
              onRetrySearch: () => _refreshFirstPage(query),
              onNearbyChanged: () => _refreshFirstPage(query),
            ),
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
    required this.resultItems,
    required this.executionStatus,
    required this.suggestions,
    this.spellingSuggestion,
    required this.onClearQuery,
    required this.hasMore,
    required this.loadingMore,
    required this.onLoadMore,
    required this.onRetrySearch,
    required this.onNearbyChanged,
  });

  final double maxWidth;
  final AppLocalizations l10n;
  final TextEditingController queryController;
  final String query;
  final List<QoshniSearchResultItem> resultItems;
  final QoshniSearchExecutionStatus executionStatus;
  final List<QoshniSearchAutocompleteSuggestion> suggestions;
  final String? spellingSuggestion;
  final VoidCallback onClearQuery;
  final bool hasMore;
  final bool loadingMore;
  final VoidCallback onLoadMore;
  final VoidCallback onRetrySearch;
  final VoidCallback onNearbyChanged;

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
              if (spellingSuggestion != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${l10n.searchSpellingSuggestionLabel}: $spellingSuggestion',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final item in suggestions)
                      ActionChip(
                        label: Text(item.displayText),
                        onPressed: () {
                          queryController.text = item.displayText;
                          queryController.selection = TextSelection.collapsed(
                            offset: item.displayText.length,
                          );
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              QoshniSearchNearbyLocationBar(onChanged: onNearbyChanged),
              const SizedBox(height: 12),
              Expanded(
                child: !hasQuery
                    ? AppEmptyState(
                        icon: Icons.manage_search_outlined,
                        title: l10n.searchInitialTitle,
                        message: l10n.searchInitialBody,
                      )
                    : executionStatus ==
                            QoshniSearchExecutionStatus.remoteUnauthorized
                        ? AppEmptyState(
                            icon: Icons.lock_outline,
                            title: l10n.searchRemoteUnauthorizedTitle,
                            message: l10n.searchRemoteUnauthorizedBody,
                            action: TextButton(
                              onPressed: onRetrySearch,
                              child: Text(l10n.searchRemoteRetry),
                            ),
                          )
                        : executionStatus ==
                                QoshniSearchExecutionStatus.remoteUnavailable
                            ? AppEmptyState(
                                icon: Icons.cloud_off_outlined,
                                title: l10n.searchRemoteUnavailableTitle,
                                message: l10n.searchRemoteUnavailableBody,
                                action: TextButton(
                                  onPressed: onRetrySearch,
                                  child: Text(l10n.searchRemoteRetry),
                                ),
                              )
                            : executionStatus ==
                                    QoshniSearchExecutionStatus.invalidCursor
                                ? AppEmptyState(
                                    icon: Icons.sync_problem_outlined,
                                    title: l10n.searchEmptyTitle,
                                    message: l10n.searchEmptyBody,
                                  )
                                : executionStatus ==
                                            QoshniSearchExecutionStatus
                                                .success &&
                                        resultItems.isEmpty
                                    ? AppEmptyState(
                                        icon: Icons.search_off_outlined,
                                        title: l10n.searchEmptyTitle,
                                        message: l10n.searchEmptyBody,
                                      )
                                    : ListView.separated(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount:
                                    resultItems.length + (hasMore ? 1 : 0),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  if (index >= resultItems.length) {
                                    return TextButton(
                                      onPressed:
                                          loadingMore ? null : onLoadMore,
                                      child: loadingMore
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(l10n.searchLoadMore),
                                    );
                                  }
                                  final item = resultItems[index];
                                  return SearchResultTile(
                                    entry: item.catalogEntry,
                                    showSponsoredLabel:
                                        item.showSponsoredLabel,
                                    sponsoredLabel: l10n.searchSponsoredLabel,
                                    trailing: item.hasVerifiedMapLocation
                                        ? IconButton(
                                            tooltip: l10n.searchShowOnMapAction,
                                            icon: const Icon(Icons.map_outlined),
                                            onPressed: () {
                                              final loc = item
                                                  .verifiedBranchLocation!
                                                  .searchLocation;
                                              getIt<
                                                      QoshniSearchMapFocusController>()
                                                  .focusOn(
                                                resultTitle:
                                                    item.catalogEntry.title,
                                                searchLocation: loc,
                                              );
                                              context.push(RoutePaths.map);
                                            },
                                          )
                                        : null,
                                  );
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
