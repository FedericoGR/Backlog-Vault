import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/metadata_api_key_storage.dart';
import '../data/igdb_metadata_provider.dart';
import '../data/metadata_repository.dart';
import '../data/rawg_metadata_provider.dart';
import '../domain/metadata_provider.dart';
import 'apply_metadata_use_case.dart';
import 'build_metadata_diff_use_case.dart';
import 'get_metadata_details_use_case.dart';
import 'search_metadata_use_case.dart';

final metadataHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final rawgMetadataProvider = Provider<MetadataProvider>((ref) {
  return RawgMetadataProvider(
    apiKeyStorage: ref.watch(metadataApiKeyStorageProvider),
    httpClient: ref.watch(metadataHttpClientProvider),
  );
});

final igdbMetadataProvider = Provider<MetadataProvider>((ref) {
  return IgdbMetadataProvider(
    apiKeyStorage: ref.watch(metadataApiKeyStorageProvider),
    httpClient: ref.watch(metadataHttpClientProvider),
  );
});

final metadataProviderListProvider = Provider<List<MetadataProvider>>((ref) {
  return [ref.watch(rawgMetadataProvider), ref.watch(igdbMetadataProvider)];
});

final searchMetadataUseCaseProvider = Provider<SearchMetadataUseCase>((ref) {
  return SearchMetadataUseCase(ref.watch(rawgMetadataProvider));
});

final getMetadataDetailsUseCaseProvider = Provider<GetMetadataDetailsUseCase>((
  ref,
) {
  return GetMetadataDetailsUseCase(ref.watch(rawgMetadataProvider));
});

final buildMetadataDiffUseCaseProvider = Provider<BuildMetadataDiffUseCase>((
  ref,
) {
  return const BuildMetadataDiffUseCase();
});

final applyMetadataUseCaseProvider = Provider<ApplyMetadataUseCase>((ref) {
  return ApplyMetadataUseCase(ref.watch(metadataRepositoryProvider));
});
