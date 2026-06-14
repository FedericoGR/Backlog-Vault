import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/external_game_details.dart';
import '../domain/metadata_exception.dart';
import '../domain/metadata_search_candidate.dart';

class IgdbApiClient {
  IgdbApiClient({
    required String clientId,
    required String accessToken,
    http.Client? httpClient,
    Uri? baseUri,
    Duration timeout = const Duration(seconds: 12),
  }) : _clientId = clientId.trim(),
       _accessToken = accessToken.trim(),
       _httpClient = httpClient ?? http.Client(),
       _baseUri = baseUri ?? Uri.https('api.igdb.com', '/v4'),
       _timeout = timeout;

  static const providerId = 'igdb';
  static const providerName = 'IGDB';

  final String _clientId;
  final String _accessToken;
  final http.Client _httpClient;
  final Uri _baseUri;
  final Duration _timeout;

  Future<List<MetadataSearchCandidate>> searchGames(String query) async {
    final response = await _postGames('''
search "${_escapeSearch(query)}";
fields id,name,slug,url,first_release_date,platforms.name,genres.name,game_type,cover.id,cover.image_id,cover.url,cover.width,cover.height;
limit 10;
''');
    final decoded = _decodeList(response);
    return [
      for (final item in decoded)
        if (item is Map<String, Object?>) _candidateFromJson(item),
    ];
  }

  Future<ExternalGameDetails> getGameDetails(String externalId) async {
    final id = int.tryParse(externalId);
    if (id == null) {
      throw const MetadataException(
        'IGDB devolvió un identificador inválido.',
        type: MetadataErrorType.unexpectedResponse,
      );
    }
    final response = await _postGames('''
fields id,name,slug,url,first_release_date,platforms.name,genres.name,game_type,summary,storyline,cover.id,cover.image_id,cover.url,cover.width,cover.height;
where id = $id;
limit 1;
''');
    final decoded = _decodeList(response);
    if (decoded.isEmpty || decoded.first is! Map<String, Object?>) {
      throw const MetadataException(
        'IGDB no encontró ese juego.',
        type: MetadataErrorType.notFound,
      );
    }
    return _detailsFromJson(decoded.first as Map<String, Object?>);
  }

  Future<http.Response> _postGames(String body) async {
    if (_clientId.isEmpty || _accessToken.isEmpty) {
      throw const MetadataException(
        'Configurá credenciales de IGDB antes de buscar metadata.',
        type: MetadataErrorType.missingApiKey,
      );
    }
    try {
      final response = await _httpClient
          .post(
            _endpoint('/games'),
            headers: {
              'Client-ID': _clientId,
              'Authorization': 'Bearer $_accessToken',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(_timeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const MetadataException(
          'Las credenciales o token de IGDB no son válidos.',
          type: MetadataErrorType.invalidApiKey,
        );
      }
      if (response.statusCode == 404) {
        throw const MetadataException(
          'IGDB no encontró ese juego.',
          type: MetadataErrorType.notFound,
        );
      }
      if (response.statusCode == 429) {
        throw const MetadataException(
          'IGDB limitó temporalmente las consultas. Probá de nuevo más tarde.',
          type: MetadataErrorType.rateLimited,
        );
      }
      if (response.statusCode >= 500) {
        throw const MetadataException(
          'IGDB no está disponible en este momento.',
          type: MetadataErrorType.providerUnavailable,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const MetadataException(
          'IGDB rechazó la solicitud de metadata.',
          type: MetadataErrorType.unexpectedResponse,
        );
      }
      return response;
    } on MetadataException {
      rethrow;
    } on TimeoutException {
      throw const MetadataException(
        'La consulta a IGDB tardó demasiado.',
        type: MetadataErrorType.timeout,
      );
    } on SocketException {
      throw const MetadataException(
        'No se pudo conectar con IGDB. Revisá tu conexión a internet.',
        type: MetadataErrorType.network,
      );
    } on http.ClientException {
      throw const MetadataException(
        'No se pudo conectar con IGDB.',
        type: MetadataErrorType.network,
      );
    }
  }

  Uri _endpoint(String path) {
    return _baseUri.replace(path: '${_baseUri.path}$path');
  }

  List<Object?> _decodeList(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is List) return decoded;
    } on FormatException {
      // Handled below with the same safe public message.
    }
    throw const MetadataException(
      'IGDB devolvió JSON inválido.',
      type: MetadataErrorType.unexpectedResponse,
    );
  }

  MetadataSearchCandidate _candidateFromJson(Map<String, Object?> json) {
    final id = json['id']?.toString();
    final title = json['name']?.toString().trim();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      throw const MetadataException(
        'IGDB devolvió un candidato incompleto.',
        type: MetadataErrorType.unexpectedResponse,
      );
    }
    final slug = _stringOrNull(json['slug']);
    return MetadataSearchCandidate(
      providerId: providerId,
      providerName: providerName,
      externalId: id,
      externalSlug: slug,
      externalUrl: _stringOrNull(json['url']) ?? _externalUrl(slug),
      title: title,
      releaseDate: _parseUnixDate(json['first_release_date']),
      platforms: _nameList(json['platforms']),
      genres: _nameList(json['genres']),
    );
  }

