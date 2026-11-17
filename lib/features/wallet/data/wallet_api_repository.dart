import 'package:dio/dio.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/wallet/domain/wallet.dart';

/// Reads the signed-in user's wallet. It never sends or changes an amount.
class WalletApiRepository implements WalletRepository {
  WalletApiRepository({
    required ApiClient apiClient,
    required this.config,
  }) : _dio = apiClient.dio;

  static const String myWalletPath = '/api/v1/wallets/me';

  final Dio _dio;
  final AppConfig config;

  @override
  Future<WalletBalance> fetchMyWallet({required String accessToken}) async {
    if (!config.apiConfigured) {
      throw const WalletFailure(WalletFailureKind.apiNotConfigured);
    }
    if (accessToken.isEmpty) {
      throw const WalletFailure(WalletFailureKind.authenticationRequired);
    }
    try {
      final response = await _dio.get<Object?>(
        myWalletPath,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const WalletFailure(WalletFailureKind.malformedResponse);
      }
      return WalletBalance.fromJson(data);
    } on WalletFailure {
      rethrow;
    } on DioException catch (error) {
      throw WalletFailure(_kind(error.response?.statusCode));
    } on Exception {
      throw const WalletFailure(WalletFailureKind.unavailable);
    }
  }

  static WalletFailureKind _kind(int? status) {
    return switch (status) {
      401 => WalletFailureKind.authenticationRequired,
      404 => WalletFailureKind.notFound,
      _ => WalletFailureKind.unavailable,
    };
  }
}
