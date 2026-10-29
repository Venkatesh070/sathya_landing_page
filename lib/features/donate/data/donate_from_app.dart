import 'package:sathya_landing/features/donate/data/donate_from_app_stub.dart'
    if (dart.library.html)
      'package:sathya_landing/features/donate/data/donate_from_app_web.dart'
    as impl;

/// Query/session marker used when the mobile app opens the website donate flow.
const kDonateFromAppValue = 'app';
const kDonateFromAppQueryKey = 'from';

bool isDonateFromAppValue(String? raw) {
  final v = raw?.trim().toLowerCase() ?? '';
  return v == kDonateFromAppValue || v == 'mobile' || v == 'ios' || v == 'android';
}

Map<String, String> _paramsFromFragment(String fragment) {
  final qIndex = fragment.indexOf('?');
  if (qIndex < 0 || qIndex >= fragment.length - 1) return const {};
  return Uri.splitQueryString(fragment.substring(qIndex + 1));
}

/// True when URL query/fragment (or Get params) says the donor came from the app.
bool urlIndicatesDonateFromMobileApp({
  Map<String, String> queryParameters = const {},
  Map<String, String> getParameters = const {},
  String fragment = '',
}) {
  final params = <String, String>{
    ...getParameters,
    ...queryParameters,
    ..._paramsFromFragment(fragment),
  };

  return isDonateFromAppValue(params[kDonateFromAppQueryKey]) ||
      isDonateFromAppValue(params['source']);
}

/// Call as early as possible (e.g. in `main`) so a later GetX nav that drops
/// query params does not lose the mobile-app marker.
void captureDonateFromAppMarkerFromUrl({
  Uri? uri,
  Map<String, String> getParameters = const {},
}) {
  final resolved = uri ?? Uri.base;
  if (urlIndicatesDonateFromMobileApp(
    queryParameters: resolved.queryParameters,
    getParameters: getParameters,
    fragment: resolved.fragment,
  )) {
    markCameFromMobileApp();
  }
}

void markCameFromMobileApp() => impl.markCameFromMobileApp();

bool peekCameFromMobileAppFlag() => impl.peekCameFromMobileAppFlag();

bool consumeCameFromMobileAppFlag() => impl.consumeCameFromMobileAppFlag();

bool donationCameFromMobileApp({
  Map<String, String> queryParameters = const {},
  Map<String, String> getParameters = const {},
  String fragment = '',
}) {
  if (urlIndicatesDonateFromMobileApp(
    queryParameters: queryParameters,
    getParameters: getParameters,
    fragment: fragment,
  )) {
    return true;
  }
  return peekCameFromMobileAppFlag();
}

/// Appends `from=app` so PayFast return/cancel landings keep the app marker.
String appendDonateFromAppQuery(String url) {
  final uri = Uri.parse(url);
  return uri.replace(queryParameters: {
    ...uri.queryParameters,
    kDonateFromAppQueryKey: kDonateFromAppValue,
  }).toString();
}
