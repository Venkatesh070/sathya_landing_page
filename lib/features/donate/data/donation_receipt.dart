import 'package:sathya_landing/features/donate/data/donation_receipt_stub.dart'
    if (dart.library.html)
      'package:sathya_landing/features/donate/data/donation_receipt_web.dart'
    as impl;

void savePendingDonationReceipt({
  required String amountLabel,
  required String reference,
}) =>
    impl.savePendingDonationReceipt(
      amountLabel: amountLabel,
      reference: reference,
    );

({String amountLabel, String reference})? consumePendingDonationReceipt() =>
    impl.consumePendingDonationReceipt();

({String amountLabel, String reference})? peekPendingDonationReceipt() =>
    impl.peekPendingDonationReceipt();

String formatZarAmountLabel(num amount) {
  final value = amount.toDouble();
  final fixed = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return 'R $fixed';
}

/// Prefer PayFast / deep-link query values, then the pending local receipt.
({String amountLabel, String reference}) resolveDonationReceipt({
  Map<String, String> queryParameters = const {},
  Map<String, String> getParameters = const {},
  String fragment = '',
}) {
  final params = <String, String>{
    ...getParameters,
    ...queryParameters,
  };
  final qIndex = fragment.indexOf('?');
  if (qIndex >= 0 && qIndex < fragment.length - 1) {
    params.addAll(Uri.splitQueryString(fragment.substring(qIndex + 1)));
  }

  final stored = peekPendingDonationReceipt();
  final amountRaw = params['amount'] ??
      params['amt'] ??
      params['donationAmount'] ??
      '';
  final referenceRaw = params['m_payment_id'] ??
      params['pf_payment_id'] ??
      params['reference'] ??
      params['payment_id'] ??
      '';

  String amountLabel = stored?.amountLabel ?? '';
  if (amountRaw.trim().isNotEmpty) {
    final parsed = num.tryParse(amountRaw.trim());
    amountLabel = parsed != null
        ? formatZarAmountLabel(parsed)
        : amountRaw.trim();
  }

  String reference = referenceRaw.trim().isNotEmpty
      ? referenceRaw.trim()
      : (stored?.reference ?? '');

  if (amountLabel.isEmpty) amountLabel = '—';
  if (reference.isEmpty) reference = '—';

  return (amountLabel: amountLabel, reference: reference);
}
