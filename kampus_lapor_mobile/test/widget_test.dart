import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_lapor_mobile/main.dart';

void main() {
  testWidgets('renders civitas login page', (tester) async {
    await tester.pumpWidget(const KampusLaporApp());

    expect(find.text('Campus Lapor'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Username / NIM'), findsOneWidget);
  });
}
