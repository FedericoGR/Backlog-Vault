import 'package:backlog_vault/features/media/application/media_providers.dart';
import 'package:backlog_vault/features/media/domain/media_asset_models.dart';
import 'package:backlog_vault/features/media/domain/media_provider.dart';
import 'package:test/test.dart';

void main() {
  test('search delegates to the selected provider', () async {
    const provider = _FakeMediaProvider();
    final viewModel = MediaSearchViewModel(
      saveRemote: ({required gameId, required asset}) async {},
      pickAndSaveLocal: (_) async => false,
    );

    final result = await viewModel.searchGames(provider, 'Hades');

    expect(result.single.title, 'Hades');
  });

  test('local picker cancellation is a successful no-op', () async {
    final viewModel = MediaSearchViewModel(
      saveRemote: ({required gameId, required asset}) async {},
      pickAndSaveLocal: (_) async => false,
    );

    expect(await viewModel.pickAndSaveLocal('game-1'), isFalse);
  });
}

class _FakeMediaProvider implements MediaProvider {
  const _FakeMediaProvider();

  @override
  MediaProviderCapabilities get capabilities =>
      const MediaProviderCapabilities(supportsCovers: true);
  @override
  String get displayName => 'Fake';
  @override
  String get providerId => 'fake';
  @override
  bool get requiresApiKey => false;
  @override
  Future<List<MediaSearchCandidate>> searchGames(String query) async => [
    MediaSearchCandidate(
      providerId: providerId,
      providerName: displayName,
      externalId: '1',
      title: query,
    ),
  ];
  @override
  Future<List<ExternalMediaAsset>> searchCoverAssets(
    String externalGameId,
  ) async => const [];
}
