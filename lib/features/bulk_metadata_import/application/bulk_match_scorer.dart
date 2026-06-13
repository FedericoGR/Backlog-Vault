import '../../library/domain/library_game_row.dart';
import '../../metadata/domain/metadata_search_candidate.dart';
import '../domain/bulk_metadata_import_models.dart';

class BulkMatchScorer {
  const BulkMatchScorer();

  List<BulkMetadataCandidate> scoreCandidates({
    required LibraryGameRow row,
    required List<MetadataSearchCandidate> candidates,
    String? existingExternalId,
  }) {
    final scored = <BulkMetadataCandidate>[];
    for (var index = 0; index < candidates.length; index++) {
      scored.add(
        _score(
          row: row,
          candidate: candidates[index],
          index: index,
          existingExternalId: existingExternalId,
        ),
      );
    }
    scored.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.candidate.title.compareTo(b.candidate.title);
    });
    return _withConfidenceAdjustedForTies(scored);
  }

  BulkMetadataCandidate _score({
    required LibraryGameRow row,
    required MetadataSearchCandidate candidate,
    required int index,
    required String? existingExternalId,
  }) {
    final reasons = <String>[];
    var score = 0;

    if (existingExternalId != null &&
        existingExternalId == candidate.externalId) {
      score += 100;
      reasons.add('external ID existente');
    }

    final localTitle = normalizeTitle(row.title);
    final externalTitle = normalizeTitle(candidate.title);
    if (localTitle.isNotEmpty && localTitle == externalTitle) {
      score += 70;
      reasons.add('título exacto');
    } else if (_containsTitle(localTitle, externalTitle)) {
      score += 38;
      reasons.add('título parecido');
    }

    final localYear = row.releaseDate?.year;
    final externalYear = candidate.releaseDate?.year;
    if (localYear != null && externalYear != null) {
      final delta = (localYear - externalYear).abs();
      if (delta == 0) {
        score += 15;
        reasons.add('mismo año');
      } else if (delta == 1) {
        score += 8;
        reasons.add('año cercano');
      }
    }

    final localPlatforms =
        row.platforms.map((platform) => normalizeLoose(platform.name)).toSet();
    final externalPlatforms = candidate.platforms.map(normalizeLoose).toSet();
    if (localPlatforms.isNotEmpty &&
        externalPlatforms.any(localPlatforms.contains)) {
      score += 10;
      reasons.add('plataforma coincidente');
    }

    if (index == 0) {
      score += 5;
      reasons.add('primer candidato');
    }

    return BulkMetadataCandidate(
      candidate: candidate,
      confidence: _confidenceForScore(score),
      score: score,
      reasons: reasons,
    );
  }

  List<BulkMetadataCandidate> _withConfidenceAdjustedForTies(
    List<BulkMetadataCandidate> scored,
  ) {
    if (scored.isEmpty) return scored;
    final result = <BulkMetadataCandidate>[];
    for (var index = 0; index < scored.length; index++) {
      final current = scored[index];
      var confidence = current.confidence;
      if (index == 0 &&
          scored.length > 1 &&
          current.confidence == BulkMetadataConfidence.safe &&
          !current.reasons.contains('external ID existente') &&
          current.score - scored[1].score < 12) {
        confidence = BulkMetadataConfidence.ambiguous;
      }
      result.add(
        BulkMetadataCandidate(
          candidate: current.candidate,
          confidence: confidence,
          score: current.score,
          reasons: current.reasons,
        ),
      );
    }
    return result;
  }

  BulkMetadataConfidence _confidenceForScore(int score) {
    if (score >= 75) return BulkMetadataConfidence.safe;
    if (score >= 50) return BulkMetadataConfidence.probable;
    if (score > 0) return BulkMetadataConfidence.ambiguous;
    return BulkMetadataConfidence.none;
  }

  bool _containsTitle(String localTitle, String externalTitle) {
    if (localTitle.length < 4 || externalTitle.length < 4) return false;
    return localTitle.contains(externalTitle) ||
        externalTitle.contains(localTitle);
  }
}

String normalizeTitle(String value) {
  var normalized = normalizeLoose(value);
  const suffixes = [
    'game of the year edition',
    'definitive edition',
    'collectors edition',
    'collector edition',
    'game of the year',
    'remastered',
    'remaster',
    'edition',
  ];
  for (final suffix in suffixes) {
    if (normalized.endsWith(' $suffix')) {
      normalized = normalized.substring(
        0,
        normalized.length - suffix.length - 1,
      );
    }
  }
  return normalized.trim();
}

String normalizeLoose(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r"['’]"), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
