import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/routes/app_pages.dart';
import 'package:sathya_landing/config/routes/initial_route.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';

class SathyaLandingApp extends StatelessWidget {
  const SathyaLandingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sathya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE45F0B)),
        textTheme: AppTypography.buildTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      initialRoute: resolveInitialRoute(),
      defaultTransition: Transition.noTransition,
      transitionDuration: Duration.zero,
      getPages: AppPages.routes,
    );
  }
}
