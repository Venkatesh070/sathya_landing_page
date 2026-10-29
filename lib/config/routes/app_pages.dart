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
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyPage(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.termsAndConditions,
      page: () => const TermsAndConditionsPage(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    // Register success/cancelled before `/donate` so GetX does not treat
    // `/donate/success` as the donate page with a leftover path segment.
    GetPage(
      name: AppRoutes.donateSuccess,
      page: () => const DonateResultPage(kind: DonateResultKind.success),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.donateCancelled,
      page: () => const DonateResultPage(kind: DonateResultKind.cancelled),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
    GetPage(
      name: AppRoutes.donate,
      page: () => const DonatePage(),
      transition: Transition.noTransition,
      transitionDuration: Duration.zero,
    ),
  ];
}
