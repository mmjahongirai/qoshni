import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/home/presentation/widgets/qoshni_mapbox_view.dart';

/// Full-screen map route — Mapbox when configured, otherwise setup placeholder.
class MapPlaceholderPage extends StatelessWidget {
  const MapPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(l10n.mapPlaceholderTitle),
      ),
      body: const SafeArea(
        child: QoshniMapboxView(showDefaultViewLabel: true),
      ),
    );
  }
}
