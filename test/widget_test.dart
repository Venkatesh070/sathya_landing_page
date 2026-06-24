import 'package:flutter_test/flutter_test.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';

void main() {
  test('landing routes are defined', () {
    expect(AppRoutes.landing, '/');
    expect(AppRoutes.privacyPolicy, isNotEmpty);
  });
}
