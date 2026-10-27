import 'package:flutter/material.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/landing/presentation/landing_colors.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_chrome.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_hero_header.dart';

class PolicySection {
  const PolicySection({required this.title, required this.body});

  final String title;
  final String body;
}

class LandingPolicyPage extends StatelessWidget {
  const LandingPolicyPage({
    super.key,
    required this.title,
    required this.activeNav,
    required this.route,
    this.body,
    this.sections,
    this.useHeroHeader = false,
  }) : assert(body != null || sections != null);

  final String title;
  final String activeNav;
  final String route;
  final String? body;
  final List<PolicySection>? sections;
  final bool useHeroHeader;

  void _onLink(String label) {
    LandingNavigation.handleLink(label, currentRoute: route);
  }

  void _onHeroNavLink(String label) {
    LandingNavigation.handleLink(label, currentRoute: route);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: LandingColors.cream,
      endDrawer: LandingMobileDrawer(
        activeNav: activeNav,
        onNavLink: _onLink,
      ),
      body: Column(
        children: [
          if (useHeroHeader)
            LandingHeroHeaderBar(
              activeNav: 'Home',
              onNavLink: _onHeroNavLink,
              onDownload: LandingNavigation.openPlayStore,
              onOpenDrawer: () => scaffoldKey.currentState?.openEndDrawer(),
            )
          else
            LandingNavBar(
              active: activeNav,
              onHome: LandingNavigation.goToLanding,
              onAbout: LandingNavigation.goToLanding,
              onFeatures: LandingNavigation.goToLanding,
              onPrivacy: LandingNavigation.openPrivacyPolicy,
              onTerms: LandingNavigation.openTermsAndConditions,
              onDownload: LandingNavigation.openPlayStore,
              onOpenDrawer: () => scaffoldKey.currentState?.openEndDrawer(),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 56 : 16,
                      vertical: wide ? 32 : 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.lora(
                                fontSize: wide ? 32 : 24,
                                fontWeight: FontWeight.w700,
                                color: LandingColors.burgundy,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(wide ? 28 : 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: LandingColors.gold.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: sections != null
                                  ? _PolicySectionsContent(sections: sections!)
                                  : Text(
                                      body!,
                                      style: AppTypography.inter(
                                        fontSize: 14,
                                        height: 1.65,
                                        color: LandingColors.textBody,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  LandingFooter(
                    onLinkTap: _onLink,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySectionsContent extends StatelessWidget {
  const _PolicySectionsContent({required this.sections});

  final List<PolicySection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 24),
          Text(
            sections[i].title,
            style: AppTypography.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: LandingColors.burgundy,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            sections[i].body,
            style: AppTypography.inter(
              fontSize: 14,
              height: 1.65,
              color: LandingColors.textBody,
            ),
          ),
        ],
      ],
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingPolicyPage(
      title: 'Privacy Policy',
      activeNav: 'Privacy Policy',
      route: AppRoutes.privacyPolicy,
      body:
          'This page will contain the full Sathya Application privacy policy. '
          'Contact support@sathya.co.za if you have questions about how we '
          'collect, use, and protect your personal information.',
    );
  }
}

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingPolicyPage(
      title: 'Terms & Conditions',
      activeNav: 'Terms & Conditions',
      route: AppRoutes.termsAndConditions,
      body:
          'This page will contain the full Sathya Application terms and '
          'conditions. Contact support@sathya.co.za if you have questions about '
          'our terms of use.',
    );
  }
}
