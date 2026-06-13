import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/metadata_exception.dart';

class IgdbAuthClient {
  IgdbAuthClient({
    http.Client? httpClient,
    Uri? tokenUri,
    Duration timeout = const Duration(seconds: 12),
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenUri = tokenUri ?? Uri.https('id.twitch.tv', '/oauth2/token'),
       _timeout = timeout;

  final http.Client _httpClient;
  final Uri _tokenUri;
  final Duration _timeout;

  Future<IgdbAuthToken> requestAccessToken({
    required String clientId,
    required String clientSecret,
  }) async {
    final normalizedClientId = clientId.trim();
    final normalizedClientSecret = clientSecret.trim();
    if (normalizedClientId.isEmpty || normalizedClientSecret.isEmpty) {
      throw const MetadataException(
        'Configurá Client ID y Client Secret de IGDB antes de buscar metadata.',
        type: MetadataErrorType.missingApiKey,
      );
    }

    final uri = _tokenUri.replace(
      queryParameters: {
        'client_id': normalizedClientId,
        'client_secret': normalizedClientSecret,
        'grant_type': 'client_credentials',
      },
    );

    try {
      final response = await _httpClient.post(uri).timeout(_timeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const MetadataException(
          'Las credenciales de IGDB/Twitch no son válidas o no tienen acceso.',
          type: MetadataErrorType.invalidApiKey,
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
          'IGDB/Twitch no está disponible en este momento.',
          type: MetadataErrorType.providerUnavailable,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const MetadataException(
          'IGDB/Twitch rechazó la autenticación.',
          type: MetadataErrorType.unexpectedResponse,
        );
      }
      return _decodeToken(response);
    } on MetadataException {
      rethrow;
    } on TimeoutException {
      throw const MetadataException(
        'La autenticación con IGDB tardó demasiado.',
        type: MetadataErrorType.timeout,
      );
    } on SocketException {
      throw const MetadataException(
        'No se pudo conectar con IGDB/Twitch. Revisá tu conexión a internet.',
        type: MetadataErrorType.network,
      );
    } on http.ClientException {
      throw const MetadataException(
        'No se pudo conectar con IGDB/Twitch.',
        type: MetadataErrorType.network,
      );
    }
  }

  IgdbAuthToken _decodeToken(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final accessToken = decoded['access_token']?.toString().trim();
        final expiresIn = _intOrNull(decoded['expires_in']);
        if (accessToken != null &&
            accessToken.isNotEmpty &&
            expiresIn != null &&
            expiresIn > 0) {
          return IgdbAuthToken(
            accessToken: accessToken,
            expiresIn: Duration(seconds: expiresIn),
          );
        }
      }
    } on FormatException {
      // Handled below with the same safe public message.
    }
    throw const MetadataException(
      'IGDB/Twitch devolvió una respuesta de autenticación inesperada.',
      type: MetadataErrorType.unexpectedResponse,
    );
  }

  int? _intOrNull(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class IgdbAuthToken {
  const IgdbAuthToken({required this.accessToken, required this.expiresIn});

  final String accessToken;
  final Duration expiresIn;
}
