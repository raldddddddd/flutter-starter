import 'package:dio/dio.dart';

import '../sample_item.dart';

abstract interface class SampleApiService {
  Future<List<SampleItem>> fetchItems({CancelToken? cancelToken});
  Future<SampleItem> createItem(String title, {CancelToken? cancelToken});
}

/// Reference adapter for a product API. The committed base URL is a placeholder.
final class DioSampleApiService implements SampleApiService {
  DioSampleApiService(this._dio);

  final Dio _dio;

  @override
  Future<List<SampleItem>> fetchItems({CancelToken? cancelToken}) async {
    final response = await _dio.get<List<dynamic>>(
      '/sample/items',
      cancelToken: cancelToken,
    );
    return [
      for (final item in response.data ?? const <dynamic>[])
        SampleItem.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  @override
  Future<SampleItem> createItem(
    String title, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/sample/items',
      data: {'title': title},
      cancelToken: cancelToken,
    );
    return SampleItem.fromJson(response.data!);
  }
}
