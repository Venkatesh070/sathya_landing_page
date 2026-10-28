import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/landing/presentation/landing_colors.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_chrome.dart';

enum DonateResultKind { success, cancelled }

class DonateResultPage extends StatelessWidget {
  const DonateResultPage({super.key, required this.kind});

  final DonateResultKind kind;

  bool get _isSuccess => kind == DonateResultKind.success;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final route = _isSuccess
        ? AppRoutes.donateSuccess
        : AppRoutes.donateCancelled;

    void onNav(String label) {
      LandingNavigation.handleLink(label, currentRoute: route);
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: LandingColors.cream,
      endDrawer: LandingMobileDrawer(
        activeNav: 'Donate',
        onNavLink: onNav,
      ),
      body: Column(
        children: [
          LandingNavBar(
            active: 'Donate',
            onHome: LandingNavigation.goToLanding,
            onAbout: () => LandingNavigation.goToLandingSection('About'),
            onFeatures: () =>
                LandingNavigation.goToLandingSection('Features'),
            onPrivacy: LandingNavigation.openPrivacyPolicy,
            onTerms: LandingNavigation.openTermsAndConditions,
            onDownload: LandingNavigation.openPlayStore,
            onDonate: LandingNavigation.goToDonate,
            onOpenDrawer: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 56 : 16,
                      vertical: wide ? 64 : 40,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isSuccess
                                ? 'Thank you'
                                : 'Payment not completed',
                            style: AppTypography.lora(
                              fontSize: wide ? 36 : 30,
                              fontWeight: FontWeight.w700,
                              color: LandingColors.burgundy,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSuccess
                                ? 'If you completed checkout on PayFast, your '
                                    'donation is being confirmed by our servers. '
                                    'This page alone is not proof of payment — '
                                    'please wait for PayFast’s confirmation email '
                                    'or contact us if you need a receipt.'
                                : 'Your PayFast checkout was cancelled or did '
                                    'not complete. No donation has been recorded '
                                    'as paid.',
                            style: AppTypography.inter(
                              fontSize: 16,
                              height: 1.55,
                              color: LandingColors.textBody,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              FilledButton(
                                onPressed: () =>
                                    Get.offAllNamed(AppRoutes.donate),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      LandingColors.headerFooterBg,
                                ),
                                child: Text(
                                  _isSuccess
                                      ? 'Make another donation'
                                      : 'Try again',
                                ),
                              ),
                              OutlinedButton(
                                onPressed: LandingNavigation.goToLanding,
                                child: const Text('Back to home'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  LandingFooter(onLinkTap: onNav),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
