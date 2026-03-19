import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:tech_gadol_test_app/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MyApp(prefs: prefs));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Catalog'), findsWidgets);
    });
  });
}