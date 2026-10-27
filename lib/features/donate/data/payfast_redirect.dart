import 'package:flutter/foundation.dart';
import 'package:sathya_landing/features/donate/data/payfast_redirect_stub.dart'
    if (dart.library.html) 'package:sathya_landing/features/donate/data/payfast_redirect_web.dart'
    as impl;

/// Posts signed PayFast checkout fields to the hosted process URL.
Future<void> redirectToPayFast({
  required String paymentUrl,
  required Map<String, String> formFields,
}) {
  if (!kIsWeb) {
    throw UnsupportedError('PayFast redirect is only supported on Flutter web.');
  }
  return impl.redirectToPayFast(paymentUrl: paymentUrl, formFields: formFields);
}
