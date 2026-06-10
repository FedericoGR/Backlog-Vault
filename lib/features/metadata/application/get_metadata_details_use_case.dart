import '../domain/external_game_details.dart';
import '../domain/metadata_provider.dart';

class GetMetadataDetailsUseCase {
  const GetMetadataDetailsUseCase(this._provider);

  final MetadataProvider _provider;

  Future<ExternalGameDetails> call(String externalId) {
    return _provider.getGameDetails(externalId);
  }
}
