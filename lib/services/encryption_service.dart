import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:mangovault/services/key_service.dart';
import 'package:pointycastle/export.dart';

class EncryptionService {
  final KeyService _keyService;

  EncryptionService(this._keyService);

  Future<String> encrypt(String plaintext, String recipient) async {
    final iv = Uint8List.fromList(
      List<int>.generate(
        12,
        (i) => Random.secure().nextInt(256),
      ),
    );

    final cipher = await _initCipher(recipient, iv, encrypt: true);

    return base64.encode(cipher.process(utf8.encode(plaintext)) + iv);
  }

  Future<String> decrypt(String ciphertext, String sender) async {
    final bytes = base64.decode(ciphertext);
    final iv = bytes.sublist(bytes.length - 12);

    final cipher = await _initCipher(sender, iv, encrypt: false);

    return utf8.decode(cipher.process(bytes.sublist(0, bytes.length - 12)));
  }

  Future<GCMBlockCipher> _initCipher(
    String username,
    Uint8List iv, {
    required bool encrypt,
  }) async {
    Uint8List secretKey = await _keyService.retrieveSecretKey(username);

    if (secretKey.isEmpty) {
      await _keyService.fetchSecretKey(username);
      secretKey = await _keyService.retrieveSecretKey(username);
    }

    return GCMBlockCipher(AESEngine())
      ..init(
        encrypt,
        AEADParameters(
          KeyParameter(secretKey),
          128,
          iv,
          Uint8List(0),
        ),
      );
  }
}
