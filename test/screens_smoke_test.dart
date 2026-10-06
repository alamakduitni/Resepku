import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resepku/core/theme/app_theme.dart';
import 'package:resepku/data/models/recipe_model.dart';
import 'package:resepku/data/stores/recipe_store.dart';
import 'package:resepku/data/stores/user_store.dart';
import 'package:resepku/routes/app_routes.dart';

import 'helpers/fake_api.dart';

Future<void> _pumpRoute(
  WidgetTester tester,
  String route, {
  Object? arguments,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(MaterialApp(
    navigatorKey: navKey,
    theme: AppTheme.darkTheme,
    onGenerateRoute: AppRoutes.generateRoute,
    initialRoute: AppRoutes.login,
  ));
  await tester.pump();
  navKey.currentState!.pushNamed(route, arguments: arguments);
  // Beri waktu untuk muat JSON, transisi halaman, dan animasi masuk.
  for (var i = 0; i < 12; i++) {
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _centerOn(WidgetTester tester, Finder finder) async {
  // Gulir ke tengah layar agar tidak tertutup AppBar/bottom bar.
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _centerOn(tester, finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _typeVisible(
    WidgetTester tester, Finder finder, String text) async {
  await _centerOn(tester, finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.enterText(finder, text);
}

void main() {
  late FakeApi api;

  setUp(() {
    // Cache asset & store dibagi antar tes; reset agar tiap tes mandiri.
    rootBundle.clear();
    api = setUpFakeApi();
  });

  const sizes = {
    'hp': Size(360, 740),
    'tablet': Size(820, 1180),
    'desktop': Size(1400, 900),
  };

  for (final entry in sizes.entries) {
    for (final route in [
      AppRoutes.onboarding,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.home,
      AppRoutes.search,
      AppRoutes.favorite,
      AppRoutes.profile,
      AppRoutes.addRecipe,
    ]) {
      testWidgets('$route tampil tanpa error (${entry.key})', (tester) async {
        await _pumpRoute(tester, route, size: entry.value);
      });
    }

    testWidgets('detail tampil tanpa error (${entry.key})', (tester) async {
      final raw = File('lib/data/dummy/dummy_recipes.json').readAsStringSync();
      final recipe = RecipeModel.fromJson(
          (json.decode(raw) as List).first as Map<String, dynamic>);
      await _pumpRoute(tester, AppRoutes.detail,
          arguments: recipe, size: entry.value);
      expect(find.text(recipe.name), findsWidgets);
    });
  }

  testWidgets('Tambah resep: validasi lalu simpan', (tester) async {
    await _pumpRoute(tester, AppRoutes.addRecipe);
    final before = RecipeStore.instance.recipes.value.length;

    // Simpan saat kosong â†’ muncul pesan error.
    await tester.tap(find.text('Simpan Resep'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Pilih salah satu foto sampul'), findsOneWidget);
    expect(find.text('Nama resep wajib diisi'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // tutup toast

    // Isi form.
    final semantics = tester.ensureSemantics();
    await _tapVisible(tester, find.bySemanticsLabel('Foto sampul 1'));
    semantics.dispose();
    await _typeVisible(
        tester,
        find.widgetWithText(TextFormField, 'Contoh: Soto Ayam Lamongan'),
        'Soto Ayam');
    await _tapVisible(tester, find.text('Olahan Ayam'));
    await _typeVisible(
        tester, find.widgetWithText(TextFormField, 'Nama bahan'), 'Ayam');
    await _typeVisible(
        tester, find.widgetWithText(TextFormField, 'Takaran'), '500 gram');
    await _typeVisible(
        tester,
        find.widgetWithText(TextFormField, 'Jelaskan langkah 1...'),
        'Rebus ayam hingga empuk');
    await tester.pump();

    // Tambah & hapus baris bahan.
    await _tapVisible(tester, find.text('Tambah Bahan'));
    expect(find.widgetWithText(TextFormField, 'Nama bahan'), findsNWidgets(2));
    await _tapVisible(tester, find.byTooltip('Hapus bahan 2'));
    expect(find.widgetWithText(TextFormField, 'Nama bahan'), findsOneWidget);

    expect(find.text('100%'), findsOneWidget);

    await tester.tap(find.text('Simpan Resep'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Resep berhasil disimpan!'), findsOneWidget);
    expect(api.requests, contains('POST /recipes'));
    expect(RecipeStore.instance.recipes.value.length, before + 1);
    expect(RecipeStore.instance.recipes.value.first.name, 'Soto Ayam');
  });

  testWidgets('Tambah resep dengan foto dari galeri', (tester) async {
    setUpFakeGallery();
    await _pumpRoute(tester, AppRoutes.addRecipe);

    final semantics = tester.ensureSemantics();
    await _tapVisible(tester, find.bySemanticsLabel('Pilih dari galeri'));
    await tester.pump(const Duration(milliseconds: 300));
    // Setelah memilih, ubin galeri berubah jadi tombol ganti foto.
    expect(find.bySemanticsLabel('Ganti foto dari galeri'), findsOneWidget);
    semantics.dispose();

    await _typeVisible(
        tester,
        find.widgetWithText(TextFormField, 'Contoh: Soto Ayam Lamongan'),
        'Es Teh Galeri');
    await _tapVisible(tester, find.text('Minuman'));
    await _typeVisible(
        tester, find.widgetWithText(TextFormField, 'Nama bahan'), 'Teh');
    await _typeVisible(
        tester, find.widgetWithText(TextFormField, 'Takaran'), '2 kantong');
    await _typeVisible(
        tester,
        find.widgetWithText(TextFormField, 'Jelaskan langkah 1...'),
        'Seduh teh dengan air panas');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // animasi progres
    expect(find.text('100%'), findsOneWidget);

    await tester.tap(find.text('Simpan Resep'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Resep berhasil disimpan!'), findsOneWidget);
    expect(api.multipartFields['name'], 'Es Teh Galeri');
    expect(api.multipartFields['category'], 'Minuman');
    expect(api.multipartFields['ingredients[0][amount]'], '2 kantong');
    expect(api.multipartFields['steps[0]'], 'Seduh teh dengan air panas');
    // Nama file tidak boleh kosong; PHP mengabaikan file tanpa nama.
    expect(api.multipartFields['image'], matches(r'^file:[^:]+\.jpg:\d+$'));
    expect(api.multipartFields.containsKey('image_path'), isFalse);
    expect(RecipeStore.instance.recipes.value.first.image,
        contains('/storage/recipes/'));
  });

  Future<RecipeModel> openDetailForRating(WidgetTester tester) async {
    await tester.runAsync(() => RecipeStore.instance.ensureLoaded());
    final recipe = RecipeStore.instance.byId('recipe_003')!;
    await _pumpRoute(tester, AppRoutes.detail, arguments: recipe);
    await _centerOn(tester, find.text('Beri Rating'));
    await tester.pump(const Duration(milliseconds: 300));
    return recipe;
  }

  testWidgets('Beri rating dari halaman detail', (tester) async {
    final recipe = await openDetailForRating(tester);
    expect(recipe.myRating, isNull);

    await tester.tap(find.byTooltip('Enak banget'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.ratings['recipe_003'], 4);
    final updated = RecipeStore.instance.byId('recipe_003')!;
    expect(updated.myRating, 4);
    expect(updated.ratingCount, 6);
    expect(find.text('Terima kasih atas ratingnya!'), findsOneWidget);
    expect(find.textContaining('Rating kamu: Enak banget'), findsOneWidget);
    expect(find.text('(6)'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // tutup toast
  });

  testWidgets('Rating dikembalikan jika server gagal', (tester) async {
    await openDetailForRating(tester);
    api.failWith = 500;

    await tester.tap(find.byTooltip('Juara!'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(RecipeStore.instance.byId('recipe_003')!.myRating, isNull);
    expect(find.text('Server error'), findsOneWidget);
    expect(find.textContaining('Sudah mencoba resep ini?'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // tutup toast
  });

  testWidgets('Favorit bisa di-toggle dari kartu', (tester) async {
    await _pumpRoute(tester, AppRoutes.home);
    final store = RecipeStore.instance;
    final initial = store.favoriteIds.value.length;

    await _tapVisible(tester, find.byTooltip('Simpan ke favorit').first);
    expect(store.favoriteIds.value.length, initial + 1);
    expect(api.requests.last, endsWith('/favorite'));
    expect(api.favorites.length, initial + 1);
  });

  testWidgets('Favorit dikembalikan jika server gagal', (tester) async {
    await _pumpRoute(tester, AppRoutes.home);
    final store = RecipeStore.instance;
    final initial = {...store.favoriteIds.value};

    api.failWith = 500;
    await _tapVisible(tester, find.byTooltip('Simpan ke favorit').first);
    await tester.pump(const Duration(milliseconds: 100));

    expect(store.favoriteIds.value, initial);
    expect(find.text('Server error'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // tutup toast
  });

  testWidgets('Login berhasil menyimpan sesi lalu ke Beranda', (tester) async {
    setUpFakeApi(loggedIn: false);
    await _pumpRoute(tester, AppRoutes.login);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'nama@email.com').last,
        'sari.wulandari@email.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Minimal 6 karakter').last,
        'password');
    await tester.tap(find.text('Masuk').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(UserStore.instance.user.value?.name, 'Sari Wulandari');
    expect(find.text('Halo, Sari 👋'), findsOneWidget);
  });

  testWidgets('Login gagal menampilkan pesan dari server', (tester) async {
    setUpFakeApi(loggedIn: false);
    await _pumpRoute(tester, AppRoutes.login);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'nama@email.com').last,
        'sari.wulandari@email.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Minimal 6 karakter').last,
        'salah123');
    await tester.tap(find.text('Masuk').last);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
    expect(UserStore.instance.user.value, isNull);
    await tester.pump(const Duration(seconds: 4)); // tutup toast
  });
}
