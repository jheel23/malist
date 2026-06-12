import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class EncryptionHelper {
  static const int _iterations = 10000;
  static const int _keyLength = 32;

  static Uint8List _deriveKey(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    var hmacSha256 = Hmac(sha256, passwordBytes);
    var block = Uint8List(_keyLength);
    var u = hmacSha256.convert([...salt, 0, 0, 0, 1]).bytes;
    for (int i = 0; i < _keyLength; i++) {
      block[i] = u[i];
    }
    for (int iter = 1; iter < _iterations; iter++) {
      u = hmacSha256.convert(u).bytes;
      for (int i = 0; i < _keyLength; i++) {
        block[i] ^= u[i];
      }
    }
    return block;
  }

  static Uint8List _generateSalt() {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(16, (_) => rng.nextInt(256)));
  }

  static String encrypt(String plainText, String password) {
    final salt = _generateSalt();
    final keyBytes = _deriveKey(password, salt);
    final key = Key(keyBytes);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final combined = <int>[...salt, ...iv.bytes, ...encrypted.bytes];
    return base64Encode(combined);
  }

  static String decrypt(String cipherText, String password) {
    final combined = base64Decode(cipherText);
    final salt = Uint8List.fromList(combined.sublist(0, 16));
    final ivBytes = combined.sublist(16, 32);
    final encryptedBytes = combined.sublist(32);
    final keyBytes = _deriveKey(password, salt);
    final key = Key(keyBytes);
    final iv = IV(Uint8List.fromList(ivBytes));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    return encrypter.decrypt(
      Encrypted(Uint8List.fromList(encryptedBytes)),
      iv: iv,
    );
  }
}
