import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/app_config.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/persistence/persistence_providers.dart';
import 'fake_sample_api_service.dart';
import 'sample_api_service.dart';
import 'sample_repository.dart';

part 'sample_data_providers.g.dart';

@Riverpod(keepAlive: true)
SampleApiService sampleApiService(Ref ref) {
  if (ref.watch(appConfigProvider).environment == AppEnvironment.dev) {
    return FakeSampleApiService();
  }
  return DioSampleApiService(ref.watch(appDioProvider));
}

@Riverpod(keepAlive: true)
SampleRepository sampleRepository(Ref ref) => SampleRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(sampleApiServiceProvider),
  ref.watch(sessionManagerProvider),
);
