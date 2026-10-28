import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/donation_config.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/donate/data/donation_api.dart';
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
  static const _fieldBorder = Color(0xFFDFD0BF);
  static const _flowerAsset = 'assets/images/donateFlowerImg.png';

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _api = DonationApi();

  WebsiteDonationPublicConfig _config =
      WebsiteDonationPublicConfig.fallback();
  bool _loadingConfig = true;
  String? _configError;
  int? _selectedPreset;
  bool _submitting = false;
  String? _submitError;

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
      _configError = null;
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
        _configError =
            'Could not reach the donation service. You can still review amounts; retry before paying.';
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
      final result = await _api.initiate(
        amount: amount,
        email: _emailCtrl.text,
        nameFirst: _firstNameCtrl.text,
        nameLast: _lastNameCtrl.text,
        note: _noteCtrl.text,
        callbackUrl: _config.returnUrl,
        cancelUrl: _config.cancelUrl,
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
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: _cream,
      endDrawer: LandingMobileDrawer(
        activeNav: 'Donate',
        onNavLink: _onNav,
      ),
      body: Column(
        children: [
          LandingNavBar(
            active: 'Donate',
            onHome: LandingNavigation.goToLanding,
            onAbout: () => LandingNavigation.goToLandingSection('About'),
            onFeatures: () =>
                LandingNavigation.goToLandingSection('Features'),
            onPrivacy: LandingNavigation.openPrivacyPolicy,
            onTerms: LandingNavigation.openTermsAndConditions,
            onDownload: LandingNavigation.openPlayStore,
            onDonate: LandingNavigation.goToDonate,
            onOpenDrawer: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _HeroBanner(wide: wide),
                  Transform.translate(
                    offset: Offset(0, wide ? -56 : -36),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? 64 : 16,
                        0,
                        wide ? 64 : 16,
                        wide ? 40 : 24,
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
                                  configError: _configError,
                                  submitError: _submitError,
                                  submitting: _submitting,
                                  selectedPreset: _selectedPreset,
                                  amountCtrl: _amountCtrl,
                                  emailCtrl: _emailCtrl,
                                  firstNameCtrl: _firstNameCtrl,
                                  lastNameCtrl: _lastNameCtrl,
                                  noteCtrl: _noteCtrl,
                                  onRetryConfig: _loadConfig,
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

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _CloudWaveClipper(),
      child: ColoredBox(
        color: _DonatePageState._orange,
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: wide ? -20 : -100,
                top: wide ? -20 : -70,
                child: Opacity(
                  opacity: 0.22,
                  child: CustomPaint(
                    size: Size(wide ? 460 : 300, wide ? 460 : 300),
                    painter: _MandalaPainter(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  wide ? 64 : 22,
                  wide ? 52 : 34,
                  wide ? 64 : 22,
                  wide ? 100 : 78,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 640 : 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support a More Meaningful Spiritual Journey',
                          style: AppTypography.lora(
                            fontSize: wide ? 44 : 30,
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
                            fontSize: wide ? 16.5 : 14.5,
                            height: 1.55,
                            color: Colors.white.withValues(alpha: 0.96),
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
    required this.configError,
    required this.submitError,
    required this.submitting,
    required this.selectedPreset,
    required this.amountCtrl,
    required this.emailCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.noteCtrl,
    required this.onRetryConfig,
    required this.onSelectPreset,
    required this.onAmountChanged,
    required this.onSubmit,
  });

  final bool wide;
  final GlobalKey<FormState> formKey;
  final WebsiteDonationPublicConfig config;
  final String? configError;
  final String? submitError;
  final bool submitting;
  final int? selectedPreset;
  final TextEditingController amountCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController noteCtrl;
  final VoidCallback onRetryConfig;
  final ValueChanged<int> onSelectPreset;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: wide
            ? SizedBox(
                height: 640,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 48, child: _StoryPanel()),
                    Expanded(flex: 52, child: _formPane()),
                  ],
                ),
              )
            : Column(
                children: [
                  const SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: _StoryPanel(),
                  ),
                  _formPane(),
                ],
              ),
      ),
    );
  }

  String get _contactLine {
    final email = config.contactEmail.trim();
    final phone = config.contactPhone?.trim();
    final emailOk =
        email.isNotEmpty && !email.contains('CONFIGURE') && email.contains('@');
    final phoneOk = phone != null && phone.isNotEmpty && !phone.contains('CONFIGURE');
    final parts = <String>[
      if (emailOk) email else DonationConfig.fallbackContactEmail,
      if (phoneOk) phone else DonationConfig.fallbackContactPhone,
    ];
    return parts.join(' · ');
  }

  Widget _formPane() {
    final amounts = config.suggestedAmounts.isEmpty
        ? DonationConfig.suggestedAmountsZar
        : config.suggestedAmounts;

    return ColoredBox(
      color: _DonatePageState._cardForm,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(wide ? 40 : 22, 32, wide ? 40 : 22, 28),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Make a Donation',
                style: AppTypography.lora(
                  fontSize: wide ? 32 : 26,
                  fontWeight: FontWeight.w700,
                  color: _DonatePageState._ink,
                ),
              ),
              if (configError != null) ...[
                const SizedBox(height: 14),
                _InlineNotice(
                  configError!,
                  tone: _NoticeTone.error,
                  onRetry: onRetryConfig,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Select an amount (ZAR)',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _DonatePageState._muted,
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              Text(
                'Custom amount (ZAR)',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _DonatePageState._muted,
                ),
              ),
              const SizedBox(height: 8),
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
                decoration: _fieldDecoration(),
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
              const SizedBox(height: 22),
              Text(
                'Your details',
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _DonatePageState._muted,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailCtrl,
                enabled: !submitting,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.inter(
                  fontSize: 15,
                  color: _DonatePageState._ink,
                ),
                decoration: _fieldDecoration(
                  hint: 'Email (required for PayFast receipt)',
                ),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.isEmpty || !v.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameCtrl,
                      enabled: !submitting,
                      style: AppTypography.inter(
                        fontSize: 15,
                        color: _DonatePageState._ink,
                      ),
                      decoration:
                          _fieldDecoration(hint: 'First name (optional)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameCtrl,
                      enabled: !submitting,
                      style: AppTypography.inter(
                        fontSize: 15,
                        color: _DonatePageState._ink,
                      ),
                      decoration:
                          _fieldDecoration(hint: 'Last name (optional)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteCtrl,
                enabled: !submitting,
                maxLines: 3,
                maxLength: 280,
                style: AppTypography.inter(
                  fontSize: 15,
                  color: _DonatePageState._ink,
                ),
                decoration: _fieldDecoration(hint: 'Note (optional)'),
              ),
              if (submitError != null) ...[
                const SizedBox(height: 4),
                _InlineNotice(submitError!, tone: _NoticeTone.error),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: submitting ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: _DonatePageState._orange,
                    disabledBackgroundColor:
                        _DonatePageState._orange.withValues(alpha: 0.55),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                          'Continue to Secure Payment',
                          style: AppTypography.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: _DonatePageState._muted.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Secure payment processed by PayFast. Card details are '
                      'handled by our payment provider.',
                      style: AppTypography.inter(
                        fontSize: 12.5,
                        height: 1.45,
                        color: _DonatePageState._muted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'This page does not claim nonprofit approval or tax deductibility. '
                'Questions: $_contactLine.',
                style: AppTypography.inter(
                  fontSize: 11.5,
                  height: 1.45,
                  color: _DonatePageState._muted.withValues(alpha: 0.9),
                ),
              ),
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
        color: _DonatePageState._muted.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _DonatePageState._fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _DonatePageState._fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: _DonatePageState._orange, width: 1.5),
      ),
      counterStyle: AppTypography.inter(
        fontSize: 11,
        color: _DonatePageState._muted,
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          _DonatePageState._flowerAsset,
          fit: BoxFit.cover,
          alignment: const Alignment(-0.35, 0.1),
        ),
        // Soft wash so the lotus stays visible, text remains readable.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.28),
                Colors.white.withValues(alpha: 0.78),
                Colors.white.withValues(alpha: 0.92),
              ],
              stops: const [0.0, 0.35, 0.72, 1.0],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(36, 40, 36, 44),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomPaint(
                size: const Size(34, 28),
                painter: _LotusIconPainter(),
              ),
              const SizedBox(height: 16),
              Text(
                'Your support makes\na difference',
                textAlign: TextAlign.center,
                style: AppTypography.lora(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.22,
                  color: _DonatePageState._ink,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'With your generosity, we can continue to bring authentic '
                'Vedic knowledge, spiritual guidance and valuable resources '
                'to people around the world.',
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  fontSize: 14.5,
                  height: 1.55,
                  color: _DonatePageState._muted,
                ),
              ),
            ],
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? _DonatePageState._orange
                  : _DonatePageState._fieldBorder,
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
    this.onRetry,
  });

  final String text;
  final _NoticeTone tone;
  final VoidCallback? onRetry;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTypography.inter(fontSize: 13, height: 1.4, color: color),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

