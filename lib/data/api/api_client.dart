import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

/// Error dari API dengan pesan yang siap ditampilkan ke pengguna.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Error validasi per field, mis. {'email': ['Email sudah terdaftar']}.
  final Map<String, List<String>> errors;

  const ApiException(this.message, {this.statusCode, this.errors = const {}});

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Pembungkus HTTP untuk semua panggilan ke resepku-api. Menambahkan
/// header JSON + token, lalu mengubah respons error menjadi [ApiException].
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  http.Client _http = http.Client();
  String? token;

  /// Ganti klien HTTP, dipakai test untuk menyuntikkan MockClient.
  @visibleForTesting
  set httpClient(http.Client client) => _http = client;

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, [Object? body]) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  /// Kirim form multipart, mis. untuk unggah foto. Field bersarang ditulis
  /// dengan notasi Laravel, mis. `ingredients[0][name]`.
  Future<dynamic> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
  }) {
    final request = http.MultipartRequest('POST', _uri(path))
      ..fields.addAll(fields)
      ..files.addAll(files);
    // Unggah foto bisa lebih lama dari request biasa.
    return _execute(request, timeout: ApiConfig.uploadTimeout);
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) {
    final request = http.Request(method, _uri(path, query));
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    return _execute(request);
  }

  Future<dynamic> _execute(
    http.BaseRequest request, {
    Duration timeout = ApiConfig.timeout,
  }) async {
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    final http.Response response;
    try {
      response = await http.Response.fromStream(
          await _http.send(request).timeout(timeout));
    } on TimeoutException {
      throw const ApiException(
          'Server tidak merespons. Coba lagi sebentar lagi.');
    } on http.ClientException {
      throw const ApiException(
          'Tidak bisa terhubung ke server. Pastikan server Resepku berjalan.');
    }

    final dynamic data = response.body.isEmpty ? null : _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    throw _toException(response.statusCode, data);
  }

  dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  ApiException _toException(int status, dynamic data) {
    final map = data is Map<String, dynamic> ? data : const {};
    final errors = <String, List<String>>{
      if (map['errors'] is Map)
        for (final e in (map['errors'] as Map).entries)
          e.key as String: [for (final m in e.value as List) m.toString()],
    };
    // Untuk error validasi, tampilkan pesan pertama saja tanpa
    // "(dan N kesalahan lainnya)".
    final message = errors.values.firstOrNull?.firstOrNull ??
        map['message'] as String? ??
        switch (status) {
          401 => 'Sesi berakhir, silakan masuk kembali.',
          403 => 'Kamu tidak punya akses untuk aksi ini.',
          404 => 'Data tidak ditemukan.',
          429 => 'Terlalu banyak percobaan, coba lagi sebentar lagi.',
          _ => 'Terjadi kesalahan di server ($status).',
        };
    return ApiException(message, statusCode: status, errors: errors);
  }
}
