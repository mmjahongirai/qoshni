import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qoshni/core/config/app_config.dart';
import 'package:qoshni/core/config/app_environment.dart';
import 'package:qoshni/core/logging/app_logger.dart';
import 'package:qoshni/core/network/api_client.dart';
import 'package:qoshni/features/search/data/remote_qoshni_search_data_source.dart';
import 'package:qoshni/features/search/domain/qoshni_search_page_result.dart';
import 'package:qoshni/features/search/domain/qoshni_search_request.dart';

void main() {
  test('remote adapter maps success response', () async {
    final dio = Dio()..httpClientAdapter = _MockSuccessAdapter();
    final config = AppConfig(
      environment: AppEnvironment.development,
      appName: 'Test',
      apiBaseUrl: 'http://example.test',
      enableLogging: false,
      enableBusinessProfileSamples: true,
      enableBusinessOfferingSamples: true,
      enableRemoteSearchDiscovery: true,
    );
    final remote = RemoteQoshniSearchDataSource(
      apiClient: ApiClient(config: config, logger: AppLogger(config), dio: dio),
    );
    final page = await remote.search(
      request: const QoshniSearchRequest(rawQuery: 'apteka'),
      accessToken: 'token',
    );
    expect(page.status, QoshniSearchExecutionStatus.success);
    expect(page.items.single.catalogEntry.title, 'Pharmacy');
  });

  test('remote adapter maps invalid cursor to invalidCursor status', () async {
    final dio = Dio()..httpClientAdapter = _MockInvalidCursorAdapter();
    final config = AppConfig.forEnvironment(AppEnvironment.development);
    final remote = RemoteQoshniSearchDataSource(
      apiClient: ApiClient(config: config, logger: AppLogger(config), dio: dio),
    );
    final page = await remote.search(
      request: const QoshniSearchRequest(rawQuery: 'apteka', cursor: 'bad'),
      accessToken: 'token',
    );
    expect(page.status, QoshniSearchExecutionStatus.invalidCursor);
  });
}

class _MockSuccessAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"items":[{"stable_id":"category:pharmacy","kind":"category","title":"Pharmacy","is_sponsored":false}],"next_cursor":null,"query_fingerprint":"apteka||","catalog_generation":1}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

class _MockInvalidCursorAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"error":{"code":"invalid_cursor","message":"Cursor is invalid or tampered."}}',
      400,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
