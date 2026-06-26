import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../../../core/ids/id_generator.dart';
import '../../../core/version/app_versions.dart';
import '../domain/lan_sync_models.dart';
import '../domain/sync_package_models.dart';
import '../domain/sync_pairing_models.dart';
import 'canonical_json.dart';
import 'lan_media_transfer_service.dart';
import 'sync_group_management.dart';
import 'sync_package_service.dart';

typedef SyncPairingStateLoader = Future<SyncPairingState> Function();

class LanSyncService {
  LanSyncService({
    required SyncPackageService packageService,
    required LanMediaTransferService mediaTransfer,
    required SyncGroupKeyResolver groupKeys,
    required SyncPairingStateLoader pairingStateLoader,
    IdGenerator? ids,
    Random? random,
    Duration timeout = const Duration(seconds: 20),
    Duration sessionTimeout = const Duration(minutes: 5),
    int maxRequestBytes = defaultMaxRequestBytes,
  }) : _packageService = packageService,
       _mediaTransfer = mediaTransfer,
       _groupKeys = groupKeys,
       _pairingStateLoader = pairingStateLoader,
       _ids = ids ?? defaultIdGenerator,
       _random = random ?? Random.secure(),
       _timeout = timeout,
       _sessionTimeout = sessionTimeout,
       _maxRequestBytes = maxRequestBytes;

  static const defaultMaxRequestBytes = 24 * 1024 * 1024;

  final SyncPackageService _packageService;
  final LanMediaTransferService _mediaTransfer;
  final SyncGroupKeyResolver _groupKeys;
  final SyncPairingStateLoader _pairingStateLoader;
  final IdGenerator _ids;
  final Random _random;
  final Duration _timeout;
  final Duration _sessionTimeout;
  final int _maxRequestBytes;

  Future<LanSyncHostSession> startHost({
    InternetAddress? bindAddress,
    int port = 0,
    String? displayAddress,
  }) async {
    final key = await _groupKeys.requireActiveGroupKey();
    final state = await _pairedState();
    final server = await HttpServer.bind(
      bindAddress ?? InternetAddress.anyIPv4,
      port,
    );
    final hostNonce = _nonce();
    final session = LanSyncHostSession._(
      sessionId: _newUuid(),
      sessionCode: _sessionCode(),
      host: displayAddress ?? await _localIpv4Address(),
      port: server.port,
      localDevice: state.localDevice,
      server: server,
    );
    session._attachTimeoutTimer(
      Timer(_sessionTimeout, () {
        session._completeError(const LanSyncException(LanSyncFailure.timeout));
        unawaited(session.stop());
      }),
    );
    String? acceptedClientNonce;
    SyncPackageDevice? acceptedClientDevice;
    var exchangeStarted = false;
    var mediaStarted = false;
    _HostExchangeState? exchangeState;

    server.listen((request) {
      unawaited(
        _handleHostRequest(
          request: request,
          session: session,
          key: key,
          hostNonce: hostNonce,
          acceptedClientNonce: () => acceptedClientNonce,
          acceptedClientDevice: () => acceptedClientDevice,
          exchangeState: () => exchangeState,
          acceptClient: (nonce, device) {
            acceptedClientNonce = nonce;
            acceptedClientDevice = device;
          },
          storeExchangeState: (state) => exchangeState = state,
          exchangeStarted: () => exchangeStarted,
          markExchangeStarted: () => exchangeStarted = true,
          mediaStarted: () => mediaStarted,
          markMediaStarted: () => mediaStarted = true,
        ),
      );
    });
    return session;
  }

  Future<LanSyncResult> connectAndSync({
    required String host,
    required int port,
    required String sessionCode,
  }) async {
    try {
      return await _connectAndSync(
        host: host,
        port: port,
        sessionCode: sessionCode,
      );
    } on FormatException {
      throw const LanSyncException(LanSyncFailure.packageRejected);
    } on HttpException {
      throw const LanSyncException(LanSyncFailure.connectionInterrupted);
    }
  }

