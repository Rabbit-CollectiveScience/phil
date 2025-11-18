// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:saikum/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the welcome text is displayed.
    expect(find.text('Welcome to Your Boilerplate!'), findsOneWidget);
    expect(find.text('Start building your app here'), findsOneWidget);

    // Verify that the test button is present.
    expect(find.text('Test Button'), findsOneWidget);

    // Tap the button and trigger a frame.
    await tester.tap(find.text('Test Button'));
    await tester.pump();

    // Verify that the snackbar message appears.
    expect(find.text('Boilerplate is working!'), findsOneWidget);
  });
}
