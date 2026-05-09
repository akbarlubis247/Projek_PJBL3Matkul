import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_lapor_mobile/main.dart';

void main() {
  testWidgets('shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusLaporApp());

    expect(find.text('Get Start'), findsOneWidget);
    expect(find.textContaining('Campus'), findsOneWidget);
  });

  testWidgets('main buttons navigate between screens', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(const CampusLaporApp());

    await tester.tap(find.text('Get Start'));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);

    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Up'), findsOneWidget);

    expect(find.text('Nama'), findsOneWidget);
  });
}
