import 'package:flutter_test/flutter_test.dart';
import 'package:hisabio/main.dart';
import 'package:hisabio/screens/login_screen.dart';

void main() {
  testWidgets('MyApp loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        initialScreen: LoginScreen(),
      ),
    );

    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}