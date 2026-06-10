import '../data/metadata_repository.dart';
import '../domain/apply_metadata_request.dart';

class ApplyMetadataUseCase {
  const ApplyMetadataUseCase(this._repository);

  final MetadataRepository _repository;

  Future<void> call(ApplyMetadataRequest request) {
    return _repository.applyMetadata(request);
  }
}
