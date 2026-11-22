/// Server wallet read model for `GET /api/v1/wallets/me`.
///
/// Amounts are integer minor units exactly as the server returns them. The
/// client never adds, subtracts, or derives a balance.
class WalletBalance {
  const WalletBalance({
    required this.walletId,
    required this.currencyCode,
    required this.availableMinor,
    required this.holdMinor,
    required this.pendingMinor,
    required this.status,
  });

  final String walletId;
  final String currencyCode;
  final int availableMinor;
  final int holdMinor;
  final int pendingMinor;
  final WalletStatus status;

  /// Largest integer every Flutter target (including web) holds exactly.
  static const int maxSafeMinor = 9007199254740991;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    final walletId = json['wallet_id'];
    final currency = json['currency_code'];
    if (walletId is! String ||
        walletId.isEmpty ||
        currency is! String ||
        currency.isEmpty) {
      throw const WalletFailure(WalletFailureKind.malformedResponse);
    }
    return WalletBalance(
      walletId: walletId,
      currencyCode: currency,
      availableMinor: _minor(json['available_minor']),
      holdMinor: _minor(json['hold_minor']),
      pendingMinor: _minor(json['pending_minor']),
      status: WalletStatus.fromApi(json['status']),
    );
  }

  static int _minor(Object? value) {
    // JSON numbers decode to `int` on the VM and to whole `num` on the web.
    if (value is! num || value is double && value != value.truncateToDouble()) {
      throw const WalletFailure(WalletFailureKind.malformedResponse);
    }
    if (value.abs() > maxSafeMinor) {
      throw const WalletFailure(WalletFailureKind.malformedResponse);
    }
    return value.toInt();
  }
}

enum WalletStatus {
  active,
  frozen,
  unknown;

  static WalletStatus fromApi(Object? value) {
    return switch (value) {
      'active' => WalletStatus.active,
      'frozen' => WalletStatus.frozen,
      _ => WalletStatus.unknown,
    };
  }
}

enum WalletFailureKind {
  /// 401: the session is missing or no longer valid.
  authenticationRequired,

  /// 404: the server has no wallet for this account.
  notFound,

  /// 5xx, timeouts, network errors, and other server problems.
  unavailable,

  /// The server answered with a body this client cannot trust.
  malformedResponse,

  /// This build has no API base URL.
  apiNotConfigured,
}

class WalletFailure implements Exception {
  const WalletFailure(this.kind);

  final WalletFailureKind kind;

  @override
  String toString() => 'WalletFailure(${kind.name})';
}

abstract class WalletRepository {
  Future<WalletBalance> fetchMyWallet({required String accessToken});
}
