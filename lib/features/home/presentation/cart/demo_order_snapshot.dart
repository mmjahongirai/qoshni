import 'package:qoshni/features/checkout/domain/qoshni_price_quote.dart';
import 'package:qoshni/features/home/presentation/cart/cart_controller.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';
import 'package:qoshni/features/home/presentation/data/mock_catalog_item_id.dart';

class DemoOrderLineSnapshot {
  const DemoOrderLineSnapshot({
    required this.businessId,
    required this.catalogItemId,
    required this.itemName,
    required this.businessName,
    required this.quantity,
    required this.unitPriceUzs,
  });

  final MockBusinessId businessId;
  final MockCatalogItemId catalogItemId;
  final String itemName;
  final String businessName;
  final int quantity;
  final int unitPriceUzs;

  int get subtotalUzs => unitPriceUzs * quantity;
}

/// Immutable in-memory demo order captured at confirmation time.
class DemoOrderSnapshot {
  DemoOrderSnapshot({
    required this.referenceId,
    required this.confirmedAt,
    required this.lines,
    required this.totalUzs,
  });

  final String referenceId;
  final DateTime confirmedAt;
  final List<DemoOrderLineSnapshot> lines;
  final int totalUzs;

  int get lineCount => lines.length;

  int get totalUnits =>
      lines.fold<int>(0, (sum, line) => sum + line.quantity);

  static DemoOrderSnapshot? fromPriceQuote({
    required QoshniPriceQuote quote,
  }) {
    if (quote.lines.isEmpty) {
      return null;
    }
    final snapshotLines = quote.lines
        .map(
          (line) => DemoOrderLineSnapshot(
            businessId: tryParseMockBusinessId(line.businessStableId)!,
            catalogItemId:
                tryParseMockCatalogItemId(line.catalogItemStableId)!,
            itemName: line.titleSnapshot,
            businessName: line.businessTitleSnapshot,
            quantity: line.quantity,
            unitPriceUzs: line.unitPriceSom,
          ),
        )
        .toList(growable: false);

    final referenceId =
        'DEMO-${quote.quotedAt.toUtc().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';

    return DemoOrderSnapshot(
      referenceId: referenceId,
      confirmedAt: quote.quotedAt.toLocal(),
      lines: snapshotLines,
      totalUzs: quote.totalSom,
    );
  }

  static DemoOrderSnapshot? fromResolvedCartLines({
    required List<ResolvedCartLine> lines,
    required int totalUzs,
  }) {
    if (lines.isEmpty) {
      return null;
    }

    final snapshotLines = lines
        .map(
          (line) => DemoOrderLineSnapshot(
            businessId: line.key.businessId,
            catalogItemId: line.key.catalogItemId,
            itemName: line.catalogItem.name,
            businessName: line.businessName,
            quantity: line.quantity,
            unitPriceUzs: line.unitPriceUzs,
          ),
        )
        .toList(growable: false);

    final referenceId =
        'DEMO-${DateTime.now().toUtc().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';

    return DemoOrderSnapshot(
      referenceId: referenceId,
      confirmedAt: DateTime.now(),
      lines: snapshotLines,
      totalUzs: totalUzs,
    );
  }
}
