/// Website donation configuration.
///
/// Recipient legal details should come from the backend
/// `GET /api/v1/donations/website/config` when configured. Local fallbacks are
/// clearly marked placeholders — replace before release.
abstract final class DonationConfig {
  /// Override with `--dart-define=API_BASE_URL=https://api-test.sathya.co.za`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.sathya.co.za',
  );

  static const String websiteOrigin = 'https://www.sathya.co.za';

  static const List<int> suggestedAmountsZar = [50, 100, 250, 500];
  static const double minAmountZar = 10;
  static const double maxAmountZar = 1000000;

  /// Placeholder until DONATION_RECIPIENT_NAME is set on the server / release.
  static const String placeholderRecipientName =
      '[CONFIGURE: legal / trading name of the donation recipient]';

  static const String placeholderPurpose =
      '[CONFIGURE: short description of how donations are used]';

  /// Existing public contact on the landing footer — used only as a contact
  /// fallback, not as a verified legal recipient name.
  static const String fallbackContactEmail = 'admin@ssscdt.org';
  static const String fallbackContactPhone = '084 261 4629';

  static String get websiteDonatePath => '/donate';
  static String get websiteDonateSuccessPath => '/donate/success';
  static String get websiteDonateCancelledPath => '/donate/cancelled';

  static String get websiteDonateUrl => '$websiteOrigin/#$websiteDonatePath';
}
