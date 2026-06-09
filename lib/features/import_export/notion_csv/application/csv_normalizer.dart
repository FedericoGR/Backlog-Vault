import '../../../library/domain/game_status.dart';
import '../domain/import_issue.dart';

class CsvNormalizer {
  const CsvNormalizer();

  DateTime? parseDate(String value, List<ImportRowIssue> issues, String field) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final isoMatch = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(text);
    if (isoMatch != null) {
      return _buildDate(
        int.parse(isoMatch.group(1)!),
        int.parse(isoMatch.group(2)!),
        int.parse(isoMatch.group(3)!),
        issues,
        field,
        text,
      );
    }

    final dashMatch = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$').firstMatch(text);
    if (dashMatch != null) {
      return _buildDate(
        int.parse(dashMatch.group(3)!),
        int.parse(dashMatch.group(2)!),
        int.parse(dashMatch.group(1)!),
        issues,
        field,
        text,
      );
    }

    final slashMatch = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(text);
    if (slashMatch != null) {
      final day = int.parse(slashMatch.group(1)!);
      final month = int.parse(slashMatch.group(2)!);
      if (day <= 12 && month <= 12) {
        issues.add(
          ImportRowIssue(
            severity: ImportIssueSeverity.warning,
            field: field,
            message: 'Fecha ambigua "$text"; se interpretó como dd/MM/yyyy.',
          ),
        );
      }
      return _buildDate(
        int.parse(slashMatch.group(3)!),
        month,
        day,
        issues,
        field,
        text,
      );
    }

    issues.add(
      ImportRowIssue(
        severity: ImportIssueSeverity.warning,
        field: field,
        message: 'Fecha inválida "$text"; se dejó vacía.',
      ),
    );
    return null;
  }

  double? parseHours(String value, List<ImportRowIssue> issues) {
    final text = value.trim().toLowerCase();
    if (text.isEmpty) return null;

    final cleaned = text
        .replaceAll(RegExp(r'\bhoras?\b'), '')
        .replaceAll(RegExp(r'\bhrs?\b'), '')
        .replaceAll(RegExp(r'\bhs\b'), '')
        .replaceAll('h', '')
        .trim()
        .replaceAll(',', '.');
    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed < 0) {
      issues.add(
        ImportRowIssue(
          severity: ImportIssueSeverity.warning,
          field: 'hoursPlayed',
          message: 'Duración inválida "$value"; se dejó vacía.',
        ),
      );
      return null;
    }
    return parsed;
  }

  int? parseRating(String value, List<ImportRowIssue> issues) {
    final text = value.trim();
    if (text.isEmpty) return null;

    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1 || parsed > 5) {
      issues.add(
        ImportRowIssue(
          severity: ImportIssueSeverity.warning,
          field: 'personalRating',
          message: 'Puntaje inválido "$value"; se dejó vacío.',
        ),
      );
      return null;
    }
    return parsed;
  }

  GameStatus parseStatus(String value, List<ImportRowIssue> issues) {
    final normalized = normalizeToken(value);
    if (normalized.isEmpty) {
      if (value.trim().isNotEmpty) {
        issues.add(
          ImportRowIssue(
            severity: ImportIssueSeverity.warning,
            field: 'status',
            message: 'Estado desconocido "$value"; se usó Pendiente.',
          ),
        );
      }
      return GameStatus.backlog;
    }

    final status = _statusByToken[normalized];
    if (status != null) return status;

    issues.add(
      ImportRowIssue(
        severity: ImportIssueSeverity.warning,
        field: 'status',
        message: 'Estado desconocido "$value"; se usó Pendiente.',
      ),
    );
    return GameStatus.backlog;
  }

  List<String> splitMultiValue(String value) {
    final seen = <String>{};
    final result = <String>[];
    for (final part in value.split(RegExp(r'[,;|]'))) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final key = normalizeToken(trimmed);
      if (seen.add(key)) result.add(trimmed);
    }
    return result;
  }

  String normalizeType(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'game';
    return text.toLowerCase();
  }

  String normalizeToken(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  DateTime? _buildDate(
    int year,
    int month,
    int day,
    List<ImportRowIssue> issues,
    String field,
    String original,
  ) {
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      issues.add(
        ImportRowIssue(
          severity: ImportIssueSeverity.warning,
          field: field,
          message: 'Fecha inválida "$original"; se dejó vacía.',
        ),
      );
      return null;
    }
    return date;
  }
}

final _statusByToken = <String, GameStatus>{
  'wishlist': GameStatus.wishlist,
  'lista de deseos': GameStatus.wishlist,
  'deseado': GameStatus.wishlist,
  'backlog': GameStatus.backlog,
  'pendiente': GameStatus.backlog,
  'playing': GameStatus.playing,
  'jugando': GameStatus.playing,
  'en curso': GameStatus.playing,
  'paused': GameStatus.paused,
  'pausado': GameStatus.paused,
  'completed': GameStatus.completed,
  'completado': GameStatus.completed,
  'finished': GameStatus.completed,
  'terminado': GameStatus.completed,
  'dropped': GameStatus.dropped,
  'abandonado': GameStatus.dropped,
  'retired': GameStatus.retired,
  'retirado': GameStatus.retired,
};
