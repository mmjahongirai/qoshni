import 'package:flutter/material.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/theme/app_tokens.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/location/application/qoshni_map_location_controller.dart';
import 'package:qoshni/features/location/application/qoshni_saved_places_controller.dart';
import 'package:qoshni/features/location/application/qoshni_search_location_selection_controller.dart';
import 'package:qoshni/features/location/domain/qoshni_location_search_policy.dart';
import 'package:qoshni/features/location/domain/qoshni_search_location_origin.dart';

class QoshniSearchNearbyLocationBar extends StatelessWidget {
  const QoshniSearchNearbyLocationBar({required this.onChanged, super.key});

  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selection = getIt<QoshniSearchLocationSelectionController>();
    final savedPlaces = getIt<QoshniSavedPlacesController>();
    final mapLocation = getIt<QoshniMapLocationController>();

    return ListenableBuilder(
      listenable: Listenable.merge([selection, savedPlaces, mapLocation]),
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.searchNearbyEnableLabel),
              subtitle: Text(_originLabel(l10n, selection)),
              value: selection.nearbySearchEnabled,
              onChanged: (enabled) {
                if (!enabled) {
                  selection.clear();
                } else if (mapLocation.deviceSnapshot?.isDeviceDerived == true) {
                  selection.useDeviceFix(mapLocation);
                } else if (savedPlaces.places.isNotEmpty) {
                  selection.useSavedPlace(savedPlaces.places.first);
                } else {
                  selection.enableNearbyWithoutOrigin();
                }
                onChanged();
              },
            ),
            if (selection.nearbySearchEnabled) ...[
              if (savedPlaces.places.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: l10n.searchNearbySavedPlaceLabel),
                  value: selection.origin.savedPlace?.id ??
                      savedPlaces.places.first.id,
                  items: [
                    for (final place in savedPlaces.places)
                      DropdownMenuItem(
                        value: place.id,
                        child: Text(place.label),
                      ),
                  ],
                  onChanged: (id) {
                    final place = savedPlaces.places.firstWhere((p) => p.id == id);
                    selection.useSavedPlace(place);
                    onChanged();
                  },
                ),
              Row(
                children: [
                  Expanded(
                    child: Text('${l10n.searchNearbyRadiusPrefix} ${selection.nearbyRadiusMeters} m'),
                  ),
                  IconButton(
                    tooltip: l10n.searchNearbyUseDeviceAction,
                    onPressed: mapLocation.deviceSnapshot?.isDeviceDerived == true
                        ? () {
                            selection.useDeviceFix(mapLocation);
                            onChanged();
                          }
                        : null,
                    icon: const Icon(Icons.my_location_outlined),
                  ),
                ],
              ),
              Slider(
                min: kQoshniSearchMinRadiusMeters.toDouble(),
                max: kQoshniSearchMaxRadiusMeters.toDouble(),
                divisions: 8,
                value: selection.nearbyRadiusMeters.toDouble(),
                label: '${selection.nearbyRadiusMeters} m',
                onChanged: (value) {
                  selection.setRadiusMeters(value.round());
                  onChanged();
                },
              ),
            ],
          ],
        );
      },
    );
  }

  String _originLabel(AppLocalizations l10n, QoshniSearchLocationSelectionController selection) {
    switch (selection.origin.kind) {
      case QoshniSearchLocationOriginKind.none:
        return l10n.searchNearbyOriginNone;
      case QoshniSearchLocationOriginKind.deviceFix:
        return l10n.searchNearbyOriginDevice;
      case QoshniSearchLocationOriginKind.savedPlace:
        return '${l10n.searchNearbyOriginSavedPlacePrefix} ${selection.origin.savedPlace?.label ?? ''}';
      case QoshniSearchLocationOriginKind.manualMapPoint:
        return l10n.searchNearbyOriginManual;
    }
  }
}
