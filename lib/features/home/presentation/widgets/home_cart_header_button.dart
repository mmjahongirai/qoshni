import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/di/injection.dart';
import 'package:qoshni/features/home/presentation/cart/cart_controller.dart';
import 'package:qoshni/routing/route_paths.dart';

class HomeCartHeaderButton extends StatelessWidget {
  const HomeCartHeaderButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cartController = getIt<CartController>();

    return ListenableBuilder(
      listenable: cartController,
      builder: (context, _) {
        final count = cartController.totalUnitCount;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          child: IconButton(
            tooltip: l10n.cartOpenTooltip,
            visualDensity: VisualDensity.compact,
            onPressed: () => context.pushNamed(RouteNames.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}
