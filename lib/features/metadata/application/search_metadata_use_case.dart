import '../domain/metadata_exception.dart';
import '../domain/metadata_provider.dart';
import '../domain/metadata_search_candidate.dart';

class SearchMetadataUseCase {
  const SearchMetadataUseCase(this._provider);

  final MetadataProvider _provider;

  Future<List<MetadataSearchCandidate>> call(String query) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      throw const MetadataException(
        'Ingresá un título para buscar metadata.',
        type: MetadataErrorType.unexpectedResponse,
      );
    }
    return _provider.searchGames(normalized);
  }
}
