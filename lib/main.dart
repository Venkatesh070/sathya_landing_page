import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sathya_landing/app.dart';
import 'package:sathya_landing/features/donate/data/donate_from_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Use /donate instead of /#/donate (requires SPA fallback on the web server).
  usePathUrlStrategy();
  // Persist before GetX routing can strip `?from=app` from the address bar.
  captureDonateFromAppMarkerFromUrl();
  runApp(const SathyaLandingApp());
}
