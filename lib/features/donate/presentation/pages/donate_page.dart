import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/donation_config.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/donate/data/donate_from_app.dart';
import 'package:sathya_landing/features/donate/data/donation_api.dart';
import 'package:sathya_landing/features/donate/data/donation_receipt.dart';
import 'package:sathya_landing/features/donate/data/payfast_redirect.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_chrome.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  static const _orange = Color(0xFFE35600);
  static const _cream = Color(0xFFFAF3E8);
  static const _cardForm = Color(0xFFFFFBF6);
  static const _ink = Color(0xFF3B1E08);
  static const _muted = Color(0xFF6E523C);
  static const _flowerAsset = 'assets/images/donateFlowerImg.png';

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollCtrl = ScrollController();
  final _amountCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _api = DonationApi();

  WebsiteDonationPublicConfig _config =
      WebsiteDonationPublicConfig.fallback();
  bool _loadingConfig = true;
  int? _selectedPreset;
  bool _submitting = false;
  String? _submitError;
  bool _cameFromMobileApp = false;

  @override
  void initState() {
    super.initState();
    _selectedPreset = 50;
    _amountCtrl.text = '50';
    _applyPrefillFromUrl();
    _loadConfig();
  }

  void _applyPrefillFromUrl() {
    final params = <String, String>{};

    void addAll(Map<dynamic, dynamic> source) {
      source.forEach((key, value) {
        final k = key?.toString().trim() ?? '';
        final v = value?.toString().trim() ?? '';
        if (k.isEmpty || v.isEmpty) return;
        params[k] = v;
      });
    }

    addAll(Get.parameters);
    addAll(Uri.base.queryParameters);

    final fragment = Uri.base.fragment;
    final qIndex = fragment.indexOf('?');
    if (qIndex >= 0 && qIndex < fragment.length - 1) {
      addAll(Uri.splitQueryString(fragment.substring(qIndex + 1)));
    }

    final args = Get.arguments;
    if (args is Map) {
      args.forEach((key, value) {
        if (key == null || value == null) return;
        final v = value.toString().trim();
        if (v.isEmpty) return;
        params[key.toString()] = v;
      });
    }

    _cameFromMobileApp = urlIndicatesDonateFromMobileApp(
      queryParameters: Uri.base.queryParameters,
      getParameters: Map<String, String>.from(
        Get.parameters.map((k, v) => MapEntry(k, v.toString())),
      ),
      fragment: Uri.base.fragment,
    );
    if (_cameFromMobileApp) {
      markCameFromMobileApp();
    }

    final email = params['email'];
    final nameFirst = params['nameFirst'] ?? params['firstName'];
    final nameLast = params['nameLast'] ?? params['lastName'];
    final fullName = params['name'] ?? params['fullName'];

    if (email != null && email.contains('@')) {
      _emailCtrl.text = email;
    }
    if (nameFirst != null && nameFirst.isNotEmpty) {
      _firstNameCtrl.text = nameFirst;
    }
    if (nameLast != null && nameLast.isNotEmpty) {
      _lastNameCtrl.text = nameLast;
    }
    if (_firstNameCtrl.text.isEmpty &&
        _lastNameCtrl.text.isEmpty &&
        fullName != null &&
        fullName.isNotEmpty) {
      final parts = fullName.split(RegExp(r'\s+'));
      _firstNameCtrl.text = parts.first;
      if (parts.length > 1) {
        _lastNameCtrl.text = parts.sublist(1).join(' ');
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _amountCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _loadingConfig = true;
    });
    try {
      final config = await _api.fetchConfig();
      if (!mounted) return;
      setState(() {
        _config = config;
        _loadingConfig = false;
        if (_selectedPreset != null &&
            !config.suggestedAmounts
                .map((e) => e.round())
                .contains(_selectedPreset)) {
          final first = config.suggestedAmounts.first.round();
          _selectedPreset = first;
          _amountCtrl.text = '$first';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _config = WebsiteDonationPublicConfig.fallback();
        _loadingConfig = false;
      });
    }
  }

  void _onNav(String label) {
    LandingNavigation.handleLink(
      label,
      currentRoute: AppRoutes.donate,
    );
  }

  Future<void> _submit() async {
    setState(() => _submitError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = num.tryParse(_amountCtrl.text.trim());
    if (amount == null) {
      setState(() => _submitError = 'Enter a valid amount.');
      return;
    }
    if (amount < _config.minAmount || amount > _config.maxAmount) {
      setState(() {
        _submitError =
            'Amount must be between ZAR ${_config.minAmount} and ZAR ${_config.maxAmount}.';
      });
      return;
    }

    setState(() => _submitting = true);
    try {
      final fromApp =
          _cameFromMobileApp || peekCameFromMobileAppFlag();
      if (fromApp) {
        markCameFromMobileApp();
      }
      final returnUrl = fromApp
          ? appendDonateFromAppQuery(_config.returnUrl)
          : _config.returnUrl;
      final cancelUrl = fromApp
          ? appendDonateFromAppQuery(_config.cancelUrl)
          : _config.cancelUrl;
      final result = await _api.initiate(
        amount: amount,
        email: _emailCtrl.text,
        nameFirst: _firstNameCtrl.text,
        nameLast: _lastNameCtrl.text,
        note: _noteCtrl.text,
        callbackUrl: returnUrl,
        cancelUrl: cancelUrl,
      );
      savePendingDonationReceipt(
        amountLabel: formatZarAmountLabel(result.amount),
        reference: result.reference,
      );
      await redirectToPayFast(
        paymentUrl: result.paymentUrl,
        formFields: result.formFields,
      );
    } on DonationApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitError = 'Could not continue to PayFast. ${e.toString()}';
      });
    }
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
              controller: _scrollCtrl,
              child: Column(
                children: [
                  _HeroBanner(wide: wide),
                  Transform.translate(
                    // Mobile: less pull-up so the donate image sits slightly lower.
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
                          child: _loadingConfig
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 96),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: _orange,
                                    ),
                                  ),
                                )
                              : _DonationCard(
                                  wide: wide,
                                  formKey: _formKey,
                                  config: _config,
                                  submitError: _submitError,
                                  submitting: _submitting,
                                  selectedPreset: _selectedPreset,
                                  amountCtrl: _amountCtrl,
                                  emailCtrl: _emailCtrl,
                                  firstNameCtrl: _firstNameCtrl,
                                  lastNameCtrl: _lastNameCtrl,
                                  noteCtrl: _noteCtrl,
                                  onSelectPreset: (amount) {
                                    setState(() {
                                      _selectedPreset = amount;
                                      _amountCtrl.text = '$amount';
                                      _submitError = null;
                                    });
                                  },
                                  onAmountChanged: (value) {
                                    final parsed = int.tryParse(value.trim());
                                    setState(() {
                                      _selectedPreset = _config.suggestedAmounts
                                              .map((e) => e.round())
                                              .contains(parsed)
                                          ? parsed
                                          : null;
                                    });
                                  },
                                  onSubmit: _submit,
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

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.wide});

  final bool wide;
  static const _flower = 'assets/images/home/landingFlower.png';

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _TempleCanopyClipper(),
      child: ColoredBox(
        color: _DonatePageState._orange,
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

class _DonationCard extends StatelessWidget {
  const _DonationCard({
    required this.wide,
    required this.formKey,
    required this.config,
    required this.submitError,
    required this.submitting,
    required this.selectedPreset,
    required this.amountCtrl,
    required this.emailCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.noteCtrl,
    required this.onSelectPreset,
    required this.onAmountChanged,
    required this.onSubmit,
  });

  final bool wide;
  final GlobalKey<FormState> formKey;
  final WebsiteDonationPublicConfig config;
  final String? submitError;
  final bool submitting;
  final int? selectedPreset;
  final TextEditingController amountCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController noteCtrl;
  final ValueChanged<int> onSelectPreset;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: wide
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 48, child: _StoryPanel(wide: wide)),
                    Expanded(flex: 52, child: _formPane()),
                  ],
                ),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 360,
                    width: double.infinity,
                    child: _StoryPanel(wide: false),
                  ),
                  _formPane(),
                ],
              ),
      ),
    );
  }

  Widget _formPane() {
    final amounts = config.suggestedAmounts.isEmpty
        ? DonationConfig.suggestedAmountsZar
        : config.suggestedAmounts;

    return ColoredBox(
      color: _DonatePageState._cardForm,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          wide ? 38 : 20,
          wide ? 28 : 22,
          wide ? 38 : 20,
          wide ? 26 : 22,
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Make a Donation',
                style: AppTypography.lora(
                  fontSize: wide ? 30 : 25,
                  fontWeight: FontWeight.w700,
                  color: _DonatePageState._ink,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select an amount (ZAR)',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _DonatePageState._muted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (var i = 0; i < amounts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _AmountPill(
                        label: 'R ${amounts[i].round()}',
                        selected: selectedPreset == amounts[i].round(),
                        enabled: !submitting,
                        onTap: () => onSelectPreset(amounts[i].round()),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Custom amount (ZAR)',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _DonatePageState._muted,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: amountCtrl,
                enabled: !submitting,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                style: AppTypography.inter(
                  fontSize: 15,
                  color: _DonatePageState._ink,
                ),
                decoration: _fieldDecoration(hint: '100'),
                onChanged: onAmountChanged,
                validator: (value) {
                  final parsed = num.tryParse((value ?? '').trim());
                  if (parsed == null) return 'Enter a valid amount';
                  if (parsed < config.minAmount) {
                    return 'Minimum is ZAR ${config.minAmount}';
                  }
                  if (parsed > config.maxAmount) {
                    return 'Maximum is ZAR ${config.maxAmount}';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Your details',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _DonatePageState._muted,
                ),
              ),
              const SizedBox(height: 12),
              const _FieldLabel('Email', isRequired: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: emailCtrl,
                enabled: !submitting,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                style: AppTypography.inter(
                  fontSize: 15,
                  color: _DonatePageState._ink,
                ),
                decoration: _fieldDecoration(hint: 'you@example.com'),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty) {
                    return 'Email is required';
                  }
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('First name', isRequired: true),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: firstNameCtrl,
                          enabled: !submitting,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
                          style: AppTypography.inter(
                            fontSize: 15,
                            color: _DonatePageState._ink,
                          ),
                          decoration: _fieldDecoration(hint: 'First name'),
                          validator: (value) {
                            final v = (value ?? '').trim();
                            if (v.isEmpty) {
                              return 'First name is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Last name'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: lastNameCtrl,
                          enabled: !submitting,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                          style: AppTypography.inter(
                            fontSize: 15,
                            color: _DonatePageState._ink,
                          ),
                          decoration: _fieldDecoration(hint: 'Last name'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Notes'),
              const SizedBox(height: 6),
              TextFormField(
                controller: noteCtrl,
                enabled: !submitting,
                maxLines: 2,
                maxLength: 280,
                textInputAction: TextInputAction.done,
                style: AppTypography.inter(
                  fontSize: 15,
                  color: _DonatePageState._ink,
                ),
                decoration: _fieldDecoration(hint: 'Optional message'),
              ),
              if (submitError != null) ...[
                const SizedBox(height: 4),
                _InlineNotice(submitError!, tone: _NoticeTone.error),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 6),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: submitting ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _DonatePageState._orange,
                    disabledBackgroundColor:
                        _DonatePageState._orange.withValues(alpha: 0.55),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Continue',
                          style: AppTypography.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.inter(
        fontSize: 14,
        color: _DonatePageState._muted.withValues(alpha: 0.55),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2D6C8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2D6C8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: _DonatePageState._orange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
      ),
      errorStyle: AppTypography.inter(
        fontSize: 11.5,
        color: const Color(0xFFD32F2F),
      ),
      counterStyle: AppTypography.inter(
        fontSize: 11,
        color: _DonatePageState._muted,
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF2A1608);
    const bodyColor = Color(0xFF3B2412);

    final copy = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: wide ? 310 : 250),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _DecorativeLotusDivider(),
          const SizedBox(height: 12),
          Text(
            'Your support\nmakes a difference',
            textAlign: TextAlign.center,
            style: AppTypography.lora(
              fontSize: wide ? 28 : 22,
              fontWeight: FontWeight.w700,
              height: 1.22,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'With your generosity, we can continue to bring authentic '
            'Vedic knowledge, spiritual guidance and valuable resources '
            'to people around the world.',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: wide ? 14 : 12.5,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            _DonatePageState._flowerAsset,
            fit: BoxFit.cover,
            alignment: Alignment(wide ? -0.92 : -0.88, wide ? 0.0 : 0.12),
            filterQuality: FilterQuality.high,
            isAntiAlias: true,
          ),
        ),
        // Soft image dim for text readability — a bit stronger on mobile.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: wide
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white.withValues(alpha: 0.55),
                      ],
                      stops: const [0.28, 0.58, 1.0],
                    )
                  : LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white.withValues(alpha: 0.52),
                        Colors.white.withValues(alpha: 0.36),
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.28),
                      ],
                      stops: const [0.0, 0.30, 0.65, 1.0],
                    ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            wide ? 28 : 16,
            wide ? 24 : 36,
            wide ? 28 : 16,
            wide ? 28 : 20,
          ),
          child: Align(
            alignment: wide
                ? const Alignment(0.92, -0.78)
                : const Alignment(1.0, -0.72),
            child: copy,
          ),
        ),
      ],
    );
  }
}

