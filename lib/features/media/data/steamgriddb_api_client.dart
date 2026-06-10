import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/media_asset_models.dart';
import '../domain/media_exception.dart';

class SteamGridDbApiClient {
  SteamGridDbApiClient({
    required String apiKey,
    http.Client? httpClient,
    Uri? baseUri,
    Duration timeout = const Duration(seconds: 12),
  }) : _apiKey = apiKey.trim(),
       _httpClient = httpClient ?? http.Client(),
       _baseUri = baseUri ?? Uri.https('www.steamgriddb.com', '/api/v2'),
       _timeout = timeout;

  static const providerId = 'steamgriddb';
  static const providerName = 'SteamGridDB';

  final String _apiKey;
  final http.Client _httpClient;
  final Uri _baseUri;
  final Duration _timeout;

  Future<List<MediaSearchCandidate>> searchGames(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final decoded = await _getObject(_uri(['search', 'autocomplete', trimmed]));
    final data = decoded['data'];
    if (data is! List) {
      throw const MediaException(
        'SteamGridDB devolvió una respuesta inesperada.',
        type: MediaErrorType.unexpectedResponse,
      );
    }
    return [
      for (final item in data)
        if (item is Map<String, Object?>) _candidateFromJson(item),
    ];
  }

  Future<List<ExternalMediaAsset>> searchCoverAssets(
    String externalGameId,
  ) async {
    final decoded = await _getObject(
      _uri(['grids', 'game', externalGameId], {'limit': '50'}),
    );
    final data = decoded['data'];
    if (data is! List) {
      throw const MediaException(
        'SteamGridDB devolvió una respuesta inesperada.',
        type: MediaErrorType.unexpectedResponse,
      );
    }
    final assets =
        [
          for (final item in data)
            if (item is Map<String, Object?>) _assetFromJson(item),
        ].where(_looksLikeCover).toList();
    assets.sort(_compareAssets);
    return assets;
  }

  Uri _uri(List<String> segments, [Map<String, String>? queryParameters]) {
    return _baseUri.replace(
      pathSegments: [..._baseUri.pathSegments, ...segments],
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, Object?>> _getObject(Uri uri) async {
    if (_apiKey.isEmpty) {
      throw const MediaException(
        'Configurá una API key de SteamGridDB antes de buscar portadas.',
        type: MediaErrorType.missingApiKey,
      );
    }
    try {
      final response = await _httpClient
          .get(uri, headers: {'Authorization': 'Bearer $_apiKey'})
          .timeout(_timeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const MediaException(
          'La API key de SteamGridDB no es válida o no tiene acceso.',
          type: MediaErrorType.invalidApiKey,
        );
      }
      if (response.statusCode == 404) {
        throw const MediaException(
          'SteamGridDB no encontró ese recurso.',
          type: MediaErrorType.notFound,
        );
      }
      if (response.statusCode == 429) {
        throw const MediaException(
          'SteamGridDB limitó temporalmente las consultas. Probá de nuevo más tarde.',
          type: MediaErrorType.rateLimited,
        );
      }
      if (response.statusCode >= 500) {
        throw const MediaException(
          'SteamGridDB no está disponible en este momento.',
          type: MediaErrorType.providerUnavailable,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const MediaException(
          'SteamGridDB rechazó la solicitud.',
          type: MediaErrorType.unexpectedResponse,
        );
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, Object?>) return decoded;
    } on MediaException {
      rethrow;
    } on TimeoutException {
      throw const MediaException(
        'La consulta a SteamGridDB tardó demasiado.',
        type: MediaErrorType.timeout,
      );
    } on SocketException {
      throw const MediaException(
        'No se pudo conectar con SteamGridDB. Revisá tu conexión a internet.',
        type: MediaErrorType.network,
      );
    } on http.ClientException {
      throw const MediaException(
        'No se pudo conectar con SteamGridDB.',
        type: MediaErrorType.network,
      );
    } on FormatException {
      throw const MediaException(
        'SteamGridDB devolvió JSON inválido.',
        type: MediaErrorType.unexpectedResponse,
      );
    }
    throw const MediaException(
      'SteamGridDB devolvió una respuesta inesperada.',
      type: MediaErrorType.unexpectedResponse,
    );
  }

  MediaSearchCandidate _candidateFromJson(Map<String, Object?> json) {
    final id = json['id']?.toString();
    final title = json['name']?.toString().trim();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      throw const MediaException(
        'SteamGridDB devolvió un candidato incompleto.',
        type: MediaErrorType.unexpectedResponse,
      );
    }
    return MediaSearchCandidate(
      providerId: providerId,
      providerName: providerName,
      externalId: id,
      title: title,
    );
  }

  ExternalMediaAsset _assetFromJson(Map<String, Object?> json) {
    final id = json['id']?.toString();
    final url = _stringOrNull(json['url']);
    if (id == null || id.isEmpty || url == null) {
      throw const MediaException(
        'SteamGridDB devolvió un asset incompleto.',
        type: MediaErrorType.unexpectedResponse,
      );
    }
    return ExternalMediaAsset(
      providerId: providerId,
      providerName: providerName,
      externalId: id,
      kind: MediaAssetKind.cover,
      remoteUrl: url,
      thumbnailUrl: _stringOrNull(json['thumb']),
      mimeType: _stringOrNull(json['mime']) ?? _stringOrNull(json['mimeType']),
      width: _intOrNull(json['width']),
      height: _intOrNull(json['height']),
      attribution: _authorName(json['author']),
    );
  }

  String? _authorName(Object? value) {
    if (value is Map<String, Object?>) return _stringOrNull(value['name']);
    return null;
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

bool _looksLikeCover(ExternalMediaAsset asset) {
  final width = asset.width;
  final height = asset.height;
  if (width == null || height == null) return true;
  return height >= width;
}

int _compareAssets(ExternalMediaAsset a, ExternalMediaAsset b) {
  final aArea = (a.width ?? 0) * (a.height ?? 0);
  final bArea = (b.width ?? 0) * (b.height ?? 0);
  return bArea.compareTo(aArea);
}