enum _NoticeTone { warning, error }

/// Cloud / scallop edge matching the design mock.
class _CloudWaveClipper extends CustomClipper<Path> {
  const _CloudWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 42);
    const bumps = 10;
    final w = size.width / bumps;
    for (var i = 0; i < bumps; i++) {
      final start = i * w;
      path.cubicTo(
        start + w * 0.25,
        size.height - 8,
        start + w * 0.35,
        size.height - 8,
        start + w * 0.5,
        size.height - 34,
      );
      path.cubicTo(
        start + w * 0.65,
        size.height - 58,
        start + w * 0.75,
        size.height - 58,
        start + w,
        size.height - 34,
      );
    }
    path
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _MandalaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    for (var ring = 1; ring <= 7; ring++) {
      canvas.drawCircle(center, size.shortestSide * 0.07 * ring, paint);
    }

    const rays = 24;
    for (var i = 0; i < rays; i++) {
      final angle = (math.pi * 2 / rays) * i;
      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * size.shortestSide * 0.48,
          center.dy + math.sin(angle) * size.shortestSide * 0.48,
        ),
        paint,
      );
    }

    for (var i = 0; i < 12; i++) {
      final angle = (math.pi * 2 / 12) * i;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * size.shortestSide * 0.28,
          center.dy + math.sin(angle) * size.shortestSide * 0.28,
        ),
        7,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LotusIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC47A2C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height * 0.62;

    for (final dx in [-10.0, -5.0, 0.0, 5.0, 10.0]) {
      final path = Path()
        ..moveTo(cx, cy + 6)
        ..quadraticBezierTo(cx + dx, cy - 10, cx + dx * 0.2, cy - 18)
        ..quadraticBezierTo(cx, cy - 6, cx, cy + 6);
      canvas.drawPath(path, paint);
    }
    canvas.drawCircle(Offset(cx, cy - 2), 2.2, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
