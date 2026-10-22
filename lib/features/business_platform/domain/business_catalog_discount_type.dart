enum BusinessCatalogDiscountType {
  percentage,
  fixedAmount,
}

/// Percentage discounts use basis points: 1_000 = 10.00%, 10_000 = 100%.
const int kBusinessCatalogDiscountBasisPointsMax = 10000;