  Future<LanSyncResult> _connectAndSync({
    required String host,
    required int port,
    required String sessionCode,
  }) async {
    final normalizedCode = _normalizeCode(sessionCode);
    if (normalizedCode.isEmpty) {
      throw const LanSyncException(LanSyncFailure.invalidSessionCode);
    }
    final key = await _groupKeys.requireActiveGroupKey();
    final state = await _pairedState();
    final clientNonce = _nonce();
    final helloProof = _proof(key.bytes, {
      'type': 'hello',
      'groupId': key.groupId,
      'keyId': key.keyId,
      'deviceId': state.localDevice.deviceId,
      'clientNonce': clientNonce,
      'sessionCode': normalizedCode,
    });
    final hello = await _postJson(
      host: host,
      port: port,
      path: '/sync/hello',
      body: {
        'formatVersion': 1,
        'syncProtocolVersion': syncProtocolVersion,
        'groupId': key.groupId,
        'keyId': key.keyId,
        'device': state.localDevice.toJson(),
        'clientNonce': clientNonce,
        'proof': helloProof,
      },
    );
    final sessionId = _string(hello, 'sessionId');
    final hostNonce = _string(hello, 'hostNonce');
    final hostDevice = SyncPackageDevice.fromJson(_map(hello['hostDevice']));
    _expectProof(key.bytes, _string(hello, 'proof'), {
      'type': 'helloResponse',
      'sessionId': sessionId,
      'groupId': key.groupId,
      'keyId': key.keyId,
      'clientNonce': clientNonce,
      'hostNonce': hostNonce,
      'deviceId': hostDevice.deviceId,
      'sessionCode': normalizedCode,
    });

    final outgoing = await _packageService.exportWithGroupKey();
    final packageHash = _sha256Base64(outgoing.bytes);
    final exchangeProof = _proof(key.bytes, {
      'type': 'exchange',
      'sessionId': sessionId,
      'groupId': key.groupId,
      'keyId': key.keyId,
      'clientNonce': clientNonce,
      'hostNonce': hostNonce,
      'deviceId': state.localDevice.deviceId,
      'packageHash': packageHash,
      'sessionCode': normalizedCode,
    });
    final exchange = await _postJson(
      host: host,
      port: port,
      path: '/sync/exchange',
      body: {
        'formatVersion': 1,
        'syncProtocolVersion': syncProtocolVersion,
        'sessionId': sessionId,
        'groupId': key.groupId,
        'keyId': key.keyId,
        'device': state.localDevice.toJson(),
        'clientNonce': clientNonce,
        'package': base64Encode(outgoing.bytes),
        'proof': exchangeProof,
      },
    );
    final incomingBytes = _decodePackageBytes(_string(exchange, 'package'));
    final peerExchange = LanSyncSummary.fromJson(_map(exchange['result']));
    final hostRequests = _mediaRequests(exchange['mediaRequests']);
    _expectProof(key.bytes, _string(exchange, 'proof'), {
      'type': 'exchangeResponse',
      'sessionId': sessionId,
      'groupId': key.groupId,
      'keyId': key.keyId,
      'clientNonce': clientNonce,
      'hostNonce': hostNonce,
      'deviceId': hostDevice.deviceId,
      'packageHash': _sha256Base64(incomingBytes),
      'result': peerExchange.toJson(),
      'mediaRequests': _mediaRequestsJson(hostRequests),
      'sessionCode': normalizedCode,
    });
    final localApply = await _packageService.applySafeChangesWithGroupKey(
      incomingBytes,
    );
    final localPrepare = await _mediaTransfer.prepareIncomingMedia(
      localApply.preview.document,
    );
    final uploads = await _mediaTransfer.buildPayloads(
      document: outgoing.document,
      requests: hostRequests,
    );
    final mediaProofBody = {
      'type': 'media',
      'sessionId': sessionId,
      'groupId': key.groupId,
      'keyId': key.keyId,
      'clientNonce': clientNonce,
      'hostNonce': hostNonce,
      'deviceId': state.localDevice.deviceId,
      'requests': _mediaRequestsJson(localPrepare.requests),
      'payloads': _mediaPayloadsJson(uploads.payloads),
      'sessionCode': normalizedCode,
    };
    final media = await _postJson(
      host: host,
      port: port,
      path: '/sync/media',
      body: {
        'formatVersion': 1,
        'syncProtocolVersion': syncProtocolVersion,
        'sessionId': sessionId,
        'groupId': key.groupId,
        'keyId': key.keyId,
        'device': state.localDevice.toJson(),
        'clientNonce': clientNonce,
        'requests': _mediaRequestsJson(localPrepare.requests),
        'payloads': _mediaPayloadsJson(uploads.payloads),
        'proof': _proof(key.bytes, mediaProofBody),
      },
    );
    final hostPayloads = _mediaPayloads(media['payloads']);
    final peer = LanSyncSummary.fromJson(_map(media['result']));
    _expectProof(key.bytes, _string(media, 'proof'), {
      'type': 'mediaResponse',
      'sessionId': sessionId,
      'groupId': key.groupId,
      'keyId': key.keyId,
      'clientNonce': clientNonce,
      'hostNonce': hostNonce,
      'deviceId': hostDevice.deviceId,
      'payloads': _mediaPayloadsJson(hostPayloads),
      'result': peer.toJson(),
      'sessionCode': normalizedCode,
    });
    final received = await _mediaTransfer.receivePayloads(
      document: localApply.preview.document,
      payloads: hostPayloads,
    );
    final localSummary = LanSyncSummary.fromImportResult(
      changesSent: outgoing.changeCount,
      result: localApply,
    ).withMedia(
      mediaRequested: localPrepare.requests.length,
      mediaSent: uploads.sent,
      mediaReceived: received.received,
      mediaSkipped: localPrepare.skipped + uploads.skipped + received.skipped,
      mediaFailed: localPrepare.failed + uploads.failed + received.failed,
      mediaBytesTransferred:
          uploads.bytesTransferred + received.bytesTransferred,
      pendingMedia: received.pendingAfterReceive,
    );
    return LanSyncResult(
      peerDevice: hostDevice,
      local: localSummary,
      peer: peer,
    );
  }

