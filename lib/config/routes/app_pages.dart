import 'package:get/get.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/features/donate/presentation/pages/donate_page.dart';
import 'package:sathya_landing/features/donate/presentation/pages/donate_result_page.dart';
import 'package:sathya_landing/features/landing/presentation/pages/landing_policy_page.dart';
import 'package:sathya_landing/features/landing/presentation/pages/sathya_landing_page.dart';

abstract final class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.landing,
      page: () => const SathyaLandingPage(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
    ),
    GetPage(
      name: AppRoutes.termsAndConditions,
      page: () => const TermsAndConditionsPage(),
    ),
    GetPage(
      name: AppRoutes.donate,
      page: () => const DonatePage(),
    ),
    GetPage(
      name: AppRoutes.donateSuccess,
      page: () => const DonateResultPage(kind: DonateResultKind.success),
    ),
    GetPage(
      name: AppRoutes.donateCancelled,
      page: () => const DonateResultPage(kind: DonateResultKind.cancelled),
    ),
  ];
}
