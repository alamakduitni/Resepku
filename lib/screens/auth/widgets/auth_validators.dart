class AuthValidators {
  AuthValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email wajib diisi';
    if (!_emailPattern.hasMatch(v)) {
      return 'Format email belum benar, contoh: nama@email.com';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Kata sandi wajib diisi';
    if (v.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nama wajib diisi';
    if (v.length < 3) return 'Nama minimal 3 huruf';
    return null;
  }
}