  Future<void> _handleHostRequest({
    required HttpRequest request,
    required LanSyncHostSession session,
    required SyncGroupKeyMaterial key,
    required String hostNonce,
    required String? Function() acceptedClientNonce,
    required SyncPackageDevice? Function() acceptedClientDevice,
    required _HostExchangeState? Function() exchangeState,
    required void Function(String nonce, SyncPackageDevice device) acceptClient,
    required void Function(_HostExchangeState state) storeExchangeState,
    required bool Function() exchangeStarted,
    required void Function() markExchangeStarted,
    required bool Function() mediaStarted,
    required void Function() markMediaStarted,
  }) async {
    try {
      if (request.method != 'POST') {
        throw const LanSyncException(LanSyncFailure.invalidRequest);
      }
      if (request.uri.path == '/sync/hello') {
        final body = await _readJson(request);
        _validateEnvelope(body, key);
        if (acceptedClientNonce() != null) {
          throw const LanSyncException(LanSyncFailure.invalidRequest);
        }
        final device = SyncPackageDevice.fromJson(_map(body['device']));
        final clientNonce = _string(body, 'clientNonce');
        _expectProof(
          key.bytes,
          _string(body, 'proof'),
          {
            'type': 'hello',
            'groupId': key.groupId,
            'keyId': key.keyId,
            'deviceId': device.deviceId,
            'clientNonce': clientNonce,
            'sessionCode': session.sessionCode,
          },
          codeFailure: LanSyncFailure.invalidSessionCode,
        );
        acceptClient(clientNonce, device);
        await _writeJson(request.response, {
          'formatVersion': 1,
          'syncProtocolVersion': syncProtocolVersion,
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'hostDevice': session.localDevice.toJson(),
          'hostNonce': hostNonce,
          'proof': _proof(key.bytes, {
            'type': 'helloResponse',
            'sessionId': session.sessionId,
            'groupId': key.groupId,
            'keyId': key.keyId,
            'clientNonce': clientNonce,
            'hostNonce': hostNonce,
            'deviceId': session.localDevice.deviceId,
            'sessionCode': session.sessionCode,
          }),
        });
        return;
      }
      if (request.uri.path == '/sync/exchange') {
        final body = await _readJson(request);
        _validateEnvelope(body, key);
        if (exchangeStarted()) {
          throw const LanSyncException(LanSyncFailure.invalidRequest);
        }
        markExchangeStarted();
        if (_string(body, 'sessionId') != session.sessionId) {
          throw const LanSyncException(LanSyncFailure.invalidRequest);
        }
        final device = SyncPackageDevice.fromJson(_map(body['device']));
        final clientNonce = _string(body, 'clientNonce');
        if (clientNonce != acceptedClientNonce() ||
            device.deviceId != acceptedClientDevice()?.deviceId) {
          throw const LanSyncException(LanSyncFailure.invalidRequest);
        }
        final incomingBytes = _decodePackageBytes(_string(body, 'package'));
        _expectProof(key.bytes, _string(body, 'proof'), {
          'type': 'exchange',
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'clientNonce': clientNonce,
          'hostNonce': hostNonce,
          'deviceId': device.deviceId,
          'packageHash': _sha256Base64(incomingBytes),
          'sessionCode': session.sessionCode,
        });
        final incomingApply = await _packageService
            .applySafeChangesWithGroupKey(incomingBytes);
        final outgoing = await _packageService.exportWithGroupKey();
        final mediaPrepare = await _mediaTransfer.prepareIncomingMedia(
          incomingApply.preview.document,
        );
        final localSummary = LanSyncSummary.fromImportResult(
          changesSent: outgoing.changeCount,
          result: incomingApply,
        ).withMedia(
          mediaRequested: mediaPrepare.requests.length,
          mediaSkipped: mediaPrepare.skipped,
          mediaFailed: mediaPrepare.failed,
          pendingMedia: mediaPrepare.pendingAfterLocalResolution,
        );
        storeExchangeState(
          _HostExchangeState(
            clientDevice: device,
            clientNonce: clientNonce,
            incomingDocument: incomingApply.preview.document,
            outgoingDocument: outgoing.document,
            localSummary: localSummary,
            mediaRequests: mediaPrepare.requests,
          ),
        );
        final response = {
          'formatVersion': 1,
          'syncProtocolVersion': syncProtocolVersion,
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'package': base64Encode(outgoing.bytes),
          'result': localSummary.toJson(),
          'mediaRequests': _mediaRequestsJson(mediaPrepare.requests),
        };
        response['proof'] = _proof(key.bytes, {
          'type': 'exchangeResponse',
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'clientNonce': clientNonce,
          'hostNonce': hostNonce,
          'deviceId': session.localDevice.deviceId,
          'packageHash': _sha256Base64(outgoing.bytes),
          'result': localSummary.toJson(),
          'mediaRequests': _mediaRequestsJson(mediaPrepare.requests),
          'sessionCode': session.sessionCode,
        });
        await _writeJson(request.response, response);
        return;
      }
      if (request.uri.path == '/sync/media') {
        final body = await _readJson(request);
        _validateEnvelope(body, key);
        if (mediaStarted()) {
          throw const LanSyncException(LanSyncFailure.invalidRequest);
        }
        markMediaStarted();
        final state = exchangeState();
        if (state == null || _string(body, 'sessionId') != session.sessionId) {
          throw const LanSyncException(LanSyncFailure.invalidRequest);
        }
        final device = SyncPackageDevice.fromJson(_map(body['device']));
        final clientNonce = _string(body, 'clientNonce');
        if (clientNonce != acceptedClientNonce() ||
            clientNonce != state.clientNonce ||
            device.deviceId != acceptedClientDevice()?.deviceId ||
            device.deviceId != state.clientDevice.deviceId) {
          throw const LanSyncException(LanSyncFailure.invalidRequest);
        }
        final requests = _mediaRequests(body['requests']);
        final payloads = _mediaPayloads(body['payloads']);
        _expectProof(key.bytes, _string(body, 'proof'), {
          'type': 'media',
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'clientNonce': clientNonce,
          'hostNonce': hostNonce,
          'deviceId': device.deviceId,
          'requests': _mediaRequestsJson(requests),
          'payloads': _mediaPayloadsJson(payloads),
          'sessionCode': session.sessionCode,
        });
        final outgoingMedia = await _mediaTransfer.buildPayloads(
          document: state.outgoingDocument,
          requests: requests,
        );
        final incomingMedia = await _mediaTransfer.receivePayloads(
          document: state.incomingDocument,
          payloads: payloads,
        );
        final finalSummary = state.localSummary.withMedia(
          mediaSent: outgoingMedia.sent,
          mediaReceived: incomingMedia.received,
          mediaSkipped:
              state.localSummary.mediaSkipped +
              outgoingMedia.skipped +
              incomingMedia.skipped,
          mediaFailed:
              state.localSummary.mediaFailed +
              outgoingMedia.failed +
              incomingMedia.failed,
          mediaBytesTransferred:
              outgoingMedia.bytesTransferred + incomingMedia.bytesTransferred,
          pendingMedia: incomingMedia.pendingAfterReceive,
        );
        final response = {
          'formatVersion': 1,
          'syncProtocolVersion': syncProtocolVersion,
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'payloads': _mediaPayloadsJson(outgoingMedia.payloads),
          'result': finalSummary.toJson(),
        };
        response['proof'] = _proof(key.bytes, {
          'type': 'mediaResponse',
          'sessionId': session.sessionId,
          'groupId': key.groupId,
          'keyId': key.keyId,
          'clientNonce': clientNonce,
          'hostNonce': hostNonce,
          'deviceId': session.localDevice.deviceId,
          'payloads': _mediaPayloadsJson(outgoingMedia.payloads),
          'result': finalSummary.toJson(),
          'sessionCode': session.sessionCode,
        });
        await _writeJson(request.response, response);
        session._complete(
          LanSyncResult(peerDevice: device, local: finalSummary),
        );
        unawaited(session.stop());
        return;
      }
      throw const LanSyncException(LanSyncFailure.invalidRequest);
    } on LanSyncException catch (error) {
      await _finishFailedHostRequest(request.response, session, error.failure);
    } on SyncPairingException catch (error) {
      await _finishFailedHostRequest(
        request.response,
        session,
        _pairingFailure(error),
      );
    } on SyncPackageException {
      await _finishFailedHostRequest(
        request.response,
        session,
        LanSyncFailure.packageRejected,
      );
    } on FormatException {
      await _finishFailedHostRequest(
        request.response,
        session,
        LanSyncFailure.packageRejected,
      );
    } on TimeoutException {
      await _finishFailedHostRequest(
        request.response,
        session,
        LanSyncFailure.timeout,
      );
    } on HttpException {
      await _finishFailedHostRequest(
        request.response,
        session,
        LanSyncFailure.connectionInterrupted,
      );
    } on Object {
      await _finishFailedHostRequest(
        request.response,
        session,
        LanSyncFailure.invalidRequest,
      );
    }
  }

