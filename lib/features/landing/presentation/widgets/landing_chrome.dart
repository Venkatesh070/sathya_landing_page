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
  static const _columnGap = 48.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    final fiveColumns = width >= 1000;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth
                    .clamp(0.0, _maxContentWidth)
                    .toDouble();
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: contentWidth,
                    child: fiveColumns
                        ? _fiveColumnLayout(wide: wide)
                        : wide
                            ? _twoRowLayout(wide: wide)
                            : _stackedLayout(wide: wide),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: wide ? 20 : 26),
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
                const SizedBox(height: 10),
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: LandingNavigation.openRedinWebsite,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Developed by',
                            style: AppTypography.inter(
                              fontSize: wide ? 13 : 12,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Image.asset(
                            'assets/images/Redin Consulting logo.png',
                            height: wide ? 40 : 33,
                            fit: BoxFit.contain,
                          ),
                        ],
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
        Expanded(child: _aboutSathya(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(child: _address(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(child: _contactUs(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(child: _quickLinksSection(wide: wide)),
        const SizedBox(width: _columnGap),
        Expanded(child: _downloadApp(wide: wide, stackBadges: false)),
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
            Expanded(child: _aboutSathya(wide: wide)),
            const SizedBox(width: _columnGap),
            Expanded(child: _address(wide: wide)),
            const SizedBox(width: _columnGap),
            Expanded(child: _contactUs(wide: wide)),
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

class LandingScrollToTopButton extends StatefulWidget {
  const LandingScrollToTopButton({
    super.key,
    required this.footerKey,
    required this.visible,
    required this.scrollGeneration,
    required this.onPressed,
  });

  final GlobalKey footerKey;
  final bool visible;
  final int scrollGeneration;
  final VoidCallback onPressed;

  @override
  State<LandingScrollToTopButton> createState() =>
      _LandingScrollToTopButtonState();
}

class _FooterSplitClipper extends CustomClipper<Rect> {
  const _FooterSplitClipper({required this.ratio, required this.topPortion});

  final double ratio;
  final bool topPortion;

  @override
  Rect getClip(Size size) {
    final boundary = size.height * ratio.clamp(0.0, 1.0);
    if (topPortion) {
      return Rect.fromLTRB(0, 0, size.width, boundary);
    }
    return Rect.fromLTRB(0, boundary, size.width, size.height);
  }

  @override
  bool shouldReclip(_FooterSplitClipper oldClipper) =>
      oldClipper.ratio != ratio || oldClipper.topPortion != topPortion;
}

class _LandingScrollToTopButtonState extends State<LandingScrollToTopButton> {
  final _measureKey = GlobalKey();
  bool _hovered = false;
  double _split = 1;
  bool _splitUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleSplitUpdate();
  }

  @override
  void didUpdateWidget(covariant LandingScrollToTopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollGeneration != widget.scrollGeneration ||
        oldWidget.visible != widget.visible) {
      _scheduleSplitUpdate();
    }
  }

  void _scheduleSplitUpdate() {
    if (_splitUpdateScheduled) return;
    _splitUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _splitUpdateScheduled = false;
      if (!mounted) return;
      _updateSplit();
    });
  }

  double _computeFooterSplit() {
    final footerCtx = widget.footerKey.currentContext;
    final buttonCtx = _measureKey.currentContext;
    if (footerCtx == null || buttonCtx == null) return 1;

    final footerBox = footerCtx.findRenderObject();
    final buttonBox = buttonCtx.findRenderObject();
    if (footerBox is! RenderBox ||
        buttonBox is! RenderBox ||
        !footerBox.hasSize ||
        !buttonBox.hasSize) {
      return 1;
    }

    final buttonHeight = buttonBox.size.height;
    if (buttonHeight <= 0) return 1;

    final footerTopInButton = buttonBox.globalToLocal(
      footerBox.localToGlobal(Offset.zero),
    ).dy;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final snappedBoundary = (footerTopInButton * dpr).round() / dpr;

    return (snappedBoundary / buttonHeight).clamp(0.0, 1.0);
  }

  void _updateSplit() {
    final split = _computeFooterSplit();
    if ((split - _split).abs() > 0.0001) {
      setState(() => _split = split);
    }
  }

  Widget _buttonFace({required bool onFooter}) {
    final bgColor =
        onFooter ? Colors.white : LandingColors.headerFooterBg;
    final fgColor =
        onFooter ? LandingColors.headerFooterBg : Colors.white;

    return ColoredBox(
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _hovered ? 16 : 12,
          vertical: 12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: fgColor,
              size: 30,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: Alignment.centerLeft,
              child: _hovered
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        'Scroll to top',
                        style: AppTypography.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _splitButton(double split) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ClipRect(
          clipper: _FooterSplitClipper(ratio: split, topPortion: true),
          child: _buttonFace(onFooter: false),
        ),
        ClipRect(
          clipper: _FooterSplitClipper(ratio: split, topPortion: false),
          child: _buttonFace(onFooter: true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: widget.visible ? Offset.zero : const Offset(0, 1.5),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: widget.visible ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        child: IgnorePointer(
          ignoring: !widget.visible,
          child: Padding(
            padding: const EdgeInsets.only(right: 24, bottom: 28),
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _hovered = true);
                _scheduleSplitUpdate();
              },
              onExit: (_) {
                setState(() => _hovered = false);
                _scheduleSplitUpdate();
              },
              cursor: SystemMouseCursors.click,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onPressed,
                      child: KeyedSubtree(
                        key: _measureKey,
                        child: _splitButton(_split),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
