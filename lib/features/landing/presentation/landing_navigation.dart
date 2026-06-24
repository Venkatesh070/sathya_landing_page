import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

const landingPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.sathyadevotee.app';

const landingWebsiteUrl = 'https://www.sathya.co.za';

const landingPrivacyPolicyUrl = 'https://sathya-app-privacy.netlify.app/';

const landingTermsAndConditionsUrl =
    'https://sathya-terms-and-conditions.netlify.app/';

const cataloguePdfPath = '/Sri-Sri-Tattva-Sathya.pdf';

abstract final class LandingNavigation {
  static Future<void> openPlayStore() async {
    final uri = Uri.parse(landingPlayStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> openPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Future<void> openWebsite() async {
    final uri = Uri.parse(landingWebsiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openCatalogue() async {
    final uri = Uri.parse('${Uri.base.origin}$cataloguePdfPath');
    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String hashUrl(String route) {
    final path = route.startsWith('/') ? route : '/$route';
    return '${Uri.base.origin}/#$path';
  }

  static Future<void> openRouteInNewTab(String route) async {
    if (kIsWeb) {
      await launchUrl(
        Uri.parse(hashUrl(route)),
        webOnlyWindowName: '_blank',
      );
      return;
    }
    await Get.toNamed(route);
  }

  static Future<void> openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openPrivacyPolicy() =>
      openExternalUrl(landingPrivacyPolicyUrl);

  static Future<void> openTermsAndConditions() =>
      openExternalUrl(landingTermsAndConditionsUrl);

  static void openRefundPolicy() {
    if (Get.currentRoute == AppRoutes.refundPolicy) return;
    Get.toNamed(AppRoutes.refundPolicy);
  }

  static Future<void> openAdminSignIn() async {
    final uri = Uri.parse(
     'https://admin.sathya.co.za',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static void goToLanding() {
    Get.offAllNamed(AppRoutes.landing);
  }

  static void handleLink(
    String label, {
    String? currentRoute,
    void Function(String section)? onLandingSection,
  }) {
    switch (label) {
      case 'Home':
        if (onLandingSection != null) {
          onLandingSection(label);
        } else {
          goToLanding();
        }
      case 'About':
        if (onLandingSection != null) {
          onLandingSection(label);
        } else {
          goToLanding();
        }
      case 'Features':
        if (onLandingSection != null) {
          onLandingSection(label);
        } else {
          goToLanding();
        }
      case 'Contact Us':
        goToLanding();
      case 'Privacy Policy':
        openPrivacyPolicy();
      case 'Terms & Conditions':
        openTermsAndConditions();
      case 'Refund & Cancellation Policy':
        if (currentRoute != AppRoutes.refundPolicy) {
          openRefundPolicy();
        }
    }
  }
}