  Future<SyncPairingState> _pairedState() async {
    final state = await _pairingStateLoader();
    if (!state.isConfigured) {
      throw const LanSyncException(LanSyncFailure.notPaired);
    }
    if (!state.hasGroupKey) {
      throw const LanSyncException(LanSyncFailure.keyMissing);
    }
    return state;
  }

  Future<Map<String, Object?>> _postJson({
    required String host,
    required int port,
    required String path,
    required Map<String, Object?> body,
  }) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.post(host, port, path).timeout(_timeout);
      request.headers.contentType = ContentType.json;
      final bytes = utf8.encode(jsonEncode(body));
      if (bytes.length > _maxRequestBytes) {
        throw const LanSyncException(LanSyncFailure.requestTooLarge);
      }
      request.contentLength = bytes.length;
      request.add(bytes);
      final response = await request.close().timeout(_timeout);
      final decoded = await _readResponseJson(response);
      if (response.statusCode != HttpStatus.ok) {
        throw LanSyncException(_failureFromJson(decoded));
      }
      return decoded;
    } on LanSyncException {
      rethrow;
    } on TimeoutException {
      throw const LanSyncException(LanSyncFailure.timeout);
    } on HttpException {
      throw const LanSyncException(LanSyncFailure.connectionInterrupted);
    } on SocketException {
      throw const LanSyncException(LanSyncFailure.networkUnavailable);
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, Object?>> _readJson(HttpRequest request) async {
    final bytes = await _readBytes(request, _maxRequestBytes).timeout(_timeout);
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) return decoded;
      if (decoded is Map) return Map<String, Object?>.from(decoded);
    } on Object {
      throw const LanSyncException(LanSyncFailure.invalidRequest);
    }
    throw const LanSyncException(LanSyncFailure.invalidRequest);
  }

  Future<Map<String, Object?>> _readResponseJson(
    HttpClientResponse response,
  ) async {
    final bytes = await _readBytes(
      response,
      _maxRequestBytes,
    ).timeout(_timeout);
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) return decoded;
      if (decoded is Map) return Map<String, Object?>.from(decoded);
    } on Object {
      throw const LanSyncException(LanSyncFailure.invalidRequest);
    }
    throw const LanSyncException(LanSyncFailure.invalidRequest);
  }

  Future<List<int>> _readBytes(Stream<List<int>> stream, int maxBytes) async {
    final builder = BytesBuilder(copy: false);
    var total = 0;
    var tooLarge = false;
    await for (final chunk in stream) {
      total += chunk.length;
      if (total > maxBytes) {
        tooLarge = true;
        continue;
      }
      if (!tooLarge) {
        builder.add(chunk);
      }
    }
    if (tooLarge) {
      throw const LanSyncException(LanSyncFailure.requestTooLarge);
    }
    return builder.takeBytes();
  }

  void _validateEnvelope(
    Map<String, Object?> body,
    SyncGroupKeyMaterial expected,
  ) {
    if (_integer(body, 'formatVersion') != 1 ||
        _integer(body, 'syncProtocolVersion') != syncProtocolVersion) {
      throw const LanSyncException(LanSyncFailure.protocolMismatch);
    }
    final groupId = _string(body, 'groupId');
    final keyId = _string(body, 'keyId');
    if (groupId != expected.groupId) {
      throw const LanSyncException(LanSyncFailure.groupMismatch);
    }
    if (keyId != expected.keyId) {
      throw const LanSyncException(LanSyncFailure.keyIdMismatch);
    }
  }

  Future<void> _writeJson(
    HttpResponse response,
    Map<String, Object?> body, {
    int statusCode = HttpStatus.ok,
  }) async {
    response.statusCode = statusCode;
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(body));
    await response.close();
  }

  Future<void> _writeError(HttpResponse response, LanSyncFailure failure) {
    final status = switch (failure) {
      LanSyncFailure.requestTooLarge => HttpStatus.requestEntityTooLarge,
      LanSyncFailure.invalidSessionCode => HttpStatus.forbidden,
      LanSyncFailure.groupMismatch ||
      LanSyncFailure.keyIdMismatch => HttpStatus.forbidden,
      LanSyncFailure.protocolMismatch => HttpStatus.preconditionFailed,
      _ => HttpStatus.badRequest,
    };
    return _writeJson(response, {'error': failure.name}, statusCode: status);
  }

  Future<void> _finishFailedHostRequest(
    HttpResponse response,
    LanSyncHostSession session,
    LanSyncFailure failure,
  ) async {
    try {
      await _writeError(response, failure);
    } on Object {
      // The peer may have disconnected before receiving the failure response.
    }
    session._completeError(LanSyncException(failure));
    unawaited(session.stop());
  }

  void _expectProof(
    List<int> groupKey,
    String received,
    Map<String, Object?> message, {
    LanSyncFailure codeFailure = LanSyncFailure.invalidRequest,
  }) {
    final expected = _proof(groupKey, message);
    if (!_constantTimeEquals(utf8.encode(received), utf8.encode(expected))) {
      throw LanSyncException(codeFailure);
    }
  }

  String _proof(List<int> groupKey, Map<String, Object?> message) {
    final encoded = canonicalJson.encode(message);
    final mac = Hmac(sha256, groupKey).convert(utf8.encode(encoded));
    return base64UrlEncode(mac.bytes);
  }

  String _sha256Base64(List<int> bytes) =>
      base64UrlEncode(sha256.convert(bytes).bytes);

  List<int> _decodePackageBytes(String encoded) {
    try {
      return base64Decode(encoded);
    } on FormatException {
      throw const LanSyncException(LanSyncFailure.packageRejected);
    }
  }

  String _nonce() => base64UrlEncode(_randomBytes(16));

  List<int> _randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));

  String _sessionCode() =>
      (100000 + _random.nextInt(900000)).toString().padLeft(6, '0');

  String _normalizeCode(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();

  String _newUuid() {
    final value = _ids.newId();
    if (!RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(value)) {
      throw StateError('Generated LAN sync session id is not a UUID v4.');
    }
    return value;
  }

  Future<String> _localIpv4Address() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) return address.address;
        }
      }
    } on Object {
      // Fall back to loopback for a safe, local-only display value.
    }
    return InternetAddress.loopbackIPv4.address;
  }
}

