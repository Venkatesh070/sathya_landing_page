import 'package:flutter/material.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/landing/presentation/landing_colors.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';

class LandingNavBar extends StatelessWidget {
  const LandingNavBar({
    super.key,
    required this.active,
    required this.onHome,
    required this.onAbout,
    required this.onFeatures,
    required this.onPrivacy,
    required this.onTerms,
    required this.onRefund,
    required this.onDownload,
  });

  final String active;
  final VoidCallback onHome;
  final VoidCallback onAbout;
  final VoidCallback onFeatures;
  final VoidCallback onPrivacy;
  final VoidCallback onTerms;
  final VoidCallback onRefund;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1100;
    final links = <(String, VoidCallback)>[
      ('Home', onHome),
      ('About', onAbout),
      ('Features', onFeatures),
      ('Privacy Policy', onPrivacy),
      ('Terms & Conditions', onTerms),
      ('Refund & Cancellation Policy', onRefund),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: LandingColors.headerFooterBg,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 40 : 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Image.asset('assets/images/logoWhite.png', height: 44),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Sathya',
                      style: AppTypography.lora(
                        fontSize: wide ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (wide) ...[
                    const Spacer(),
                    for (final link in links) ...[
                      LandingNavLink(
                        label: link.$1,
                        isActive: active == link.$1,
                        onTap: link.$2,
                      ),
                      const SizedBox(width: 18),
                    ],
                  ],
                  if (!wide) const Spacer(),
                  LandingDownloadNavButton(onTap: onDownload, compact: !wide),
                ],
              ),
            ),
          ),
        ),
        if (!wide) LandingMobileNavStrip(active: active, links: links),
      ],
    );
  }
}

class LandingMobileNavStrip extends StatelessWidget {
  const LandingMobileNavStrip({
    super.key,
    required this.active,
    required this.links,
  });

