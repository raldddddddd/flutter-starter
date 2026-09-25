import 'package:dio/dio.dart';

import '../sample_item.dart';
import 'sample_api_service.dart';

enum FakeSampleOutcome { success, networkFailure, serverFailure, unauthorized }

/// Deterministic in-process API for development and feature tests.
final class FakeSampleApiService implements SampleApiService {
  FakeSampleApiService({
    this.latency = const Duration(milliseconds: 350),
    this.outcome = FakeSampleOutcome.success,
    List<SampleItem>? items,
  }) : items =
           items ??
           const [
             SampleItem(id: 'one', title: 'First sample item'),
             SampleItem(id: 'two', title: 'Second sample item'),
           ];

  Duration latency;
  FakeSampleOutcome outcome;
  List<SampleItem> items;
  int requestCount = 0;
  int createCount = 0;

  @override
  Future<List<SampleItem>> fetchItems({CancelToken? cancelToken}) async {
    requestCount++;
    await _simulate(cancelToken);
    return List<SampleItem>.of(items);
  }

  @override
  Future<SampleItem> createItem(
    String title, {
    CancelToken? cancelToken,
  }) async {
    createCount++;
    await _simulate(cancelToken);
    final created = SampleItem(id: 'created-$createCount', title: title);
    items = [...items, created];
    return created;
  }

  Future<void> _simulate(CancelToken? cancelToken) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (cancelToken?.isCancelled == true) {
      throw DioException(
        requestOptions: RequestOptions(path: '/sample/items'),
        type: DioExceptionType.cancel,
      );
    }
    switch (outcome) {
      case FakeSampleOutcome.success:
        return;
      case FakeSampleOutcome.networkFailure:
        throw DioException(
          requestOptions: RequestOptions(path: '/sample/items'),
          type: DioExceptionType.connectionError,
        );
      case FakeSampleOutcome.serverFailure:
      case FakeSampleOutcome.unauthorized:
        final status = outcome == FakeSampleOutcome.serverFailure ? 503 : 401;
        final options = RequestOptions(path: '/sample/items');
        throw DioException.badResponse(
          statusCode: status,
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: status,
          ),
        );
    }
  }
}