class _HostExchangeState {
  const _HostExchangeState({
    required this.clientDevice,
    required this.clientNonce,
    required this.incomingDocument,
    required this.outgoingDocument,
    required this.localSummary,
    required this.mediaRequests,
  });

  final SyncPackageDevice clientDevice;
  final String clientNonce;
  final SyncPackageDocument incomingDocument;
  final SyncPackageDocument outgoingDocument;
  final LanSyncSummary localSummary;
  final List<LanMediaRequest> mediaRequests;
}

class LanSyncHostSession {
  LanSyncHostSession._({
    required this.sessionId,
    required this.sessionCode,
    required this.host,
    required this.port,
    required this.localDevice,
    required HttpServer server,
  }) : _server = server;

  final String sessionId;
  final String sessionCode;
  final String host;
  final int port;
  final SyncPackageDevice localDevice;
  final HttpServer _server;
  final _completed = Completer<LanSyncResult>();
  Timer? _timeoutTimer;
  var _stopped = false;

  Future<LanSyncResult> get completed => _completed.future;

  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    _timeoutTimer?.cancel();
    await _server.close(force: true);
    if (!_completed.isCompleted) {
      _completed.completeError(const LanSyncException(LanSyncFailure.stopped));
    }
  }

  void _complete(LanSyncResult result) {
    if (!_completed.isCompleted) {
      _timeoutTimer?.cancel();
      _completed.complete(result);
    }
  }

  void _completeError(Object error) {
    if (!_completed.isCompleted) {
      _timeoutTimer?.cancel();
      _completed.completeError(error);
    }
  }

  void _attachTimeoutTimer(Timer timer) {
    _timeoutTimer?.cancel();
    _timeoutTimer = timer;
  }
}

