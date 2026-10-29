import 'dart:convert';
import 'dart:html' as html;

const _storageKey = 'sathya_donate_receipt';

void savePendingDonationReceipt({
  required String amountLabel,
  required String reference,
}) {
  html.window.localStorage[_storageKey] = jsonEncode({
    'amountLabel': amountLabel,
    'reference': reference,
  });
}

({String amountLabel, String reference})? peekPendingDonationReceipt() {
  final raw = html.window.localStorage[_storageKey];
  if (raw == null || raw.isEmpty) return null;
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final amount = map['amountLabel']?.toString().trim() ?? '';
    final reference = map['reference']?.toString().trim() ?? '';
    if (amount.isEmpty && reference.isEmpty) return null;
    return (amountLabel: amount, reference: reference);
  } catch (_) {
    return null;
  }
}

({String amountLabel, String reference})? consumePendingDonationReceipt() {
  final value = peekPendingDonationReceipt();
  html.window.localStorage.remove(_storageKey);
  return value;
}
