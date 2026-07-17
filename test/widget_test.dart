import 'package:flutter_test/flutter_test.dart';

import 'package:devdar_laundry_pos_app/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DevdaraApp());
    await tester.pump();

    // The app should render the login page (since no user is authenticated)
    expect(find.text('Devdara Laundry'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
