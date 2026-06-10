import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/external_game_details.dart';
import '../domain/metadata_exception.dart';
import '../domain/metadata_search_candidate.dart';

class RawgApiClient {
  RawgApiClient({
    required String apiKey,
    http.Client? httpClient,
    Uri? baseUri,
    Duration timeout = const Duration(seconds: 12),
  }) : _apiKey = apiKey.trim(),
       _httpClient = httpClient ?? http.Client(),
       _baseUri = baseUri ?? Uri.https('api.rawg.io', '/api'),
       _timeout = timeout;

  static const providerId = 'rawg';
  static const providerName = 'RAWG';

  final String _apiKey;
  final http.Client _httpClient;
  final Uri _baseUri;
  final Duration _timeout;

  Future<List<MetadataSearchCandidate>> searchGames(String query) async {
    final uri = _uri('/games', {
      'search': query,
      'page_size': '10',
      'key': _apiKey,
    });
    final response = await _get(uri);
    final decoded = _decodeObject(response);
    final results = decoded['results'];
    if (results is! List) {
      throw const MetadataException(
        'RAWG devolvió una respuesta inesperada.',
        type: MetadataErrorType.unexpectedResponse,
      );
    }
    return [
      for (final item in results)
        if (item is Map<String, Object?>) _candidateFromJson(item),
    ];
  }

  Future<ExternalGameDetails> getGameDetails(String externalId) async {
    final response = await _get(_uri('/games/$externalId', {'key': _apiKey}));
    return _detailsFromJson(_decodeObject(response));
  }

  Uri _uri(String path, Map<String, String> queryParameters) {
    return _baseUri.replace(
      path: '${_baseUri.path}$path',
      queryParameters: queryParameters,
    );
  }

  Future<http.Response> _get(Uri uri) async {
    if (_apiKey.isEmpty) {
      throw const MetadataException(
        'Configurá una API key de RAWG antes de buscar metadata.',
        type: MetadataErrorType.missingApiKey,
      );
    }
    try {
      final response = await _httpClient.get(uri).timeout(_timeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const MetadataException(
          'La API key de RAWG no es válida o no tiene acceso.',
          type: MetadataErrorType.invalidApiKey,
        );
      }
      if (response.statusCode == 404) {
        throw const MetadataException(
          'RAWG no encontró ese juego.',
          type: MetadataErrorType.notFound,
        );
      }
      if (response.statusCode == 429) {
        throw const MetadataException(
          'RAWG limitó temporalmente las consultas. Probá de nuevo más tarde.',
          type: MetadataErrorType.rateLimited,
        );
      }
      if (response.statusCode >= 500) {
        throw const MetadataException(
          'RAWG no está disponible en este momento.',
          type: MetadataErrorType.providerUnavailable,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const MetadataException(
          'RAWG rechazó la solicitud de metadata.',
          type: MetadataErrorType.unexpectedResponse,
        );
      }
      return response;
    } on MetadataException {
      rethrow;
    } on TimeoutException {
      throw const MetadataException(
        'La consulta a RAWG tardó demasiado.',
        type: MetadataErrorType.timeout,
      );
    } on SocketException {
      throw const MetadataException(
        'No se pudo conectar con RAWG. Revisá tu conexión a internet.',
        type: MetadataErrorType.network,
      );
    } on http.ClientException {
      throw const MetadataException(
        'No se pudo conectar con RAWG.',
        type: MetadataErrorType.network,
      );
    }
  }

  Map<String, Object?> _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) return decoded;
    } on FormatException {
      // Handled below with the same safe public message.
    }
    throw const MetadataException(
      'RAWG devolvió JSON inválido.',
      type: MetadataErrorType.unexpectedResponse,
    );
  }

  MetadataSearchCandidate _candidateFromJson(Map<String, Object?> json) {
    final id = json['id']?.toString();
    final title = json['name']?.toString().trim();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      throw const MetadataException(
        'RAWG devolvió un candidato incompleto.',
        type: MetadataErrorType.unexpectedResponse,
      );
    }
    final slug = _stringOrNull(json['slug']);
    return MetadataSearchCandidate(
      providerId: providerId,
      providerName: providerName,
      externalId: id,
      externalSlug: slug,
      externalUrl: slug == null ? null : 'https://rawg.io/games/$slug',
      title: title,
      releaseDate: _parseDate(_stringOrNull(json['released'])),
      platforms: _platformNames(json['platforms']),
      genres: _nameList(json['genres']),
      thumbnailUrl: _stringOrNull(json['background_image']),
    );
  }

  ExternalGameDetails _detailsFromJson(Map<String, Object?> json) {
    final id = json['id']?.toString();
    final title = json['name']?.toString().trim();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      throw const MetadataException(
        'RAWG devolvió un detalle incompleto.',
        type: MetadataErrorType.unexpectedResponse,
      );
    }
    final slug = _stringOrNull(json['slug']);
    return ExternalGameDetails(
      providerId: providerId,
      providerName: providerName,
      externalId: id,
      externalSlug: slug,
      externalUrl: slug == null ? null : 'https://rawg.io/games/$slug',
      title: title,
      releaseDate: _parseDate(_stringOrNull(json['released'])),
      type: 'game',
      genres: _nameList(json['genres']),
      platforms: _platformNames(json['platforms']),
      imageUrl: _stringOrNull(json['background_image']),
    );
  }

  List<String> _platformNames(Object? value) {
    if (value is! List) return const [];
    return _uniqueNames(
      value.map((item) {
        if (item is Map<String, Object?>) {
          final platform = item['platform'];
          if (platform is Map<String, Object?>) {
            return _stringOrNull(platform['name']);
          }
        }
        return null;
      }),
    );
  }

  List<String> _nameList(Object? value) {
    if (value is! List) return const [];
    return _uniqueNames(
      value.map((item) {
        if (item is Map<String, Object?>) return _stringOrNull(item['name']);
        return null;
      }),
    );
  }

  List<String> _uniqueNames(Iterable<String?> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      result.add(trimmed);
    }
    return result;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String? _stringOrNull(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