  ExternalGameDetails _detailsFromJson(Map<String, Object?> json) {
    final id = json['id']?.toString();
    final title = json['name']?.toString().trim();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      throw const MetadataException(
        'IGDB devolvió un detalle incompleto.',
        type: MetadataErrorType.unexpectedResponse,
      );
    }
    final slug = _stringOrNull(json['slug']);
    final cover = _coverFromJson(json['cover']);
    return ExternalGameDetails(
      providerId: providerId,
      providerName: providerName,
      externalId: id,
      externalSlug: slug,
      externalUrl: _stringOrNull(json['url']) ?? _externalUrl(slug),
      title: title,
      releaseDate: _parseUnixDate(json['first_release_date']),
      type: _typeFromGameType(json['game_type']),
      genres: _nameList(json['genres']),
      platforms: _nameList(json['platforms']),
      imageUrl: cover?.remoteUrl,
      cover: cover,
    );
  }

  ExternalGameCover? _coverFromJson(Object? value) {
    if (value is! Map<String, Object?>) return null;
    final imageId = _stringOrNull(value['image_id']);
    final rawUrl = _stringOrNull(value['url']);
    final remoteUrl =
        imageId == null
            ? _normalizeIgdbImageUrl(rawUrl, preferredSize: 't_720p')
            : _imageUrl(imageId, size: 't_720p');
    if (remoteUrl == null) return null;
    final id = _stringOrNull(value['id']) ?? imageId;
    if (id == null || id.isEmpty) return null;
    return ExternalGameCover(
      externalId: id,
      imageId: imageId,
      remoteUrl: remoteUrl,
      thumbnailUrl:
          imageId == null
              ? _normalizeIgdbImageUrl(rawUrl, preferredSize: 't_cover_big')
              : _imageUrl(imageId, size: 't_cover_big'),
      width: _intOrNull(value['width']),
      height: _intOrNull(value['height']),
    );
  }

  String _escapeSearch(String value) {
    return value.trim().replaceAll('\\', r'\\').replaceAll('"', r'\"');
  }

  DateTime? _parseUnixDate(Object? value) {
    final seconds =
        value is int ? value : int.tryParse(value?.toString() ?? '');
    if (seconds == null || seconds <= 0) return null;
    final utcDate = DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    );
    return DateTime(utcDate.year, utcDate.month, utcDate.day);
  }

  String _typeFromGameType(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return 'game';
    if (normalized == 'main_game' || normalized == '0') return 'game';
    if (normalized == 'dlc_addon' || normalized == '1') return 'dlc';
    if (normalized == 'expansion' || normalized == '2') return 'expansion';
    if (normalized == 'bundle' || normalized == '3') return 'bundle';
    return 'game';
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

  String? _externalUrl(String? slug) {
    if (slug == null || slug.isEmpty) return null;
    return 'https://www.igdb.com/games/$slug';
  }

  String _imageUrl(String imageId, {required String size}) {
    return 'https://images.igdb.com/igdb/image/upload/$size/$imageId.jpg';
  }

  String? _normalizeIgdbImageUrl(String? value, {String? preferredSize}) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.startsWith('//') ? 'https:$value' : value;
    var uri = Uri.tryParse(normalized);
    if (uri == null) return null;
    if (uri.scheme == 'http') {
      uri = uri.replace(scheme: 'https');
    }
    if (uri.scheme != 'https') return null;
    if (preferredSize == null) return uri.toString();
    final segments = [...uri.pathSegments];
    final uploadIndex = segments.indexOf('upload');
    if (uploadIndex != -1 && segments.length > uploadIndex + 1) {
      segments[uploadIndex + 1] = preferredSize;
      return uri.replace(pathSegments: segments).toString();
    }
    return uri.toString();
  }

  String? _stringOrNull(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  int? _intOrNull(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
