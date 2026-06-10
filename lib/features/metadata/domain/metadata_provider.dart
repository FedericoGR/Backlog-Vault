import 'external_game_details.dart';
import 'metadata_search_candidate.dart';

abstract class MetadataProvider {
  String get providerId;
  String get displayName;
  bool get requiresApiKey;

  Future<List<MetadataSearchCandidate>> searchGames(String query);

  Future<ExternalGameDetails> getGameDetails(String externalId);
}
