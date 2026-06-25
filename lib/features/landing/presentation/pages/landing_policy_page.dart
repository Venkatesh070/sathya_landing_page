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

const refundAndCancellationPolicySections = <PolicySection>[
  PolicySection(
    title: 'Order Cancellations',
    body:
        'Pre-Dispatch: A customer may request an order cancellation at any time '
        'prior to the package being dispatched to our logistics partner, The '
        'Courier Guy. If successfully cancelled before dispatch, a full refund '
        'will be processed.\n\n'
        'Post-Dispatch: Once an order has been picked up by the courier and a '
        'waybill is generated, it can no longer be cancelled. The user must '
        'follow the standard returns/replacements inquiry process upon arrival.',
  ),
  PolicySection(
    title: 'Refund and Replacement Requests',
    body:
        'Administrative Review: All requests for refunds, cancellations, or '
        'product replacements must be logged through the application or via our '
        'official support channels.\n\n'
        'Every request is subject to a manual internal verification process by '
        'our administrative team. We review requests appropriately based on kit '
        'completeness, damage during transit, or operational errors.\n\n'
        'Approved refunds will be credited back via our payment gateway '
        '(Paystack) to the original payment method used during checkout.\n\n'
        'Users are required to report damaged, defective, missing, or incorrect '
        'products within 48 hours of delivery along with relevant photographs '
        'or supporting details where applicable.\n\n'
        'Returned products, where applicable, must be unused and returned in '
        'their original packaging.',
  ),
  PolicySection(
    title: 'Non-Refundable Transactions',
    body:
        'Contributions made through the Platform are voluntary and generally '
        'non-refundable.',
  ),
  PolicySection(
    title: 'Refund Processing Timeline',
    body:
        'Approved refunds will be processed through the payment gateway provider '
        '(Paystack) and credited to the original payment method used during '
        'checkout.\n\n'
        'Refund processing timelines may vary depending on the payment provider '
        'or banking institution and may take approximately 7–14 business days to '
        'reflect in the User’s account.',
  ),
  PolicySection(
    title: 'Right to Reject Requests',
    body:
        'The Company reserves the right to reject refund, return, replacement, or '
        'cancellation requests that do not comply with the conditions outlined in '
        'this Policy or where misuse, abuse, or fraudulent activity is suspected.',
  ),
];

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
    return Scaffold(
      backgroundColor: LandingColors.cream,
      body: Column(
        children: [
          if (useHeroHeader)
            LandingHeroHeaderBar(
              activeNav: 'Home',
              onNavLink: _onHeroNavLink,
              onDownload: LandingNavigation.openPlayStore,
            )
          else
            LandingNavBar(
              active: activeNav,
              onHome: LandingNavigation.goToLanding,
              onAbout: LandingNavigation.goToLanding,
              onFeatures: LandingNavigation.goToLanding,
              onPrivacy: LandingNavigation.openPrivacyPolicy,
              onTerms: LandingNavigation.openTermsAndConditions,
              onRefund: LandingNavigation.openRefundPolicy,
              onDownload: LandingNavigation.openPlayStore,
            ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 56 : 24,
                      vertical: 32,
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
                                fontSize: wide ? 32 : 26,
                                fontWeight: FontWeight.w700,
                                color: LandingColors.burgundy,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
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
      title: 'Refund and Cancellation Policy',
      activeNav: 'Terms & Conditions',
      route: AppRoutes.termsAndConditions,
      sections: refundAndCancellationPolicySections,
    );
  }
}

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingPolicyPage(
      title: 'Refund and Cancellation Policy',
      activeNav: 'Refund & Cancellation Policy',
      route: AppRoutes.refundPolicy,
      sections: refundAndCancellationPolicySections,
      useHeroHeader: true,
    );
  }
}
