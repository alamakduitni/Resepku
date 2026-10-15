import 'package:flutter_test/flutter_test.dart';

import 'package:resepku/app.dart';

import 'helpers/fake_api.dart';

Future<void> _waitForSplash(WidgetTester tester) async {
  // Splash menunggu 5 detik sebelum redirect.
  await tester.pump(const Duration(seconds: 5));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Splash tampil lalu berpindah ke onboarding', (tester) async {
    setUpFakeApi(loggedIn: false);
    await tester.pumpWidget(const ResepkuApp());
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Resepku'), findsOneWidget);

    await _waitForSplash(tester);

    expect(find.text('Selanjutnya'), findsOneWidget);
  });

  testWidgets('Token tersimpan → splash langsung ke Beranda', (tester) async {
    final api =
        setUpFakeApi(loggedIn: false, prefs: {'auth_token': '1|tersimpan'});
    await tester.pumpWidget(const ResepkuApp());

    await _waitForSplash(tester);

    expect(api.requests, contains('GET /me'));
    expect(find.text('Halo, Sari 👋'), findsOneWidget);
  });
}
