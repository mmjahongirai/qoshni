import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/features/auth/presentation/auth_controller.dart';
import 'package:qoshni/features/home/presentation/data/home_mock_data.dart';
import 'package:qoshni/features/search/application/qoshni_search_execution_service.dart';
import 'package:qoshni/features/search/data/remote_qoshni_search_data_source.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_query_understanding.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';

/// Selects demo (local) or remote backend execution — no silent fallback.
class QoshniSearchExecutionCoordinator {
  QoshniSearchExecutionCoordinator({
    required AppConfig config,
    required QoshniSearchExecutionService demoExecutionService,
    required RemoteQoshniSearchDataSource remoteDataSource,
    required AuthController authController,
  })  : _config = config,
        _demoExecutionService = demoExecutionService,
        _remoteDataSource = remoteDataSource,
        _authController = authController;

  final AppConfig _config;
  final QoshniSearchExecutionService _demoExecutionService;
  final RemoteQoshniSearchDataSource _remoteDataSource;
  final AuthController _authController;

  bool get usesRemoteBackend =>
      _config.enableRemoteSearchDiscovery && _config.apiConfigured;

  Future<QoshniSearchPageResult> execute({
    required QoshniSearchRequest request,
    required List<SearchCatalogEntry> catalog,
    QoshniSearchQueryUnderstanding? understanding,
  }) async {
    if (!usesRemoteBackend) {
      return _demoExecutionService.execute(
        request: request,
        catalog: catalog,
        understanding: understanding,
      );
    }

    final token = _authController.accessToken;
    if (token == null || token.isEmpty) {
      return const QoshniSearchPageResult(
        status: QoshniSearchExecutionStatus.remoteUnauthorized,
        items: [],
      );
    }

    return _remoteDataSource.search(
      request: request,
      accessToken: token,
    );
  }
}
