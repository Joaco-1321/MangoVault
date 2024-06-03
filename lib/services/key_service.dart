import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mangovault/constants.dart';
import 'package:mangovault/services/api_service.dart';
import 'package:mangovault/services/websocket_service.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/key_derivators/ecdh_kdf.dart';

class KeyService {
  static const _privateKeyStorageKey = 'privateKey';
  static const _publicKeyStorageKey = 'publicKey';

  final ApiService _apiService;
  final WebSocketService _webSocketService;
  final _storage = const FlutterSecureStorage();
  final _domain = ECCurve_secp256r1();

  late final AsymmetricKeyPair<PublicKey, PrivateKey> _keyPair;

  KeyService(this._webSocketService, this._apiService) {
    _init();
  }

  Future<void> fetchSecretKey(String username) async {
    await _apiService.get(
      '$userEndpoint/key/$username',
      (value) async {
        await _storeSecretKey(username, value.body);
      },
    );
  }

  Future<void> removeSecretKey(String username) async {
    await _storage.delete(key: '${username}_secret');
  }

  Future<Uint8List> retrieveSecretKey(String username) async {
    final secret = await _storage.read(
      key: '${username}_secret',
    );

    return secret != null ? base64.decode(secret) : Uint8List(0);
  }

  Future<void> storeKeyPair(AsymmetricKeyPair keyPair) async {
    ECPublicKey publicKey = _keyPair.publicKey as ECPublicKey;
    ECPrivateKey privateKey = _keyPair.privateKey as ECPrivateKey;

    await _storage.write(
      key: _publicKeyStorageKey,
      value: base64.encode(publicKey.Q!.getEncoded(false)),
    );

    await _storage.write(
      key: _privateKeyStorageKey,
      value: base64.encode(
        utf8.encode(
          privateKey.d!.toRadixString(16),
        ),
      ),
    );
  }

  void _init() {
    _loadKeyPair();

    _webSocketService.subscribe(
      '/queue/notification/key',
      (frame) async {
        final keyUpdate = json.decode(frame.body!) as Map<String, String>;

        await _storeSecretKey(keyUpdate['username']!, keyUpdate['key']!);
      },
    );
  }

  Future<void> _loadKeyPair() async {
    final privateKeyEncoded = await _storage.read(key: _privateKeyStorageKey);
    final publicKeyEncoded = await _storage.read(key: _publicKeyStorageKey);

    if (privateKeyEncoded != null && publicKeyEncoded != null) {
      _keyPair = AsymmetricKeyPair(
        _decodePublicKey(publicKeyEncoded),
        _decodePrivateKey(privateKeyEncoded),
      );
    } else {
      _generateKeyPair();
    }

    _publishPublicKey(_keyPair.publicKey as ECPublicKey);
  }

  void _generateKeyPair() {
    final keyGenerator = ECKeyGenerator()
      ..init(ParametersWithRandom(
        ECKeyGeneratorParameters(_domain),
        FortunaRandom()
          ..seed(KeyParameter(
            Uint8List.fromList(
              List<int>.generate(
                32,
                (i) => Random.secure().nextInt(256),
              ),
            ),
          )),
      ));

    _keyPair = keyGenerator.generateKeyPair();

    _storeKeyPair(_keyPair);
  }

  Future<void> _publishPublicKey(ECPublicKey publicKey) async {
    await _apiService.post(
      '$userEndpoint/key',
      _encodePublicKey(publicKey),
    );
  }

  Future<void> _storeKeyPair(AsymmetricKeyPair keypair) async {
    await _storage.write(
      key: _publicKeyStorageKey,
      value: _encodePublicKey(keypair.publicKey as ECPublicKey),
    );

    await _storage.write(
      key: _privateKeyStorageKey,
      value: _encodePrivateKey(keypair.privateKey as ECPrivateKey),
    );
  }

  Future<void> _storeSecretKey(String username, String publicKey) async {
    if (publicKey.isNotEmpty) {
      final secret = _deriveKey(
        _computeSharedSecret(
          _decodePublicKey(publicKey),
        ),
      );

      await _storage.write(
        key: '${username}_secret',
        value: base64.encode(secret),
      );
    }
  }

  String _encodePublicKey(ECPublicKey publicKey) {
    return base64.encode(publicKey.Q!.getEncoded(false));
  }

  String _encodePrivateKey(ECPrivateKey privateKey) {
    return base64.encode(utf8.encode(privateKey.d!.toRadixString(16)));
  }

  ECPublicKey _decodePublicKey(String publicKeyEncoded) {
    return ECPublicKey(
      _domain.curve.decodePoint(
        base64.decode(publicKeyEncoded),
      ),
      _domain,
    );
  }

  ECPrivateKey _decodePrivateKey(String privateKeyEncoded) {
    return ECPrivateKey(
      BigInt.parse(
        utf8.decode(
          base64.decode(privateKeyEncoded),
        ),
        radix: 16,
      ),
      _domain,
    );
  }

  Uint8List _computeSharedSecret(PublicKey publicKey) {
    final keyDerivator = ECDHKeyDerivator()
      ..init(ECDHKDFParameters(
        PrivateKeyParameter<ECPrivateKey>(_keyPair.privateKey).key,
        PublicKeyParameter<ECPublicKey>(publicKey).key,
      ));

    final secret = Uint8List(32);

    keyDerivator.deriveKey(Uint8List(0), 0, secret, 0);

    return secret;
  }

  Uint8List _deriveKey(Uint8List secret) {
    final kdf = HKDFKeyDerivator(SHA256Digest())
      ..init(HkdfParameters(secret, 32));

    final derivedKey = Uint8List(32);

    kdf.deriveKey(null, 0, derivedKey, 0);

    return derivedKey;
  }
}