class _DecorativeLotusDivider extends StatelessWidget {
  const _DecorativeLotusDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 1,
          color: const Color(0xFFC89B66),
        ),
        const SizedBox(width: 8),
        CustomPaint(
          size: const Size(22, 18),
          painter: _LotusIconPainter(),
        ),
        const SizedBox(width: 8),
        Container(
          width: 28,
          height: 1,
          color: const Color(0xFFC89B66),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.isRequired = false});

  final String text;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: AppTypography.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _DonatePageState._muted,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  const _AmountPill({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _DonatePageState._orange : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? _DonatePageState._orange
                  : const Color(0xFFE2D6C8),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _DonatePageState._ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice(
    this.text, {
    required this.tone,
  });

  final String text;
  final _NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      _NoticeTone.warning => const Color(0xFF8A5A00),
      _NoticeTone.error => const Color(0xFF8B1E1E),
    };
    final bg = switch (tone) {
      _NoticeTone.warning => const Color(0xFFFFF4DF),
      _NoticeTone.error => const Color(0xFFFDECEC),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: AppTypography.inter(fontSize: 13, height: 1.4, color: color),
      ),
    );
  }
}

enum _NoticeTone { warning, error }

/// Temple canopy / bracket edge framing the top of the donation card.
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
    // Smooth S-curve down to bottom edge (size.height)
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
    // Smooth S-curve up to topEdge
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

    // Central petal
    final pCenter = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx - 3, cy - 10, cx, cy - 15)
      ..quadraticBezierTo(cx + 3, cy - 10, cx, cy);
    canvas.drawPath(pCenter, paint);

    // Left petal
    final pLeft = Path()
      ..moveTo(cx - 1, cy)
      ..quadraticBezierTo(cx - 9, cy - 6, cx - 8, cy - 11)
      ..quadraticBezierTo(cx - 4, cy - 10, cx - 1, cy);
    canvas.drawPath(pLeft, paint);

    // Right petal
    final pRight = Path()
      ..moveTo(cx + 1, cy)
      ..quadraticBezierTo(cx + 9, cy - 6, cx + 8, cy - 11)
      ..quadraticBezierTo(cx + 4, cy - 10, cx + 1, cy);
    canvas.drawPath(pRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
