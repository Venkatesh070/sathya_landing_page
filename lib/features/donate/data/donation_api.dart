import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sathya_landing/config/donation_config.dart';

class WebsiteDonationPublicConfig {
  const WebsiteDonationPublicConfig({
    required this.currency,
    required this.minAmount,
    required this.maxAmount,
    required this.suggestedAmounts,
    required this.recipientName,
    required this.donationPurpose,
    required this.contactEmail,
    this.contactPhone,
    required this.returnUrl,
    required this.cancelUrl,
    required this.configIncomplete,
  });

  final String currency;
  final num minAmount;
  final num maxAmount;
  final List<num> suggestedAmounts;
  final String recipientName;
  final String donationPurpose;
  final String contactEmail;
  final String? contactPhone;
  final String returnUrl;
  final String cancelUrl;
  final bool configIncomplete;

  factory WebsiteDonationPublicConfig.fromJson(Map<String, dynamic> json) {
    final suggested = (json['suggestedAmounts'] as List?)
            ?.map((e) => num.tryParse(e.toString()) ?? 0)
            .where((e) => e > 0)
            .toList() ??
        DonationConfig.suggestedAmountsZar;
    return WebsiteDonationPublicConfig(
      currency: (json['currency'] as String?)?.toUpperCase() ?? 'ZAR',
      minAmount: json['minAmount'] as num? ?? DonationConfig.minAmountZar,
      maxAmount: json['maxAmount'] as num? ?? DonationConfig.maxAmountZar,
      suggestedAmounts: suggested.isEmpty
          ? DonationConfig.suggestedAmountsZar
          : suggested,
      recipientName: (json['recipientName'] as String?)?.trim().isNotEmpty == true
          ? json['recipientName'] as String
          : DonationConfig.placeholderRecipientName,
      donationPurpose:
          (json['donationPurpose'] as String?)?.trim().isNotEmpty == true
              ? json['donationPurpose'] as String
              : DonationConfig.placeholderPurpose,
      contactEmail: (json['contactEmail'] as String?)?.trim().isNotEmpty == true
          ? json['contactEmail'] as String
          : DonationConfig.fallbackContactEmail,
      contactPhone: (json['contactPhone'] as String?)?.trim().isNotEmpty == true
          ? json['contactPhone'] as String
          : DonationConfig.fallbackContactPhone,
      returnUrl: json['returnUrl'] as String? ??
          '${DonationConfig.websiteOrigin}/#${DonationConfig.websiteDonateSuccessPath}',
      cancelUrl: json['cancelUrl'] as String? ??
          '${DonationConfig.websiteOrigin}/#${DonationConfig.websiteDonateCancelledPath}',
      configIncomplete: json['configIncomplete'] == true,
    );
  }

  static WebsiteDonationPublicConfig fallback() => WebsiteDonationPublicConfig(
        currency: 'ZAR',
        minAmount: DonationConfig.minAmountZar,
        maxAmount: DonationConfig.maxAmountZar,
        suggestedAmounts: DonationConfig.suggestedAmountsZar,
        recipientName: DonationConfig.placeholderRecipientName,
        donationPurpose: DonationConfig.placeholderPurpose,
        contactEmail: DonationConfig.fallbackContactEmail,
        contactPhone: DonationConfig.fallbackContactPhone,
        returnUrl:
            '${DonationConfig.websiteOrigin}/#${DonationConfig.websiteDonateSuccessPath}',
        cancelUrl:
            '${DonationConfig.websiteOrigin}/#${DonationConfig.websiteDonateCancelledPath}',
        configIncomplete: true,
      );
}

class WebsiteDonationInitResult {
  const WebsiteDonationInitResult({
    required this.paymentUrl,
    required this.formFields,
    required this.reference,
    required this.amount,
    required this.currency,
  });

  final String paymentUrl;
  final Map<String, String> formFields;
  final String reference;
  final num amount;
  final String currency;

  factory WebsiteDonationInitResult.fromJson(Map<String, dynamic> json) {
    final rawFields = json['formFields'];
    final fields = <String, String>{};
    if (rawFields is Map) {
      rawFields.forEach((key, value) {
        if (value == null) return;
        fields[key.toString()] = value.toString();
      });
    }
    return WebsiteDonationInitResult(
      paymentUrl: (json['paymentUrl'] ?? json['authorizationUrl'] ?? '')
          .toString(),
      formFields: fields,
      reference: (json['reference'] ?? '').toString(),
      amount: json['amount'] as num? ?? 0,
      currency: (json['currency'] as String?) ?? 'ZAR',
    );
  }
}

class DonationApiException implements Exception {
  DonationApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class DonationApi {
  DonationApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? DonationConfig.apiBaseUrl).replaceAll(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<WebsiteDonationPublicConfig> fetchConfig() async {
    final res = await _client.get(
      _uri('/api/v1/donations/website/config'),
      headers: const {'Accept': 'application/json'},
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw DonationApiException(
        'Could not load donation settings (${res.statusCode}).',
        statusCode: res.statusCode,
      );
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      return WebsiteDonationPublicConfig.fallback();
    }
    return WebsiteDonationPublicConfig.fromJson(data);
  }

  Future<WebsiteDonationInitResult> initiate({
    required num amount,
    required String email,
    String? nameFirst,
    String? nameLast,
    String? note,
    String? callbackUrl,
    String? cancelUrl,
  }) async {
    final res = await _client.post(
      _uri('/api/v1/donations/website/donate'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amount,
        'currency': 'ZAR',
        'email': email.trim(),
        if (nameFirst != null && nameFirst.trim().isNotEmpty)
          'nameFirst': nameFirst.trim(),
        if (nameLast != null && nameLast.trim().isNotEmpty)
          'nameLast': nameLast.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (callbackUrl != null) 'callbackUrl': callbackUrl,
        if (cancelUrl != null) 'cancelUrl': cancelUrl,
      }),
    );

    final body = jsonDecode(res.body.isEmpty ? '{}' : res.body)
        as Map<String, dynamic>;
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw DonationApiException(
        (body['message'] as String?)?.trim().isNotEmpty == true
            ? body['message'] as String
            : 'Could not start donation (${res.statusCode}).',
        statusCode: res.statusCode,
      );
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw DonationApiException('Unexpected donation response.');
    }
    final result = WebsiteDonationInitResult.fromJson(data);
    if (result.paymentUrl.isEmpty || result.formFields.isEmpty) {
      throw DonationApiException('Payment checkout data was incomplete.');
    }
    // Passphrase must never leave the server. merchant_key is required by
    // PayFast hosted POST checkout and is not the signing passphrase.
    if (result.formFields.containsKey('passphrase') ||
        result.formFields.keys.any((k) => k.toLowerCase().contains('passphrase'))) {
      throw DonationApiException('Unsafe payment payload rejected.');
    }
    return result;
  }
}
