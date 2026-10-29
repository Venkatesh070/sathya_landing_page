import 'package:flutter/foundation.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';

/// Prefer the browser path on web so `/donate` and `/donate/success` deep links
/// work. GetMaterialApp's hardcoded `initialRoute: '/'` would otherwise always
/// boot the landing page and drop the inbound query (e.g. `from=app`).
String resolveInitialRoute({Uri? uri, bool? isWeb}) {
  if (!(isWeb ?? kIsWeb)) return AppRoutes.landing;

  final resolved = uri ?? Uri.base;
  var path = resolved.path;
  if (path.isEmpty || path == '/') return AppRoutes.landing;
  if (path.length > 1 && path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }

  const known = <String>{
    AppRoutes.landing,
    AppRoutes.privacyPolicy,
    AppRoutes.termsAndConditions,
    AppRoutes.donate,
    AppRoutes.donateSuccess,
    AppRoutes.donateCancelled,
  };
  if (known.contains(path)) return path;
  return AppRoutes.landing;
}
