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
    this.onOpenDrawer,
  });

  static const _headerBg = 'assets/images/home/landingHeaderbgImg.png';
  static const _flower = 'assets/images/home/landingFlower.png';

  final String activeNav;
  final void Function(String label) onNavLink;
  final VoidCallback onDownload;
  final VoidCallback? onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final width = MediaQuery.sizeOf(context).width;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        width: double.infinity,
        height: wide ? 104 : 76,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _headerBg,
              fit: BoxFit.fill,
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
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  left: wide ? 48 : 16,
                  right: wide ? 30 : 16,
                ),
                child: LandingHeroNavBar(
                  wide: wide,
                  activeNav: activeNav,
                  onNavLink: onNavLink,
                  onDownload: onDownload,
                  onOpenDrawer: onOpenDrawer,
                ),
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
    this.onOpenDrawer,
  });

  final bool wide;
  final String activeNav;
  final void Function(String label) onNavLink;
  final VoidCallback onDownload;
  final VoidCallback? onOpenDrawer;

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
          children: [
            Image.asset(
              'assets/images/logoWhite.png',
              height: 44,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < heroLinks.length; i++) ...[
                        if (i > 0) const SizedBox(width: 18),
                        LandingHeroNavLink(
                          label: heroLinks[i],
                          isActive: isNavActive(activeNav, heroLinks[i]),
                          onTap: () => onNavLink(heroLinks[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            LandingHeaderDonateButton(
              isActive: activeNav == 'Donate',
              onTap: () => onNavLink('Donate'),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(width: 8),
                LandingCompactStoreBadge(
                  label: 'GET IT ON',
                  store: 'Google Play',
                  leading: const LandingPlayStoreIcon(size: 20),
                  onTap: LandingNavigation.openPlayStore,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logoWhite.png', height: 38),
                const SizedBox(width: 8),
                Text(
                  'Sathya',
                  style: AppTypography.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LandingHeaderDonateButton(
                  isActive: activeNav == 'Donate',
                  compact: true,
                  onTap: () => onNavLink('Donate'),
                ),
                const SizedBox(width: 6),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
                  onPressed: onOpenDrawer ?? () => Scaffold.of(context).openEndDrawer(),
                ),
              ],
            ),
          ],
        ),
      ),
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
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.visible,
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

