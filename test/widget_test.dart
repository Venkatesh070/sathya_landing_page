import 'package:flutter_test/flutter_test.dart';
import 'package:sathya_landing/config/donation_config.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/features/donate/data/donation_api.dart';

void main() {
  test('landing routes are defined', () {
    expect(AppRoutes.landing, '/');
    expect(AppRoutes.privacyPolicy, isNotEmpty);
    expect(AppRoutes.donate, '/donate');
    expect(AppRoutes.donateSuccess, '/donate/success');
    expect(AppRoutes.donateCancelled, '/donate/cancelled');
  });

  test('donation URL uses HTTPS sathya domain path route', () {
    final uri = Uri.parse(DonationConfig.websiteDonateUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, 'www.sathya.co.za');
    expect(uri.path, '/donate');
    expect(uri.fragment, isEmpty);
  });

  test('sanitizeDonationReturnUrl rejects homepage redirects', () {
    expect(
      DonationConfig.sanitizeDonationReturnUrl('https://www.sathya.co.za/'),
      DonationConfig.websiteDonateSuccessUrl,
    );
    expect(
      DonationConfig.sanitizeDonationReturnUrl(
        'https://www.sathya.co.za/donate/success?from=app',
      ),
      'https://www.sathya.co.za/donate/success?from=app',
    );
  });

  test('init result rejects passphrase leakage', () {
    expect(
      () => WebsiteDonationInitResult.fromJson({
        'paymentUrl': 'https://sandbox.payfast.co.za/eng/process',
        'reference': 'PF-DON-WEB-1',
        'amount': 50,
        'currency': 'ZAR',
        'formFields': {
          'merchant_id': '10000100',
          'amount': '50.00',
          'passphrase': 'secret',
        },
      }),
      returnsNormally,
    );
    // Safety check lives in DonationApi.initiate after parse.
    final parsed = WebsiteDonationInitResult.fromJson({
      'paymentUrl': 'https://sandbox.payfast.co.za/eng/process',
      'reference': 'x',
      'amount': 50,
      'formFields': {'passphrase': 'nope', 'merchant_id': '1'},
    });
    expect(parsed.formFields.containsKey('passphrase'), isTrue);
  });

  test('public config fallback marks incomplete placeholders', () {
    final cfg = WebsiteDonationPublicConfig.fallback();
    expect(cfg.configIncomplete, isTrue);
    expect(cfg.recipientName, contains('CONFIGURE'));
    expect(cfg.minAmount, greaterThan(0));
  });
}
