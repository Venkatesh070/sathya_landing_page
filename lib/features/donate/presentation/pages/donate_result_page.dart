import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/donate/data/donate_from_app.dart';
import 'package:sathya_landing/features/donate/data/donation_receipt.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_chrome.dart';

enum DonateResultKind { success, cancelled }

class DonateResultPage extends StatefulWidget {
  const DonateResultPage({super.key, required this.kind});

  final DonateResultKind kind;

  @override
  State<DonateResultPage> createState() => _DonateResultPageState();
}

class _DonateResultPageState extends State<DonateResultPage> {
  static const _orange = Color(0xFFE45F0B);
  static const _ink = Color(0xFF2A1608);
  static const _muted = Color(0xFF6B7280);
  static const _successGreen = Color(0xFF2E9B57);
  static const _cream = Color(0xFFFAF3E8);

  bool get _isSuccess => widget.kind == DonateResultKind.success;
  bool _fromMobileApp = false;
  bool _dialogShown = false;
  late final String _amountLabel;
  late final String _reference;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onNav(String label) {
    LandingNavigation.handleLink(
      label,
      currentRoute:
          _isSuccess ? AppRoutes.donateSuccess : AppRoutes.donateCancelled,
    );
  }

  @override
  void initState() {
    super.initState();
    _fromMobileApp = donationCameFromMobileApp(
      queryParameters: Uri.base.queryParameters,
      getParameters: Map<String, String>.from(
        Get.parameters.map((k, v) => MapEntry(k, v.toString())),
      ),
      fragment: Uri.base.fragment,
    );

    final receipt = resolveDonationReceipt(
      queryParameters: Uri.base.queryParameters,
      getParameters: Map<String, String>.from(
        Get.parameters.map((k, v) => MapEntry(k, v.toString())),
      ),
      fragment: Uri.base.fragment,
    );
    _amountLabel = receipt.amountLabel;
    _reference = receipt.reference;
    if (_isSuccess) {
      consumePendingDonationReceipt();
    }

    if (_isSuccess && _fromMobileApp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeShowReturnToAppDialog();
      });
    }
  }

  Future<void> _maybeShowReturnToAppDialog() async {
    if (!mounted || _dialogShown || !_fromMobileApp) return;
    _dialogShown = true;
    consumeCameFromMobileAppFlag();

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _successGreen.withValues(alpha: 0.12),
                        border: Border.all(
                          color: _successGreen.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: _successGreen,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Thank you for your donation',
                      textAlign: TextAlign.center,
                      style: AppTypography.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please return to the App to continue.',
                      textAlign: TextAlign.center,
                      style: AppTypography.inter(
                        fontSize: 15,
                        height: 1.5,
                        color: _muted,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'OK',
                          style: AppTypography.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 980;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _cream,
      endDrawer: LandingMobileDrawer(
        activeNav: 'Donate',
        onNavLink: _onNav,
      ),
      body: Column(
        children: [
          LandingNavBar(
            active: 'Donate',
            onNavLink: _onNav,
            onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _ResultHeroBanner(wide: wide),
                  Transform.translate(
                    offset: Offset(0, wide ? -56 : -16),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 64 : 16,
                        0,
                        wide ? 64 : 16,
                        0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1080),
                          child: _isSuccess
                              ? _SuccessCard(
                                  wide: wide,
                                  amountLabel: _amountLabel,
                                  reference: _reference,
                                  fromMobileApp: _fromMobileApp,
                                  onHome: LandingNavigation.goToLanding,
                                )
                              : _CancelledCard(
                                  wide: wide,
                                  onTryAgain: LandingNavigation.goToDonate,
                                  onHome: LandingNavigation.goToLanding,
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: wide ? 48 : 32),
                  LandingFooter(onLinkTap: _onNav),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeroBanner extends StatelessWidget {
  const _ResultHeroBanner({required this.wide});

  final bool wide;
  static const _orange = Color(0xFFE45F0B);
  static const _flower = 'assets/images/home/landingFlower.png';

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _TempleCanopyClipper(),
      child: ColoredBox(
        color: _orange,
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: wide ? -260 : -160,
                top: wide ? -30 : -20,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.42,
                    child: Image.asset(
                      _flower,
                      width: wide ? 740 : 460,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  wide ? 64 : 22,
                  wide ? 48 : 32,
                  wide ? 64 : 22,
                  wide ? 120 : 92,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 660 : 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support a More Meaningful Spiritual Journey',
                          style: AppTypography.lora(
                            fontSize: wide ? 44 : 28,
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: wide ? 16 : 12),
                        Text(
                          'Your support helps Sathya share the timeless wisdom of '
                          'the Vedas and support our growing community.',
                          style: AppTypography.inter(
                            fontSize: wide ? 16 : 14,
                            height: 1.55,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TempleCanopyClipper extends CustomClipper<Path> {
  const _TempleCanopyClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    const dropHeight = 36.0;
    final topEdge = size.height - dropHeight;
    final shelfWidth = (size.width * 0.08).clamp(28.0, 90.0);
    const curveWidth = 42.0;

    path.lineTo(0, topEdge);
    path.lineTo(shelfWidth, topEdge);
    path.cubicTo(
      shelfWidth + curveWidth * 0.45,
      topEdge,
      shelfWidth + curveWidth * 0.55,
      size.height,
      shelfWidth + curveWidth,
      size.height,
    );

    final rightShelf = size.width - shelfWidth;
    path.lineTo(rightShelf - curveWidth, size.height);
    path.cubicTo(
      rightShelf - curveWidth * 0.55,
      size.height,
      rightShelf - curveWidth * 0.45,
      topEdge,
      rightShelf,
      topEdge,
    );

    path.lineTo(size.width, topEdge);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.wide,
    required this.amountLabel,
    required this.reference,
    required this.fromMobileApp,
    required this.onHome,
  });

  final bool wide;
  final String amountLabel;
  final String reference;
  final bool fromMobileApp;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final details = _DetailsPanel(
      amountLabel: amountLabel,
      reference: reference,
      fromMobileApp: fromMobileApp,
      onHome: onHome,
    );

    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  flex: 48,
                  child: AspectRatio(
                    aspectRatio: 0.9,
                    child: _StoryPanel(),
                  ),
                ),
                Expanded(flex: 52, child: details),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: _StoryPanel(),
                ),
                details,
              ],
            ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel();

  static const _ink = Color(0xFF2A1608);
  static const _body = Color(0xFF3B2412);
  static const _flowerAsset = 'assets/images/donateFlowerImg.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            _flowerAsset,
            fit: BoxFit.cover,
            alignment: const Alignment(-0.85, 0.05),
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0.72),
                ],
                stops: const [0.2, 0.55, 1],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _LotusDivider(),
                  const SizedBox(height: 14),
                  Text(
                    'Your generosity makes a difference',
                    textAlign: TextAlign.center,
                    style: AppTypography.lora(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Thank you for supporting Sathya and helping us share '
                    'Vedic wisdom and spiritual guidance.',
                    textAlign: TextAlign.center,
                    style: AppTypography.inter(
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: _body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.amountLabel,
    required this.reference,
    required this.fromMobileApp,
    required this.onHome,
  });

  final String amountLabel;
  final String reference;
  final bool fromMobileApp;
  final VoidCallback onHome;

  static const _orange = Color(0xFFE45F0B);
  static const _ink = Color(0xFF2A1608);
  static const _muted = Color(0xFF6B7280);
  static const _successGreen = Color(0xFF2E9B57);
  static const _rowBorder = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _successGreen.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                    color: _successGreen.withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: _successGreen,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Donation Successful!',
            textAlign: TextAlign.center,
            style: AppTypography.lora(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for your generous contribution. Your payment has been confirmed.',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: 14,
              height: 1.45,
              color: _muted,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _rowBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _DetailRow(label: 'Donation amount', value: amountLabel),
                const Divider(height: 1, color: _rowBorder),
                _DetailRow(
                  label: 'Payment status',
                  value: 'Successful',
                  valueColor: _successGreen,
                ),
                const Divider(height: 1, color: _rowBorder),
                _DetailRow(label: 'Transaction reference', value: reference),
              ],
            ),
          ),
          if (fromMobileApp) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.phone_iphone_rounded,
                  size: 18,
                  color: _orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please return to the App to continue.',
                    style: AppTypography.inter(
                      fontSize: 12.5,
                      height: 1.4,
                      color: _muted,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onHome,
              style: FilledButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Back to Home',
                style: AppTypography.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  static const _ink = Color(0xFF2A1608);
  static const _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: 13,
                color: _muted,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: valueColor ?? _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledCard extends StatelessWidget {
  const _CancelledCard({
    required this.wide,
    required this.onTryAgain,
    required this.onHome,
  });

  final bool wide;
  final VoidCallback onTryAgain;
  final VoidCallback onHome;

  static const _orange = Color(0xFFE45F0B);
  static const _ink = Color(0xFF2A1608);
  static const _muted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 24,
          vertical: wide ? 48 : 36,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ink.withValues(alpha: 0.08),
              ),
              child: Icon(
                Icons.close_rounded,
                color: _ink.withValues(alpha: 0.7),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Payment not completed',
              textAlign: TextAlign.center,
              style: AppTypography.lora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your PayFast checkout was cancelled or did not complete. '
              'No donation has been recorded as paid.',
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 14,
                height: 1.5,
                color: _muted,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTryAgain,
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Try again',
                  style: AppTypography.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onHome,
                child: Text(
                  'Back to Home',
                  style: AppTypography.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _orange,
                    decoration: TextDecoration.underline,
                    decorationColor: _orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LotusDivider extends StatelessWidget {
  const _LotusDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 28, height: 1, color: const Color(0xFFC89B66)),
        const SizedBox(width: 8),
        CustomPaint(
          size: const Size(22, 18),
          painter: _LotusIconPainter(),
        ),
        const SizedBox(width: 8),
        Container(width: 28, height: 1, color: const Color(0xFFC89B66)),
      ],
    );
  }
}

class _LotusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC49A6C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height * 0.75;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: 10, height: 18),
      3.4,
      2.6,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx - 6, cy - 2), width: 10, height: 14),
      3.6,
      2.2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx + 6, cy - 2), width: 10, height: 14),
      3.6,
      2.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
