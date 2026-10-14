import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/core/widgets/app_empty_state.dart';

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
      body: Center(
        child: AppEmptyState(
          icon: Icons.map_outlined,
          title: l10n.mapPlaceholderTitle,
          message: l10n.mapPlaceholderBody,
        ),
      ),
    );
  }
}
