import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:resepku/data/api/api_client.dart';
import 'package:resepku/data/models/user_model.dart';
import 'package:resepku/data/stores/recipe_store.dart';
import 'package:resepku/data/stores/user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testUser = UserModel(
  id: '1',
  name: 'Sari Wulandari',
  email: 'sari.wulandari@email.com',
  phone: '0812-3456-7890',
  address: 'Surabaya, Jawa Timur',
  avatarIndex: 0,
);

/// Server palsu yang meniru resepku-api memakai data dummy di
/// lib/data/dummy, supaya test tidak butuh server Laravel.
class FakeApi {
  final List<Map<String, dynamic>> recipes;
  final List<Map<String, dynamic>> categories;
  final Set<String> favorites = {'recipe_001', 'recipe_005', 'recipe_002'};
  final List<String> requests = [];
  final Map<String, int> ratings = {};

  /// Field dari request multipart terakhir (unggah foto).
  Map<String, String> multipartFields = {};

  /// Paksa semua request gagal dengan status ini (mis. 500).
  int? failWith;

  FakeApi()
      : recipes = _readJson('lib/data/dummy/dummy_recipes.json'),
        categories = _readJson('lib/data/dummy/dummy_categories.json')
            .where((c) => c['name'] != 'Semua')
            .toList();

  static List<Map<String, dynamic>> _readJson(String path) =>
      (json.decode(File(path).readAsStringSync()) as List)
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> get _userJson => {
        'id': int.parse(testUser.id),
        'name': testUser.name,
        'email': testUser.email,
        'phone': testUser.phone,
        'address': testUser.address,
        'birthDate': '1998-05-14',
        'profileImage': null,
        'avatarIndex': testUser.avatarIndex,
      };

  Map<String, dynamic> _recipeJson(Map<String, dynamic> r) =>
      {...r, 'isFavorite': favorites.contains(r['id'])};

  http.Client get client => MockClient((request) async {
        final path = request.url.path.replaceFirst(RegExp(r'^.*/api'), '');
        requests.add('${request.method} $path');
        if (failWith != null) {
          return _json({'message': 'Server error'}, failWith!);
        }
        final isMultipart = request.headers['content-type']
                ?.startsWith('multipart/form-data') ??
            false;
        if (isMultipart) multipartFields = _parseMultipart(request.bodyBytes);
        final body = isMultipart
            ? _multipartToJson(multipartFields)
            : request.body.isEmpty
                ? const <String, dynamic>{}
                : json.decode(request.body) as Map<String, dynamic>;

        final rating = RegExp(r'^/recipes/([^/]+)/rating$').firstMatch(path);
        if (rating != null) {
          final score = body['score'] as int;
          ratings[rating.group(1)!] = score;
          return _json({
            'message': 'Terima kasih atas ratingnya!',
            'rating': 4.2,
            'ratingCount': 6,
            'myRating': score,
          });
        }

        final favorite =
            RegExp(r'^/recipes/([^/]+)/favorite$').firstMatch(path);
        if (favorite != null) {
          final id = favorite.group(1)!;
          request.method == 'DELETE' ? favorites.remove(id) : favorites.add(id);
          return _json({'recipeId': id, 'isFavorite': favorites.contains(id)});
        }

        switch ('${request.method} $path') {
          case 'GET /categories':
            return _json({'data': categories});
          case 'GET /recipes':
            return _json({'data': recipes.map(_recipeJson).toList()});
          case 'GET /banners':
            return _json({
              'data': [
                {
                  'id': 1,
                  'caption': 'Favorit Minggu Ini',
                  'recipe': recipes[0]
                },
              ],
            });
          case 'POST /login':
            if (body['password'] != 'password') {
              return _json({
                'message': 'Email atau kata sandi salah.',
                'errors': {
                  'email': ['Email atau kata sandi salah.'],
                },
              }, 422);
            }
            return _json({'token': '1|abc', 'user': _userJson});
          case 'POST /register':
            return _json(
                {'message': 'Akun berhasil dibuat! Silakan masuk.'}, 201);
          case 'POST /logout':
            return _json({'message': 'Berhasil keluar.'});
          case 'GET /me':
            return _json({'user': _userJson});
          case 'PUT /me':
            return _json({
              'user': {
                ..._userJson,
                if (body.containsKey('avatar_index'))
                  'avatarIndex': body['avatar_index'],
                for (final key in ['name', 'email', 'phone', 'address'])
                  if (body.containsKey(key)) key: body[key],
                if (body.containsKey('birth_date'))
                  'birthDate': body['birth_date'],
              },
            });
          case 'POST /recipes':
            final category = categories
                .firstWhere((c) => c['name'] == body['category'])['name'];
            final created = <String, dynamic>{
              'id': 100 + recipes.length,
              'name': body['name'],
              'image': isMultipart
                  ? 'http://localhost/storage/recipes/upload.jpg'
                  : 'http://localhost/${body['image_path']}',
              'category': category,
              'cookingTimeMinutes': body['cooking_time_minutes'],
              'rating': 0,
              'ingredients': body['ingredients'],
              'steps': body['steps'],
              'uploader': {
                'id': 1,
                'name': testUser.name,
                'profileImage': null
              },
            };
            recipes.insert(0, created);
            return _json(
                {'message': 'Resep berhasil disimpan!', 'data': created}, 201);
        }
        return _json({'message': 'Endpoint tidak ditemukan.'}, 404);
      });