LanSyncFailure _pairingFailure(SyncPairingException error) {
  return switch (error.failure) {
    SyncPairingFailure.noGroup => LanSyncFailure.notPaired,
    SyncPairingFailure.keyMissing => LanSyncFailure.keyMissing,
    SyncPairingFailure.groupMismatch => LanSyncFailure.groupMismatch,
    SyncPairingFailure.keyIdMismatch => LanSyncFailure.keyIdMismatch,
    _ => LanSyncFailure.invalidRequest,
  };
}

LanSyncFailure _failureFromJson(Map<String, Object?> json) {
  final value = json['error'];
  if (value is String) {
    for (final failure in LanSyncFailure.values) {
      if (failure.name == value) return failure;
    }
  }
  return LanSyncFailure.invalidRequest;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw const LanSyncException(LanSyncFailure.invalidRequest);
}

int _integer(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw const LanSyncException(LanSyncFailure.invalidRequest);
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);
  throw const LanSyncException(LanSyncFailure.invalidRequest);
}

List<LanMediaRequest> _mediaRequests(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const LanSyncException(LanSyncFailure.invalidRequest);
  }
  return value.map((item) => LanMediaRequest.fromJson(_map(item))).toList();
}

List<LanMediaPayload> _mediaPayloads(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const LanSyncException(LanSyncFailure.invalidRequest);
  }
  return value.map((item) => LanMediaPayload.fromJson(_map(item))).toList();
}

List<Map<String, Object?>> _mediaRequestsJson(List<LanMediaRequest> requests) =>
    requests.map((request) => request.toJson()).toList(growable: false);

List<Map<String, Object?>> _mediaPayloadsJson(List<LanMediaPayload> payloads) =>
    payloads.map((payload) => payload.toJson()).toList(growable: false);

bool _constantTimeEquals(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var index = 0; index < left.length; index++) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}
