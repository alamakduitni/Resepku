import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/cute_avatar.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import 'recipe_store.dart';

/// Sesi pengguna yang sedang masuk. Token disimpan di perangkat agar
/// pengguna tidak perlu login ulang setiap membuka aplikasi.
class UserStore {
  UserStore._();
  static final UserStore instance = UserStore._();

  static const String _tokenKey = 'auth_token';

  final ApiClient _api = ApiClient.instance;

  final ValueNotifier<UserModel?> user = ValueNotifier(null);

  /// Dipisah dari [user] agar avatar bisa langsung berganti saat dipilih,
  /// sebelum server selesai menyimpan.
  final ValueNotifier<int> avatarIndex = ValueNotifier(0);

  String get name => user.value?.name ?? '';
  String get firstName => user.value?.firstName ?? '';
  String get email => user.value?.email ?? '';

  CuteAvatarData get avatar => CuteAvatarData
      .presets[avatarIndex.value.clamp(0, CuteAvatarData.presets.length - 1)];

  /// Pulihkan sesi dari token tersimpan. Mengembalikan `true` jika token
  /// masih berlaku.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey);
    if (saved == null) return false;

    _api.token = saved;
    try {
      final data = await _api.get('/me') as Map<String, dynamic>;
      _setUser(UserModel.fromJson(data['user'] as Map<String, dynamic>));
      return true;
    } on ApiException catch (e) {
      // Token kedaluwarsa dihapus; kalau hanya gagal koneksi, simpan saja
      // agar bisa dicoba lagi saat aplikasi dibuka berikutnya.
      if (e.isUnauthorized) await prefs.remove(_tokenKey);
      _api.token = null;
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    final data = await _api.post('/login', {
      'email': email,
      'password': password,
      'device_name': 'resepku-flutter',
    }) as Map<String, dynamic>;

    final token = data['token'] as String;
    _api.token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Data resep (status favorit) bergantung pada siapa yang login.
    RecipeStore.instance.reset();
    _setUser(UserModel.fromJson(data['user'] as Map<String, dynamic>));
  }

  /// Mengembalikan pesan sukses dari server.
  Future<String> register(String name, String email, String password) async {
    final data = await _api.post('/register', {
      'name': name,
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    return data['message'] as String? ?? 'Akun berhasil dibuat!';
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } on ApiException {
      // Tetap keluar di perangkat walau server tidak bisa dihubungi.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _api.token = null;
    user.value = null;
    avatarIndex.value = 0;
    RecipeStore.instance.reset();
  }

  /// Simpan perubahan data akun. Field opsional yang dikosongkan dikirim
  /// sebagai null agar terhapus di server.
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? address,
    DateTime? birthDate,
  }) async {
    String? orNull(String? v) =>
        (v == null || v.trim().isEmpty) ? null : v.trim();

    final data = await _api.put('/me', {
      'name': name.trim(),
      'email': email.trim(),
      'phone': orNull(phone),
      'address': orNull(address),
      'birth_date': birthDate == null
          ? null
          : '${birthDate.year.toString().padLeft(4, '0')}-'
              '${birthDate.month.toString().padLeft(2, '0')}-'
              '${birthDate.day.toString().padLeft(2, '0')}',
    }) as Map<String, dynamic>;
    _setUser(UserModel.fromJson(data['user'] as Map<String, dynamic>));
  }

  /// Simpan karakter yang sedang dipratinjau di [avatarIndex] ke server.
  /// Jika gagal, avatar dikembalikan ke pilihan yang tersimpan.
  Future<void> saveAvatar() async {
    final index = avatarIndex.value;
    if (index == user.value?.avatarIndex) return;
    try {
      final data = await _api.put('/me', {'avatar_index': index})
          as Map<String, dynamic>;
      _setUser(UserModel.fromJson(data['user'] as Map<String, dynamic>));
    } on ApiException {
      discardAvatarPreview();
      rethrow;
    }
  }

  /// Batalkan pratinjau avatar yang belum disimpan.
  void discardAvatarPreview() {
    avatarIndex.value = user.value?.avatarIndex ?? 0;
  }

  void _setUser(UserModel value) {
    user.value = value;
    avatarIndex.value = value.avatarIndex;
  }

  @visibleForTesting
  void reset({UserModel? as}) {
    _api.token = as == null ? null : 'test-token';
    user.value = as;
    avatarIndex.value = as?.avatarIndex ?? 0;
  }
}
