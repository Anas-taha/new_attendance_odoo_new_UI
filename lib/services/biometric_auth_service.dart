import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';

enum BiometricAvailability {
  ready,
  notSupported,
  disabledInSettings,
}

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<BiometricAvailability> getAvailability() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) {
        return BiometricAvailability.notSupported;
      }

      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final enrolledBiometrics = await _auth.getAvailableBiometrics();
      if (!canCheckBiometrics || enrolledBiometrics.isEmpty) {
        return BiometricAvailability.disabledInSettings;
      }

      return BiometricAvailability.ready;
    } catch (_) {
      return BiometricAvailability.disabledInSettings;
    }
  }

  Future<bool> isAvailable() async {
    return await getAvailability() == BiometricAvailability.ready;
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> openDeviceSettings() => openAppSettings();
}
