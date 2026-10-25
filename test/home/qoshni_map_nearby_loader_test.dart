import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/home/presentation/map/qoshni_map_nearby_loader.dart';
import 'package:qoshni/features/location/domain/qoshni_current_location_snapshot.dart';
import 'package:qoshni/features/location/domain/qoshni_geo_coordinates.dart';
import 'package:qoshni/features/location/domain/qoshni_location_kind.dart';
import 'package:qoshni/features/location/domain/qoshni_location_source.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_coordinator.dart';
import 'package:qoshni/features/search/application/qoshni_search_query_processor.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await configureDependencies(
      AppConfig.forEnvironment(AppEnvironment.development),
    );
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('demo nearby load returns no verified branch markers', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    final catalog = buildSearchCatalog(l10n, const ColorScheme.light());
    final snapshot = QoshniCurrentLocationSnapshot(
      coordinates: QoshniGeoCoordinates.create(latitude: 41.31, longitude: 69.28),
      kind: QoshniLocationKind.deviceCurrent,
      source: QoshniLocationSource.gps,
      acquiredAt: DateTime.utc(2026, 1, 1),
    );

    final markers = await qoshniLoadVerifiedMapBranchMarkers(
      execution: getIt<QoshniSearchExecutionCoordinator>(),
      queryProcessor: getIt<QoshniSearchQueryProcessor>(),
      catalog: catalog,
      deviceSnapshot: snapshot,
    );

    expect(markers, isEmpty);
  });
}
