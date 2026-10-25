import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/features/location/application/qoshni_geocoding_service.dart';
import 'package:qoshni/features/location/application/qoshni_saved_places_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_geocoding_suggestion.dart';

Future<void> showQoshniGeocodeSaveSheet(
  BuildContext context, {
  required QoshniGeocodingService geocodingService,
  required QoshniSavedPlacesController savedPlacesController,
}) async {
  final l10n = AppLocalizations.of(context);
  if (!geocodingService.isProviderConfigured) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.geocodingUnavailableBody)),
    );
    return;
  }

  final queryController = TextEditingController();
  var loading = false;
  var suggestions = <QoshniGeocodingSuggestion>[];
  String? errorKey;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> runSearch() async {
            setModalState(() {
              loading = true;
              errorKey = null;
            });
            try {
              final results = await geocodingService.searchAddress(
                query: queryController.text,
              );
              setModalState(() {
                suggestions = results;
                loading = false;
              });
            } catch (_) {
              setModalState(() {
                loading = false;
                errorKey = 'unavailable';
                suggestions = const [];
              });
            }
          }

          Future<void> confirmSave(QoshniGeocodingSuggestion suggestion) async {
            final labelController = TextEditingController(text: suggestion.displayLabel);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.savedPlaceConfirmTitle),
                content: TextField(
                  controller: labelController,
                  decoration: InputDecoration(labelText: l10n.savedPlaceLabelField),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.searchClearQuery),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.savedPlaceSaveAction),
                  ),
                ],
              ),
            );
            if (confirmed != true || !context.mounted) {
              return;
            }
            await savedPlacesController.saveFromUserConfirmation(
              label: labelController.text.trim().isEmpty
                  ? suggestion.displayLabel
                  : labelController.text.trim(),
              coordinates: suggestion.coordinates,
              fromSuggestion: suggestion,
            );
            if (context.mounted) {
              Navigator.pop(context);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.md,
              bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.geocodingSearchTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: queryController,
                  decoration: InputDecoration(
                    hintText: l10n.geocodingSearchHint,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: loading ? null : runSearch,
                    ),
                  ),
                  onSubmitted: (_) => runSearch(),
                ),
                if (loading) const LinearProgressIndicator(),
                if (errorKey != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(l10n.geocodingUnavailableBody),
                  ),
                const SizedBox(height: AppSpacing.sm),
                ...suggestions.map(
                  (s) => ListTile(
                    title: Text(s.displayLabel),
                    subtitle: Text(l10n.geocodingSuggestionDisclaimer),
                    onTap: () => confirmSave(s),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
  queryController.dispose();
}
