import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../api/api_client.dart';
import '../models/category_model.dart';
import '../models/recipe_model.dart';

/// Foto yang dipilih dari galeri, siap diunggah.
class PickedPhoto {
  final Uint8List bytes;
  final String filename;

  const PickedPhoto({required this.bytes, required this.filename});
}

/// Sumber data resep. Data dimuat dari resepku-api sekali, lalu disimpan
/// di memori sehingga semua layar ikut ter-update saat ada resep baru
/// atau favorit berubah.
class RecipeStore {
  RecipeStore._();
  static final RecipeStore instance = RecipeStore._();

  /// Kategori khusus di aplikasi; tidak ada di database.
  static const CategoryModel allCategory =
      CategoryModel(id: 'all', name: 'Semua', icon: '');

  final ApiClient _api = ApiClient.instance;

  final ValueNotifier<List<RecipeModel>> recipes = ValueNotifier(const []);
  final ValueNotifier<Set<String>> favoriteIds = ValueNotifier(const {});

  List<CategoryModel> categories = const [];

  /// Carousel Beranda: pasangan (id resep, keterangan).
  List<(String, String)> banners = const [];

  Future<void>? _loading;

  Future<void> ensureLoaded() {
    return _loading ??= _load().catchError((Object e) {
      _loading = null; // izinkan coba lagi
      throw e;
    });
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _api.get('/categories'),
      _api.get('/recipes'),
      _api.get('/banners'),
    ]);

    categories = [
      allCategory,
      for (final c in _list(results[0])) CategoryModel.fromJson(c),
    ];

    final recipeJson = _list(results[1]);
    recipes.value = [for (final r in recipeJson) RecipeModel.fromJson(r)];
    favoriteIds.value = {
      for (final r in recipeJson)
        if (r['isFavorite'] == true) r['id'].toString(),
    };

    banners = [
      for (final b in _list(results[2]))
        (
          (b['recipe'] as Map<String, dynamic>)['id'].toString(),
          b['caption'] as String,
        ),
    ];
  }

  List<Map<String, dynamic>> _list(dynamic response) =>
      ((response as Map<String, dynamic>)['data'] as List)
          .cast<Map<String, dynamic>>();

  /// Kosongkan data, mis. saat ganti akun, agar dimuat ulang dari server.
  void reset() {
    _loading = null;
    categories = const [];
    banners = const [];
    recipes.value = const [];
    favoriteIds.value = const {};
  }

  /// Simpan resep baru ke server lalu tampilkan paling atas.
  ///
  /// Isi salah satu sampul:
  /// - [coverAsset]: path asset bawaan, mis.
  ///   "assets/images/recipes/ayam_geprek.jpg"; server punya salinannya di
  ///   "images/recipes/...".
  /// - [photo]: foto dari galeri, dikirim sebagai multipart.
  Future<RecipeModel> createRecipe({
    required String name,
    required String category,
    required int cookingTimeMinutes,
    String? coverAsset,
    PickedPhoto? photo,
    required List<Ingredient> ingredients,
    required List<String> steps,
  }) async {
    assert((coverAsset == null) != (photo == null),
        'Isi salah satu: coverAsset atau photo');

    final dynamic data;
    if (photo != null) {
      data = await _api.postMultipart(
        '/recipes',
        fields: {
          'name': name,
          'category': category,
          'cooking_time_minutes': '$cookingTimeMinutes',
          for (final (i, item) in ingredients.indexed) ...{
            'ingredients[$i][name]': item.name,
            'ingredients[$i][amount]': item.amount,
          },
          for (final (i, step) in steps.indexed) 'steps[$i]': step,
        },
        files: [
          http.MultipartFile.fromBytes('image', photo.bytes,
              filename: photo.filename),
        ],
      );
    } else {
      data = await _api.post('/recipes', {
        'name': name,
        'category': category,
        'cooking_time_minutes': cookingTimeMinutes,
        'image_path': coverAsset!.replaceFirst('assets/', ''),
        'ingredients': [for (final i in ingredients) i.toJson()],
        'steps': steps,
      });
    }

    final recipe = RecipeModel.fromJson(
        (data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
    recipes.value = [recipe, ...recipes.value];
    return recipe;
  }

  /// Beri atau ubah rating (1-5). Rata-rata baru dari server langsung
  /// dipakai di semua layar.
  Future<RecipeModel> rateRecipe(String id, int score) async {
    final data = await _api.post('/recipes/$id/rating', {'score': score})
        as Map<String, dynamic>;

    final current = byId(id);
    if (current == null) {
      throw const ApiException('Resep tidak ditemukan.');
    }
    final updated = current.copyWithRating(
      rating: (data['rating'] as num).toDouble(),
      ratingCount: (data['ratingCount'] as num).toInt(),
      myRating: (data['myRating'] as num?)?.toInt() ?? score,
    );
    recipes.value = [
      for (final r in recipes.value) r.id == id ? updated : r,
    ];
    return updated;
  }

  bool isFavorite(String id) => favoriteIds.value.contains(id);

  /// Ubah status favorit. Tampilan langsung berubah; jika server gagal,
  /// dikembalikan seperti semula dan error diteruskan ke pemanggil.
  Future<void> toggleFavorite(String id) async {
    final wasFavorite = isFavorite(id);
    _setFavorite(id, !wasFavorite);
    try {
      if (wasFavorite) {
        await _api.delete('/recipes/$id/favorite');
      } else {
        await _api.post('/recipes/$id/favorite');
      }
    } on ApiException {
      _setFavorite(id, wasFavorite);
      rethrow;
    }
  }

  void _setFavorite(String id, bool value) {
    final next = {...favoriteIds.value};
    value ? next.add(id) : next.remove(id);
    favoriteIds.value = next;
  }

  List<RecipeModel> get favorites {
    final byId = {for (final r in recipes.value) r.id: r};
    return [
      for (final id in favoriteIds.value)
        if (byId[id] != null) byId[id]!,
    ];
  }

  RecipeModel? byId(String id) {
    for (final r in recipes.value) {
      if (r.id == id) return r;
    }
    return null;
  }
}
