enum BusinessCatalogInventoryReservationStatus {
  reserved,
  confirmed,
  released,
  expired;

  bool get isTerminal => this != BusinessCatalogInventoryReservationStatus.reserved;
}