  final String active;
  final List<(String, VoidCallback)> links;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LandingColors.headerFooterBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            for (final link in links) ...[
              LandingNavLink(
                label: link.$1,
                isActive: active == link.$1,
                onTap: link.$2,
              ),
              const SizedBox(width: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class LandingNavLink extends StatelessWidget {
  const LandingNavLink({
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
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ),
    );
  }
}

class LandingDownloadNavButton extends StatelessWidget {
  const LandingDownloadNavButton({
    super.key,
    required this.onTap,
    this.compact = false,
  });

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            compact ? 'Download' : 'Download App',
            style: AppTypography.inter(
              fontSize: compact ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class LandingFooter extends StatelessWidget {
  const LandingFooter({
    super.key,
    required this.onLinkTap,
  });

  final void Function(String label) onLinkTap;

  static const _quickLinks = [
    'Home',
    'Privacy Policy',
    'Terms & Conditions',
    'Refund & Cancellation Policy',
  ];

  static const _maxContentWidth = 1280.0;
  static const _columnGap = 80.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    final fiveColumns = width >= 1200;

    return Container(
      width: double.infinity,
      color: LandingColors.headerFooterBg,
      padding: EdgeInsets.only(
        top: wide ? 40 : 32,
        bottom: wide ? 20 : 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 56 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: fiveColumns
                    ? _fiveColumnLayout(wide: wide)
                    : wide
                        ? _twoRowLayout(wide: wide)
                        : _stackedLayout(wide: wide),
              ),
            ),
          ),
          SizedBox(height: wide ? 40 : 36),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: wide ? 56 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '© ${DateTime.now().year} Sathya Application. All Rights Reserved.',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    fontSize: wide ? 13 : 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: LandingNavigation.openRedinWebsite,
                      child: Image.asset(
                        'assets/images/Redin Consulting logo.jpg',
                        height: wide ? 32 : 28,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fiveColumnLayout({required bool wide}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _aboutSathya(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(flex: 2, child: _address(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(flex: 2, child: _contactUs(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(flex: 2, child: _quickLinksSection(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(flex: 3, child: _downloadApp(wide: wide, stackBadges: false)),
      ],
    );
  }

  Widget _twoRowLayout({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _aboutSathya(wide: wide)),
            const SizedBox(width: _columnGap),
            Expanded(flex: 2, child: _address(wide: wide)),
            const SizedBox(width: _columnGap),
            Expanded(flex: 2, child: _contactUs(wide: wide)),
          ],
        ),
        const SizedBox(height: 56),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _quickLinksSection(wide: wide)),
            const SizedBox(width: _columnGap),
            Expanded(child: _downloadApp(wide: wide, stackBadges: false)),
          ],
        ),
      ],
    );
  }

  Widget _stackedLayout({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _aboutSathya(wide: wide),
        const SizedBox(height: 56),
        _address(wide: wide),
        const SizedBox(height: 56),
        _contactUs(wide: wide),
        const SizedBox(height: 56),
        _quickLinksSection(wide: wide),
        const SizedBox(height: 48),
        _downloadApp(wide: wide, stackBadges: true),
      ],
    );
  }

  Widget _sectionTitle(String title, {required bool wide}) {
    return Text(
      title,
      style: AppTypography.lora(
        fontSize: wide ? 20 : 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _sectionBody(String text, {required bool wide}) {
    return Text(
      text,
      style: AppTypography.inter(
        fontSize: wide ? 14 : 13,
        height: 1.6,
        color: Colors.white70,
      ),
    );
  }

  Widget _aboutSathya({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/images/logoWhite.png', height: wide ? 44 : 40),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Sathya',
                style: AppTypography.lora(
                  fontSize: wide ? 22 : 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _sectionBody(
          'Bringing Vedic wisdom into your daily life through technology, '
          'authenticity, and devotion.',
          wide: wide,
        ),
        const SizedBox(height: 10),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: LandingNavigation.openAdminSignIn,
            child: Text(
              'Admin sign in →',
              style: AppTypography.inter(
                fontSize: wide ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _address({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Address', wide: wide),
        const SizedBox(height: 12),
        _sectionBody(
          'Pinetown,\nDurban, 3610\nSouth Africa.',
          wide: wide,
        ),
      ],
    );
  }

  Widget _contactUs({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Contact Us', wide: wide),
        const SizedBox(height: 12),
        _contactLine(
          icon: Icons.email_outlined,
          label: 'admin@ssscdt.org',
          onTap: () => LandingNavigation.openEmail('admin@ssscdt.org'),
          wide: wide,
        ),
        const SizedBox(height: 10),
        _contactLine(
          icon: Icons.phone_outlined,
          label: '084 261 4629',
          onTap: () => LandingNavigation.openPhone('+27842614629'),
          wide: wide,
        ),
        const SizedBox(height: 10),
        _contactLine(
          icon: Icons.phone_outlined,
          label: '073 268 6773',
          onTap: () => LandingNavigation.openPhone('+27732686773'),
          wide: wide,
        ),
      ],
    );
  }

  Widget _contactLine({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool wide,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTypography.inter(
                  fontSize: wide ? 14 : 13,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickLinksSection({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Quick Links', wide: wide),
        const SizedBox(height: 12),
        for (final link in _quickLinks)
          LandingFooterLink(
            label: link,
            wide: wide,
            onTap: () => onLinkTap(link),
          ),
      ],
    );
  }

  Widget _downloadApp({required bool wide, required bool stackBadges}) {
    final badges = [
      LandingStoreBadge(
        label: 'Download on the',
        store: 'App Store',
        leading: const Icon(
          Icons.apple_rounded,
          color: Colors.white,
          size: 28,
        ),
        onTap: LandingNavigation.openAppStore,
      ),
      LandingStoreBadge(
        label: 'GET IT ON',
        store: 'Google Play',
        leading: const LandingPlayStoreIcon(),
        onTap: LandingNavigation.openPlayStore,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Download App', wide: wide),
        const SizedBox(height: 12),
        if (stackBadges)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              badges[0],
              const SizedBox(height: 10),
              badges[1],
            ],
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: badges,
          ),
      ],
    );
  }
}

class LandingFooterLink extends StatelessWidget {
  const LandingFooterLink({
    super.key,
    required this.label,
    required this.wide,
    required this.onTap,
  });

  final String label;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: AppTypography.inter(
              fontSize: wide ? 14 : 13,
              height: 1.5,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class LandingPlayStoreIcon extends StatelessWidget {
  const LandingPlayStoreIcon({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      child: Image.asset(
        'assets/images/playstore_icon.png',
        height: size,
        width: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class LandingStoreBadge extends StatelessWidget {
  const LandingStoreBadge({
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.inter(
                      fontSize: 9,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    store,
                    style: AppTypography.inter(
                      fontSize: 15,
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