  /// Ambil field teks & nama file dari body multipart. Nilai file disimpan
  /// sebagai `file:<nama file>:<ukuran byte>`.
  static Map<String, String> _parseMultipart(List<int> bytes) {
    final text = latin1.decode(bytes);
    final fields = <String, String>{};
    final part = RegExp(
      r'content-disposition: form-data; name="([^"]+)"(?:; filename="([^"]*)")?'
      r'\r\n(?:[^\r\n]+\r\n)*\r\n([\s\S]*?)\r\n--',
      caseSensitive: false,
    );
    for (final m in part.allMatches(text)) {
      fields[m.group(1)!] = m.group(2) != null
          ? 'file:${m.group(2)}:${m.group(3)!.length}'
          : utf8.decode(latin1.encode(m.group(3)!));
    }
    return fields;
  }

  /// Ubah `ingredients[0][name]` dsb. menjadi struktur JSON biasa.
  static Map<String, dynamic> _multipartToJson(Map<String, String> fields) {
    final ingredients = <int, Map<String, String>>{};
    final steps = <int, String>{};
    final out = <String, dynamic>{};
    for (final MapEntry(:key, :value) in fields.entries) {
      final ing = RegExp(r'^ingredients\[(\d+)\]\[(\w+)\]$').firstMatch(key);
      final step = RegExp(r'^steps\[(\d+)\]$').firstMatch(key);
      if (ing != null) {
        (ingredients[int.parse(ing.group(1)!)] ??= {})[ing.group(2)!] = value;
      } else if (step != null) {
        steps[int.parse(step.group(1)!)] = value;
      } else {
        out[key] = int.tryParse(value) ?? value;
      }
    }
    out['ingredients'] = [
      for (final k in ingredients.keys.toList()..sort()) ingredients[k]
    ];
    out['steps'] = [for (final k in steps.keys.toList()..sort()) steps[k]];
    return out;
  }

  static http.Response _json(Object body, [int status = 200]) => http.Response(
        json.encode(body),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
}

/// Galeri palsu: mengembalikan [photo], atau null untuk meniru batal.
class FakeImagePicker extends ImagePickerPlatform {
  XFile? photo;

  FakeImagePicker({this.photo});

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async =>
      photo;
}

FakeImagePicker setUpFakeGallery() {
  final bytes =
      File('assets/images/recipes/es_teh_serai.jpg').readAsBytesSync();
  final picker = FakeImagePicker(
      photo: XFile.fromData(bytes,
          name: 'foto_galeri.jpg', mimeType: 'image/jpeg'));
  ImagePickerPlatform.instance = picker;
  return picker;
}

/// Pasang [FakeApi] dan kosongkan semua store. Jika [loggedIn], sesi
/// [testUser] langsung aktif seperti sesudah login.
FakeApi setUpFakeApi({bool loggedIn = true, Map<String, Object>? prefs}) {
  final api = FakeApi();
  ApiClient.instance.httpClient = api.client;
  SharedPreferences.setMockInitialValues(prefs ?? {});
  RecipeStore.instance.reset();
  UserStore.instance.reset(as: loggedIn ? testUser : null);
  return api;
}
