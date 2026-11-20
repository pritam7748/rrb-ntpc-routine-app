import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'storage_service.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    final canAuth = await canCheckBiometrics();
    if (!canAuth) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to open RRB NTPC Companion',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }

  static bool verifyPin(String enteredPin) {
    final storedPin = StorageService.getUserPin();
    if (storedPin == null) return true; // no pin set yet
    return storedPin == enteredPin;
  }
}
