import 'package:flutter/material.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_chrome.dart';

class LandingHeroHeaderBar extends StatelessWidget {
  const LandingHeroHeaderBar({
    super.key,
    required this.activeNav,
    required this.onNavLink,
    required this.onDownload,
  });

  static const _headerBg = 'assets/images/home/landingHeaderbgImg.png';
  static const _flower = 'assets/images/home/landingFlower.png';

  final String activeNav;
  final void Function(String label) onNavLink;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        width: double.infinity,
        height: wide ? 104 : 132,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _headerBg,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            Positioned(
              top: -8,
              right: wide ? 24 : 0,
              child: Opacity(
                opacity: 0.42,
                child: Image.asset(
                  _flower,
                  width: wide ? width * 0.28 : width * 0.45,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: wide ? 48 : 28,
                right: wide ? 30 : 16,
              ),
              child: LandingHeroNavBar(
                wide: wide,
                activeNav: activeNav,
                onNavLink: onNavLink,
                onDownload: onDownload,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LandingHeroNavBar extends StatelessWidget {
  const LandingHeroNavBar({
    super.key,
    required this.wide,
    required this.activeNav,
    required this.onNavLink,
    required this.onDownload,
  });

  final bool wide;
  final String activeNav;
  final void Function(String label) onNavLink;
  final VoidCallback onDownload;

  static const heroLinks = [
    'Home',
    'About',
    'Core Features',
    'Ayurveda',
    'How the Store Works',
    'Ready to Deepen Your Practice?',
  ];

  @override
  Widget build(BuildContext context) {
    if (wide) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/logoWhite.png',
                  height: 48,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < heroLinks.length; i++) ...[
                  if (i > 0) const SizedBox(width: 22),
                  LandingHeroNavLink(
                    label: heroLinks[i],
                    isActive: isNavActive(activeNav, heroLinks[i]),
                    onTap: () => onNavLink(heroLinks[i]),
                  ),
                ],
              ],
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 10,
                  children: [
                    LandingCompactStoreBadge(
                      label: 'Download on the',
                      store: 'App Store',
                      leading: const Icon(
                        Icons.apple_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onTap: LandingNavigation.openAppStore,
                    ),
                    LandingCompactStoreBadge(
                      label: 'GET IT ON',
                      store: 'Google Play',
                      leading: const LandingPlayStoreIcon(size: 20),
                      onTap: LandingNavigation.openPlayStore,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Image.asset('assets/images/logoWhite.png', height: 40),
              const Spacer(),
              LandingCompactStoreBadge(
                label: 'GET IT ON',
                store: 'Google Play',
                leading: const LandingPlayStoreIcon(size: 20),
                onTap: LandingNavigation.openPlayStore,
              ),
            ],
          ),
        ),
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final link in heroLinks) ...[
                  LandingHeroNavLink(
                    label: link,
                    isActive: isNavActive(activeNav, link),
                    onTap: () => onNavLink(link),
                  ),
                  const SizedBox(width: 20),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static bool isNavActive(String activeNav, String link) {
    return switch (link) {
      'About' => activeNav == 'About',
      'Core Features' => activeNav == 'Core Features' || activeNav == 'Features',
      'Ayurveda' => activeNav == 'Ayurveda',
      'How the Store Works' =>
        activeNav == 'How the Store Works' || activeNav == 'How store works',
      _ => activeNav == link,
    };
  }
}

class LandingHeroNavLink extends StatelessWidget {
  const LandingHeroNavLink({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: AppTypography.inter(
            fontSize: 15,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.90),
          ),
        ),
      ),
    );
  }
}

class LandingCompactStoreBadge extends StatelessWidget {
  const LandingCompactStoreBadge({
    super.key,
    required this.label,
    required this.store,
    required this.leading,
    required this.onTap,
  });

  final String label;
  final String store;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.inter(
                      fontSize: 7,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    store,
                    style: AppTypography.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
