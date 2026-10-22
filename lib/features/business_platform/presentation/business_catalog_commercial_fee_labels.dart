import 'package:qoshni/core/localization/generated/app_localizations.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_application_basis.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_calculation_type.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_charge_bearer.dart';
import 'package:qoshni/features/business_platform/domain/business_catalog_commercial_fee_type.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_commercial_fee_preview.dart';
import 'package:qoshni/features/business_platform/presentation/business_catalog_pricing_validation.dart';

extension BusinessCatalogCommercialFeeTypeLabels
    on BusinessCatalogCommercialFeeType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogCommercialFeeType.platformFee:
        return l10n.catalogCommercialFeeTypePlatform;
      case BusinessCatalogCommercialFeeType.serviceFee:
        return l10n.catalogCommercialFeeTypeService;
      case BusinessCatalogCommercialFeeType.deliveryFee:
        return l10n.catalogCommercialFeeTypeDelivery;
      case BusinessCatalogCommercialFeeType.commission:
        return l10n.catalogCommercialFeeTypeCommission;
    }
  }
}

extension BusinessCatalogCommercialFeeChargeBearerLabels
    on BusinessCatalogCommercialFeeChargeBearer {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogCommercialFeeChargeBearer.customer:
        return l10n.catalogCommercialFeeBearerCustomer;
      case BusinessCatalogCommercialFeeChargeBearer.business:
        return l10n.catalogCommercialFeeBearerBusiness;
      case BusinessCatalogCommercialFeeChargeBearer.platformAccounting:
        return l10n.catalogCommercialFeeBearerPlatform;
    }
  }
}

extension BusinessCatalogCommercialFeeCalculationTypeLabels
    on BusinessCatalogCommercialFeeCalculationType {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogCommercialFeeCalculationType.fixedAmount:
        return l10n.catalogCommercialFeeCalcFixed;
      case BusinessCatalogCommercialFeeCalculationType.percentage:
        return l10n.catalogCommercialFeeCalcPercent;
    }
  }
}

extension BusinessCatalogCommercialFeeApplicationBasisLabels
    on BusinessCatalogCommercialFeeApplicationBasis {
  String label(AppLocalizations l10n) {
    switch (this) {
      case BusinessCatalogCommercialFeeApplicationBasis.listingBase:
        return l10n.catalogCommercialFeeBasisListing;
      case BusinessCatalogCommercialFeeApplicationBasis.serviceAmount:
        return l10n.catalogCommercialFeeBasisService;
      case BusinessCatalogCommercialFeeApplicationBasis.deliveryBasis:
        return l10n.catalogCommercialFeeBasisDelivery;
      case BusinessCatalogCommercialFeeApplicationBasis.commissionBasis:
        return l10n.catalogCommercialFeeBasisCommission;
    }
  }
}

extension CommercialFeeLinePreviewLabels on CommercialFeeLinePreview {
  String summaryLine(AppLocalizations l10n) {
    if (status == CommercialFeeLineStatus.basisMissing) {
      return l10n.catalogCommercialFeePreviewBasisMissing(
        feeType.label(l10n),
        chargeBearer.label(l10n),
      );
    }
    return l10n.catalogCommercialFeePreviewLine(
      feeType.label(l10n),
      chargeBearer.label(l10n),
      formatCatalogPriceAmountSom(basisAmountSom ?? 0),
      formatCatalogPriceAmountSom(computedFeeSom ?? 0),
    );
  }
}
