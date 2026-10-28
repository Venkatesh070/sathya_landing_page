import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

const landingPlayStoreUrl =
    'https://play.google.com/store/apps/details?id=com.satya_devotte_app';

const landingAppStoreUrl = 'https://apps.apple.com/';

const landingWebsiteUrl = 'https://www.sathya.co.za';

const landingRedinUrl = 'https://redin.co.za/';

const landingPrivacyPolicyUrl = 'https://sathya-app-privacy.netlify.app/';

const landingTermsAndConditionsUrl =
    'https://sathya-terms-and-conditions.netlify.app/';

const cataloguePdfPath = '/Sri-Sri-Tattva-Sathya.pdf';

abstract final class LandingNavigation {
  static Future<void> openPlayStore() async {
    final uri = Uri.parse(landingPlayStoreUrl);
    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> openAppStore() async {
    final uri = Uri.parse(landingAppStoreUrl);
    if (kIsWeb) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
      return;
    }
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

  static Future<void> openRedinWebsite() => openExternalUrl(landingRedinUrl);

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

  static void goToDonate() {
    if (Get.currentRoute == AppRoutes.donate) return;
    Get.toNamed(AppRoutes.donate);
  }

  static void goToLandingSection(String section) {
    Get.offAllNamed(
      AppRoutes.landing,
      arguments: {'section': section},
    );
  }

  static void _navigateToLandingSection(
    String label, {
    void Function(String section)? onLandingSection,
  }) {
    if (onLandingSection != null) {
      onLandingSection(label);
      return;
    }
    goToLandingSection(label);
  }

  static void handleLink(
    String label, {
    String? currentRoute,
    void Function(String section)? onLandingSection,
  }) {
    switch (label) {
      case 'Home':
      case 'About':
      case 'About Us':
      case 'Features':
      case 'Core Features':
      case 'Ayurveda':
      case 'Ayurveda for Better Living':
      case 'How the Store Works':
      case 'How store works':
      case 'Ready to Deepen Your Practice?':
        _navigateToLandingSection(
          label,
          onLandingSection: onLandingSection,
        );
      case 'Contact Us':
        if (onLandingSection != null) {
          onLandingSection(label);
        } else {
          goToLanding();
        }
      case 'Privacy Policy':
        openPrivacyPolicy();
      case 'Terms & Conditions':
        openTermsAndConditions();
      case 'Donate':
        goToDonate();
    }
  }
}
