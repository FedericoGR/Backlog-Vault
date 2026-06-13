import 'external_game_details.dart';
import 'metadata_field.dart';

class ApplyMetadataRequest {
  const ApplyMetadataRequest({
    required this.gameId,
    required this.libraryEntryId,
    required this.details,
    required this.selectedFields,
    this.replaceFields = const {},
    this.replaceExistingExternalId = false,
  });

  final String gameId;
  final String libraryEntryId;
  final ExternalGameDetails details;
  final Set<MetadataField> selectedFields;
  final Set<MetadataField> replaceFields;
  final bool replaceExistingExternalId;
}
