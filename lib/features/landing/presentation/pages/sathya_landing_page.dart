import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/landing/presentation/landing_colors.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_animations.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_chrome.dart';

class SathyaLandingPage extends StatefulWidget {
  const SathyaLandingPage({super.key});

  @override
  State<SathyaLandingPage> createState() => _SathyaLandingPageState();
}

class _SathyaLandingPageState extends State<SathyaLandingPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final _homeKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _storeWorksKey = GlobalKey();
  final _catalogueKey = GlobalKey();
  final _ctaKey = GlobalKey();
  final _footerKey = GlobalKey();

  String _activeNav = 'Home';
  bool _showScrollToTop = false;
  int _scrollGeneration = 0;

  static const _navSections = <(String, String)>[
    ('Home', 'home'),
    ('About', 'about'),
    ('Core Features', 'features'),
    ('Ayurveda', 'ayurveda'),
    ('How the Store Works', 'store'),
    ('Ready to Deepen Your Practice?', 'cta'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateActiveSection();
      _onScroll();
      _scrollToPendingSection();
    });
  }

  void _scrollToPendingSection() {
    final args = Get.arguments;
    if (args is! Map) return;
    final section = args['section'];
    if (section is! String) return;

    void scheduleScroll([int attempt = 0]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final hasTarget = switch (section) {
          'Home' => _homeKey.currentContext != null,
          'About' || 'About Us' => _aboutKey.currentContext != null,
          'Features' || 'Core Features' => _featuresKey.currentContext != null,
          'Ayurveda' || 'Ayurveda for Better Living' =>
            _catalogueKey.currentContext != null,
          'How the Store Works' || 'How store works' =>
            _storeWorksKey.currentContext != null,
          'Ready to Deepen Your Practice?' => _ctaKey.currentContext != null,
          _ => false,
        };

        if (hasTarget) {
          _scrollToSection(section);
          return;
        }
        if (attempt < 12) {
          scheduleScroll(attempt + 1);
        }
      });
    }

    scheduleScroll();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyForSection(String id) {
    return switch (id) {
      'home' => _homeKey,
      'about' => _aboutKey,
      'features' => _featuresKey,
      'ayurveda' => _catalogueKey,
      'store' => _storeWorksKey,
      'cta' => _ctaKey,
      _ => _homeKey,
    };
  }

  double _scrollAnchor(BuildContext context) {
    return 120.0;
  }

  void _onScroll() {
    _updateActiveSection();
    if (!_scrollController.hasClients || !mounted) return;

    final show = _scrollController.offset > 320;
    if (!show) {
      if (_showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
      return;
    }

    setState(() {
      _showScrollToTop = true;
      _scrollGeneration++;
    });
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController
        .animateTo(
          0,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
      if (mounted) {
        setState(() {
          _activeNav = 'Home';
          _showScrollToTop = false;
          _scrollGeneration++;
        });
      }
    });
  }

  void _updateActiveSection() {
    if (!_scrollController.hasClients || !mounted) return;

    final anchor = _scrollAnchor(context);

    var active = _navSections.first.$1;
    for (final (label, id) in _navSections) {
      final ctx = _keyForSection(id).currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;

      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= anchor) {
        active = label;
      }
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 32) {
      active = _navSections.last.$1;
    }

    if (active != _activeNav) {
      setState(() => _activeNav = active);
    }
  }

  void _scrollTo(GlobalKey key, String label) {
    setState(() => _activeNav = label);
    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
      alignment: 0,
    ).whenComplete(_updateActiveSection);
  }

  void _scrollToSection(String label) {
    switch (label) {
      case 'Home':
        _scrollTo(_homeKey, label);
      case 'About':
      case 'About Us':
        _scrollTo(_aboutKey, 'About');
      case 'Features':
      case 'Core Features':
        _scrollTo(_featuresKey, 'Core Features');
      case 'Ayurveda':
      case 'Ayurveda for Better Living':
        _scrollTo(_catalogueKey, 'Ayurveda');
      case 'How the Store Works':
      case 'How store works':
        _scrollTo(_storeWorksKey, 'How the Store Works');
      case 'Ready to Deepen Your Practice?':
        _scrollTo(_ctaKey, label);
      case 'Donate':
        LandingNavigation.goToDonate();
    }
  }

  void _onFooterLink(String label) {
    LandingNavigation.handleLink(
      label,
      onLandingSection: _scrollToSection,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: LandingColors.sectionStoreWorks,
      endDrawer: LandingMobileDrawer(
        activeNav: _activeNav,
        onNavLink: _scrollToSection,
      ),
      body: Column(
        children: [
          LandingNavBar(
            active: _activeNav,
            onNavLink: _scrollToSection,
            onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _LandingHeroSection(
                        sectionKey: _homeKey,
                        onDownload: LandingNavigation.openPlayStore,
                      ),
                      LandingScrollReveal(
                        scrollController: _scrollController,
                        child: _AboutSection(sectionKey: _aboutKey),
                      ),
                      LandingScrollReveal(
                        scrollController: _scrollController,
                        delay: const Duration(milliseconds: 60),
                        child: _CoreFeaturesSection(
                          sectionKey: _featuresKey,
                          scrollController: _scrollController,
                        ),
                      ),
                      LandingScrollReveal(
                        scrollController: _scrollController,
                        delay: const Duration(milliseconds: 60),
                        child: _CataloguePromoSection(sectionKey: _catalogueKey),
                      ),
                      LandingScrollReveal(
                        scrollController: _scrollController,
                        delay: const Duration(milliseconds: 60),
                        child: _StoreWorksSection(
                          sectionKey: _storeWorksKey,
                          scrollController: _scrollController,
                        ),
                      ),
                      LandingScrollReveal(
                        scrollController: _scrollController,
                        delay: const Duration(milliseconds: 60),
                        child: _DownloadCtaSection(sectionKey: _ctaKey),
                      ),
                      LandingFooter(
                        key: _footerKey,
                        onLinkTap: _onFooterLink,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: LandingScrollToTopButton(
                    footerKey: _footerKey,
                    visible: _showScrollToTop,
                    scrollGeneration: _scrollGeneration,
                    onPressed: _scrollToTop,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header + Hero (mockup) ───────────────────────────────────────
class _LandingHeroSection extends StatelessWidget {
  const _LandingHeroSection({
    required this.sectionKey,
    required this.onDownload,
  });

  static const _headerBg = 'assets/images/home/landingHeaderbgImg.png';
  static const _flower = 'assets/images/home/landingFlower.png';

  final GlobalKey sectionKey;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final width = MediaQuery.sizeOf(context).width;
    final minHeroHeight = wide ? 460.0 : (width < 400 ? 380.0 : 420.0);

    return Container(
      key: sectionKey,
      width: double.infinity,
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = wide
              ? (width * 0.52).clamp(480.0, 720.0)
              : minHeroHeight;
          return SizedBox(
            height: heroHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _headerBg,
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 0.42,
                      child: Image.asset(
                        _flower,
                        width: wide ? width * 0.48 : width * 0.72,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: _heroContent(context, wide),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroContent(BuildContext context, bool wide) {
    final width = MediaQuery.sizeOf(context).width;
    final titleFontSize = wide ? 48.0 : (width < 400 ? 24.0 : 28.0);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 80 : 16,
        vertical: wide ? 24 : 12,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LandingStaggerIn(
            delay: const Duration(milliseconds: 150),
            child: Text(
              'Align Your Daily Life with Vedic Wisdom.',
              textAlign: TextAlign.center,
              style: AppTypography.lora(
                fontSize: titleFontSize,
                height: 1.18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: wide ? 20 : 12),
          LandingStaggerIn(
            delay: const Duration(milliseconds: 280),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 720 : 250),
              child: Text(
                'Bring structure, mindfulness, and authenticity to your '
                'spiritual routine with a smart ritual calendar and premium, '
                'curated Puja Kits and Ayurveda products delivered straight to your door.',
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: wide ? 16 : 13.5,
                  height: 1.6,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── About ────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.sectionKey});
  final GlobalKey sectionKey;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      key: sectionKey,
      width: double.infinity,
      color: LandingColors.sectionStoreWorks,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 56 : 20,
        vertical: wide ? 64 : 40,
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: wide ? 60 : 16),
                    child: _aboutCopy(),
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  child: LandingScaleIn(
                    delay: const Duration(milliseconds: 200),
                    child: _aboutIllustration(context),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _aboutCopy(),
                const SizedBox(height: 24),
                LandingScaleIn(
                  delay: const Duration(milliseconds: 200),
                  child: _aboutIllustration(context),
                ),
              ],
            ),
    );
  }

  Widget _aboutCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Preserving Tradition, Embracing the Present',
                style: AppTypography.lora(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: LandingColors.burgundy,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.spa_outlined, color: LandingColors.gold, size: 28),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Through Sathya, we are dedicated to preserving and sharing the timeless wisdom of Vedic traditions. Our mission is to make authentic spiritual practices accessible to everyone — combining ancient knowledge with modern technology.\n\nWe believe that spirituality should fit seamlessly into contemporary life. Whether you are performing your first ritual or deepening a lifelong practice, The Sathya App provides the tools, guidance, and community to support your journey — every single day.',
          style: AppTypography.inter(
            fontSize: 14.5,
            height: 1.6,
            color: LandingColors.textBody,
          ),
        ),
      ],
    );
  }

  Widget _aboutIllustration(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final width = MediaQuery.sizeOf(context).width;
    final h = wide ? 320.0 : (width < 400 ? 200.0 : 240.0);
    final sunSize = wide ? 220.0 : (width < 400 ? 150.0 : 180.0);
    final yogaSize = wide ? 280.0 : (width < 400 ? 180.0 : 210.0);

    return Container(
      height: h,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: sunSize,
            color: LandingColors.gold.withValues(alpha: 0.18),
          ),
          Image.asset(
            'assets/images/yoga.png',
            height: yogaSize,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// ── Core Features ────────────────────────────────────────────────
class _CoreFeaturesSection extends StatelessWidget {
  const _CoreFeaturesSection({
    required this.sectionKey,
    required this.scrollController,
  });
  final GlobalKey sectionKey;
  final ScrollController scrollController;

  static const _items = [
    (
      Icons.calendar_month_rounded,
      'Smart Vedic Calendar',
      'Never miss an auspicious date with precise tracking tailored to your routine.',
    ),
    (
      Icons.route_rounded,
      'Step-by-Step Guides',
      'Access simple, structured instructional walkthroughs for your daily prayers and multi-day rituals.',
    ),
    (
      Icons.shopping_cart_outlined,
      'Integrated Store',
      'Order verified, authentic, and premium-grade Puja Kits and Ayurveda products directly through the application.',
    ),
    (
      Icons.local_fire_department_outlined,
      'Deity Workspaces',
      'Fully immersive spaces designed to bring peace and focus to your daily meditations.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: LandingColors.sectionCoreFeatures,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            left: wide ? 12 : 0,
            child: Opacity(
              opacity: 0.07,
              child: Image.asset(
                'assets/images/home/homeHeaderFlower.png',
                width: wide ? 200 : 120,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: wide ? 12 : 0,
            child: Opacity(
              opacity: 0.07,
              child: Image.asset(
                'assets/images/home/homeHeaderFlower.png',
                width: wide ? 180 : 100,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 56 : 24,
              vertical: 64,
            ),
            child: Column(
              children: [
                _LandingGroupHeader(
                  wide: wide,
                  title: 'Core Features',
                  subtitle: 'A Modern Companion for Your Spiritual Journey',
                ),
                const SizedBox(height: 40),
                _CoreFeaturesStaggeredGrid(
                  wide: wide,
                  scrollController: scrollController,
                  items: _items,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mockup-accurate 2×2 staggered grid for Core Features.
class _CoreFeaturesStaggeredGrid extends StatelessWidget {
  const _CoreFeaturesStaggeredGrid({
    required this.wide,
    required this.scrollController,
    required this.items,
  });

  final bool wide;
  final ScrollController scrollController;
  final List<(IconData, String, String)> items;

  static const _maxGridWidth = 880.0;
  static const _cardHeight = 240.0;
  static const _columnGap = 28.0;
  static const _rowGap = 28.0;
  static const _staggerOffset = 60.0;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: _rowGap),
            _animatedCard(i),
          ],
        ],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxGridWidth),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _animatedCard(0),
                  const SizedBox(height: _rowGap),
                  _animatedCard(2),
                ],
              ),
            ),
            const SizedBox(width: _columnGap),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: _staggerOffset),
                child: Column(
                  children: [
                    _animatedCard(1),
                    const SizedBox(height: _rowGap),
                    _animatedCard(3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedCard(int index) {
    return LandingScrollReveal(
      scrollController: scrollController,
      delay: Duration(milliseconds: index * 100),
      offsetY: 32,
      child: _CoreFeatureCard(
        icon: items[index].$1,
        title: items[index].$2,
        body: items[index].$3,
        showTitleColon: index == 0,
      ),
    );
  }
}

class _CoreFeatureCard extends StatelessWidget {
  const _CoreFeatureCard({
    required this.icon,
    required this.title,
    required this.body,
    this.showTitleColon = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool showTitleColon;

  @override
  Widget build(BuildContext context) {
    final displayTitle = showTitleColon ? '$title:' : title;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final cardContent = DecoratedBox(
      decoration: BoxDecoration(
        color: LandingColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x144A2C2A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          wide ? 28 : 20,
          wide ? 30 : 20,
          wide ? 28 : 20,
          wide ? 28 : 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: wide ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: wide ? 30 : 26,
              color: LandingColors.burgundy,
            ),
            SizedBox(height: wide ? 18 : 12),
            Text(
              displayTitle,
              style: AppTypography.lora(
                fontSize: wide ? 18 : 16,
                fontWeight: FontWeight.w700,
                color: LandingColors.burgundy,
                height: 1.2,
              ),
            ),
            SizedBox(height: wide ? 12 : 8),
            if (wide)
              Expanded(
                child: Text(
                  body,
                  style: AppTypography.inter(
                    fontSize: 13,
                    height: 1.65,
                    color: LandingColors.textBody,
                  ),
                ),
              )
            else
              Text(
                body,
                style: AppTypography.inter(
                  fontSize: 13,
                  height: 1.6,
                  color: LandingColors.textBody,
                ),
              ),
          ],
        ),
      ),
    );

    if (wide) {
      return SizedBox(
        height: _CoreFeaturesStaggeredGrid._cardHeight,
        width: double.infinity,
        child: cardContent,
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 150),
      child: cardContent,
    );
  }
}

// ── How the Store Works ──────────────────────────────────────────
class _StoreWorksSection extends StatelessWidget {
  const _StoreWorksSection({
    required this.sectionKey,
    required this.scrollController,
  });
  final GlobalKey sectionKey;
  final ScrollController scrollController;

  static const _items = [
    (
      Icons.local_fire_department_outlined,
      'Select Your Ritual',
      'Browse the app for your specific prayer or upcoming auspicious day.',
    ),
    (
      Icons.shopping_cart_outlined,
      'Order Natively',
      'Purchase the matching curated kit in just a few taps.',
    ),
    (
      Icons.local_shipping_outlined,
      'Reliable Shipping',
      'Delivered safely to your door so you can focus entirely on your practice.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Container(
      key: sectionKey,
      width: double.infinity,
      color: LandingColors.sectionCoreFeatures,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 56 : 24,
        vertical: wide ? 96 : 80,
      ),
      child: Column(
        children: [
          _LandingGroupHeader(
            wide: wide,
            title: 'How the Store Works',
            subtitle: 'Authentic Puja Kits and Ayurveda products, Delivered Securely',
          ),
          SizedBox(height: wide ? 52 : 40),
          _LandingFeatureGrid(
            wide: wide,
            scrollController: scrollController,
            items: _items,
            columns: wide ? 3 : 1,
            startIndex: 4,
            cardStyle: _FeatureCardStyle.store,
          ),
        ],
      ),
    );
  }
}

class _LandingGroupHeader extends StatelessWidget {
  const _LandingGroupHeader({
    required this.wide,
    required this.title,
    required this.subtitle,
  });

  final bool wide;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.lora(
            fontSize: wide ? 32 : 26,
            fontWeight: FontWeight.w700,
            color: LandingColors.burgundy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.inter(
            fontSize: 14,
            height: 1.5,
            color: LandingColors.textBody,
          ),
        ),
      ],
    );
  }
}

class _LandingFeatureGrid extends StatelessWidget {
  const _LandingFeatureGrid({
    required this.wide,
    required this.scrollController,
    required this.items,
    required this.columns,
    required this.startIndex,
    required this.cardStyle,
  });

  final bool wide;
  final ScrollController scrollController;
  final List<(IconData, String, String)> items;
  final int columns;
  final int startIndex;
  final _FeatureCardStyle cardStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 20.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++)
              LandingScrollReveal(
                scrollController: scrollController,
                delay: Duration(milliseconds: (startIndex + i) * 90),
                offsetY: 28,
                child: SizedBox(
                  width: columns == 1 ? double.infinity : itemWidth,
                  child: _FeatureCard(
                    icon: items[i].$1,
                    title: items[i].$2,
                    body: items[i].$3,
                    style: cardStyle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _FeatureCardStyle { core, store }

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.body,
    this.style = _FeatureCardStyle.core,
  });

  final IconData icon;
  final String title;
  final String body;
  final _FeatureCardStyle style;

  @override
  Widget build(BuildContext context) {
    final isCore = style == _FeatureCardStyle.core;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isCore ? 200 : 220),
      padding: EdgeInsets.all(isCore ? 28 : 24),
      decoration: BoxDecoration(
        color: LandingColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: LandingColors.burgundy.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: LandingColors.burgundyDark.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isCore ? 48 : 44,
            height: isCore ? 48 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LandingColors.burgundyDark.withValues(alpha: 0.08),
              border: Border.all(
                color: LandingColors.gold.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              icon,
              color: LandingColors.burgundy,
              size: isCore ? 22 : 20,
            ),
          ),
          SizedBox(height: isCore ? 18 : 14),
          Text(
            title,
            style: AppTypography.lora(
              fontSize: isCore ? 17 : 16,
              fontWeight: FontWeight.w700,
              color: LandingColors.burgundy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: AppTypography.inter(
              fontSize: 13,
              height: 1.6,
              color: LandingColors.textBody,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ayurveda Catalogue ───────────────────────────────────────────
class _CataloguePromoSection extends StatelessWidget {
  const _CataloguePromoSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _promoPhotoAsset = 'assets/images/home/ayurvedicImg.png';

  static const _catalogueFeatures = <(IconData, String, String)>[
    (Icons.eco_outlined, 'Natural & Pure', '100% natural ingredients'),
    (Icons.spa_outlined, 'Traditional Wisdom', 'Rooted in ancient Ayurvedic texts'),
    (Icons.local_shipping_outlined, 'Delivered to You', 'Safe, reliable & on-time delivery'),
  ];

  static const _wellnessFeatures = <(IconData, String, String)>[
    (
      Icons.self_improvement_outlined,
      'Holistic Well-being',
      'Support your body, mind and spirit naturally.',
    ),
    (
      Icons.soup_kitchen_outlined,
      'Ayurvedic Authenticity',
      'Formulated as per classical Ayurvedic knowledge.',
    ),
    (
      Icons.volunteer_activism_outlined,
      'Better Living',
      'Small daily choices for a healthier, happier you.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      key: sectionKey,
      width: double.infinity,
      color: LandingColors.sectionStoreWorks,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 56 : 24,
        vertical: wide ? 96 : 80,
      ),
      child: Column(
        children: [
          _LandingGroupHeader(
            wide: wide,
            title: 'Ayurveda for Better Living',
            subtitle:
                'Browse our curated range of Ayurveda products — carefully sourced, scholar-verified, and delivered to your door.',
          ),
          SizedBox(height: wide ? 48 : 36),
          _mainCard(context, wide),
          SizedBox(height: wide ? 20 : 16),
          _bottomWellnessBar(wide),
        ],
      ),
    );
  }

  Widget _mainCard(BuildContext context, bool wide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(wide ? 36 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: LandingColors.ayurvedaBorder.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: LandingColors.burgundyDark.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: wide ? _wideTopRow(context, wide) : _narrowTopColumn(context, wide),
    );
  }

  Widget _wideTopRow(BuildContext context, bool wide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _promoImage(height: 380)),
        const SizedBox(width: 40),
        Expanded(flex: 6, child: _promoCopy(context, wide)),
      ],
    );
  }

  Widget _narrowTopColumn(BuildContext context, bool wide) {
    final width = MediaQuery.sizeOf(context).width;
    final imgHeight = width < 400 ? 180.0 : 220.0;
    return Column(
      children: [
        _promoImage(height: imgHeight),
        const SizedBox(height: 20),
        _promoCopy(context, wide),
      ],
    );
  }

  Widget _promoImage({required double height}) {
    return LandingScaleIn(
      delay: const Duration(milliseconds: 120),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Image.asset(
            _promoPhotoAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _promoCopy(BuildContext context, bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NATURAL WELLNESS',
          style: AppTypography.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: LandingColors.headerFooterBg,
          ).copyWith(letterSpacing: 1.4),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: Text(
                'Ayurvedic Catalogue',
                style: AppTypography.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: LandingColors.burgundy,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.eco_outlined, color: LandingColors.headerFooterBg, size: 24),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Explore our range of authentic Ayurvedic products made from natural '
          'ingredients to support your well-being and harmony — curated with the '
          'same care as our ritual kits.',
          style: AppTypography.inter(
            fontSize: 15,
            height: 1.65,
            color: LandingColors.textBody,
          ),
        ),
        const SizedBox(height: 24),
        _viewCatalogueButton(),
        const SizedBox(height: 28),
        _catalogueFeatureRow(wide),
      ],
    );
  }

  Widget _catalogueFeatureRow(bool wide) {
    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < _catalogueFeatures.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            _catalogueFeatureItem(_catalogueFeatures[i]),
          ],
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _catalogueFeatures.length; i++) ...[
            if (i > 0)
              VerticalDivider(
                width: 24,
                thickness: 1,
                color: LandingColors.ayurvedaDecor.withValues(alpha: 0.55),
              ),
            Expanded(child: _catalogueFeatureItem(_catalogueFeatures[i])),
          ],
        ],
      ),
    );
  }

  Widget _catalogueFeatureItem((IconData, String, String) feature) {
    final (icon, title, subtitle) = feature;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LandingColors.ayurvedaGreen, size: 28),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppTypography.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: LandingColors.ayurvedaGreenDark,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTypography.inter(
            fontSize: 12,
            height: 1.45,
            color: LandingColors.ayurvedaText,
          ),
        ),
      ],
    );
  }

  Widget _bottomWellnessBar(bool wide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: wide ? 32 : 20,
        vertical: wide ? 28 : 24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LandingColors.ayurvedaBorder.withValues(alpha: 0.45),
        ),
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < _wellnessFeatures.length; i++) ...[
                  if (i > 0) const SizedBox(width: 24),
                  Expanded(child: _wellnessFeatureItem(_wellnessFeatures[i])),
                ],
              ],
            )
          : Column(
              children: [
                for (var i = 0; i < _wellnessFeatures.length; i++) ...[
                  if (i > 0) const SizedBox(height: 20),
                  _wellnessFeatureItem(_wellnessFeatures[i]),
                ],
              ],
            ),
    );
  }

  Widget _wellnessFeatureItem((IconData, String, String) feature) {
    final (icon, title, subtitle) = feature;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LandingColors.ayurvedaGreen, size: 30),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LandingColors.ayurvedaGreenDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.inter(
                  fontSize: 12,
                  height: 1.45,
                  color: LandingColors.ayurvedaText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _viewCatalogueButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: LandingNavigation.openCatalogue,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: LandingColors.headerFooterBg,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: LandingColors.headerFooterBg.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Catalogue',
                style: AppTypography.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Download CTA ─────────────────────────────────────────────────
class _DownloadCtaSection extends StatelessWidget {
  const _DownloadCtaSection({required this.sectionKey});

  final GlobalKey sectionKey;

  static const _mandalaAsset = 'assets/images/home/homeHeaderFlower.png';

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      key: sectionKey,
      width: double.infinity,
      color: LandingColors.sectionStoreWorks,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: wide ? -48 : -72,
            top: wide ? 24 : 40,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(_mandalaAsset, width: wide ? 200 : 120),
            ),
          ),
          Positioned(
            right: wide ? -48 : -72,
            top: wide ? 24 : 40,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(_mandalaAsset, width: wide ? 200 : 120),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: wide ? -36 : -28,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  _mandalaAsset,
                  width: wide ? 220 : 140,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 56 : 20,
              vertical: wide ? 128 : 56,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Ready to Deepen Your Practice?',
                        textAlign: TextAlign.center,
                        style: AppTypography.lora(
                          fontSize: wide ? 36 : (width < 400 ? 24 : 28),
                          fontWeight: FontWeight.w700,
                          color: LandingColors.burgundy,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: wide ? 28 : 16),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Join our spiritual community today. Download the Sathya app '
                        'and bring authentic structure back to your daily rituals.',
                        textAlign: TextAlign.center,
                        style: AppTypography.inter(
                          fontSize: wide ? 15 : 13.5,
                          height: 1.6,
                          color: LandingColors.textBody,
                        ),
                      ),
                    ),
                    SizedBox(height: wide ? 52 : 32),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 12,
                      children: [
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
