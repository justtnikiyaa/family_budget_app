import 'package:flutter_test/flutter_test.dart';
import 'package:family_budget_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Simple instantiation check
    const app = MyApp();
    expect(app, isNotNull);
  });
}
