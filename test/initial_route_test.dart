import 'package:flutter_test/flutter_test.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/config/routes/initial_route.dart';

void main() {
  test('resolveInitialRoute maps donate deep links on web', () {
    expect(
      resolveInitialRoute(
        uri: Uri.parse('https://www.sathya.co.za/donate?from=app'),
        isWeb: true,
      ),
      AppRoutes.donate,
    );
    expect(
      resolveInitialRoute(
        uri: Uri.parse('https://www.sathya.co.za/donate/success?from=app'),
        isWeb: true,
      ),
      AppRoutes.donateSuccess,
    );
    expect(
      resolveInitialRoute(
        uri: Uri.parse('https://www.sathya.co.za/'),
        isWeb: true,
      ),
      AppRoutes.landing,
    );
  });

  test('resolveInitialRoute stays on landing when not web', () {
    expect(
      resolveInitialRoute(
        uri: Uri.parse('https://www.sathya.co.za/donate?from=app'),
        isWeb: false,
      ),
      AppRoutes.landing,
    );
  });
}
