import 'package:flutter/foundation.dart';

/// Alamat server Laravel (resepku-api).
///
/// Bisa diganti tanpa ubah kode:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api`
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    // Emulator Android melihat komputer host sebagai 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static const Duration timeout = Duration(seconds: 15);
  static const Duration uploadTimeout = Duration(seconds: 60);

  /// Batas ukuran foto, sama dengan aturan `max:2048` (KB) di server.
  static const int maxPhotoBytes = 2 * 1024 * 1024;
}
