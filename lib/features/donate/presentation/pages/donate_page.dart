import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sathya_landing/config/donation_config.dart';
import 'package:sathya_landing/config/routes/app_routes.dart';
import 'package:sathya_landing/core/theme/app_typography.dart';
import 'package:sathya_landing/features/donate/data/donation_api.dart';
import 'package:sathya_landing/features/donate/data/payfast_redirect.dart';
import 'package:sathya_landing/features/landing/presentation/landing_colors.dart';
import 'package:sathya_landing/features/landing/presentation/landing_navigation.dart';
import 'package:sathya_landing/features/landing/presentation/widgets/landing_chrome.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({super.key});

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
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
    _selectedPreset = 100;
    _amountCtrl.text = '100';
    _loadConfig();
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
    } catch (e) {
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
        _submitError = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: LandingColors.cream,
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
            onOpenDrawer: () => scaffoldKey.currentState?.openEndDrawer(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 56 : 16,
                      vertical: wide ? 40 : 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: _loadingConfig
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 80),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : _buildForm(wide),
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

  Widget _buildForm(bool wide) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Donate',
            style: AppTypography.lora(
              fontSize: wide ? 40 : 32,
              fontWeight: FontWeight.w700,
              color: LandingColors.burgundy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Support the work of Sathya. Payments are processed securely on '
            'PayFast outside this app. Card details are never collected on '
            'this website.',
            style: AppTypography.inter(
              fontSize: 16,
              height: 1.55,
              color: LandingColors.textBody,
            ),
          ),
          if (_config.configIncomplete ||
              _config.recipientName.startsWith('[CONFIGURE')) ...[
            const SizedBox(height: 16),
            _notice(
              'Recipient legal details are not fully configured yet. '
              'Set DONATION_RECIPIENT_NAME, DONATION_PURPOSE, and '
              'DONATION_CONTACT_EMAIL on the server before public release.',
              tone: _NoticeTone.warning,
            ),
          ],
          if (_configError != null) ...[
            const SizedBox(height: 16),
            _notice(_configError!, tone: _NoticeTone.error, onRetry: _loadConfig),
          ],
          const SizedBox(height: 28),
          _sectionTitle('Who receives this donation'),
          const SizedBox(height: 8),
          Text(
            _config.recipientName,
            style: AppTypography.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: LandingColors.burgundy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _config.donationPurpose,
            style: AppTypography.inter(
              fontSize: 15,
              height: 1.5,
              color: LandingColors.textBody,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This page does not claim nonprofit / Benevity / Candid approval '
            'or tax deductibility.',
            style: AppTypography.inter(
              fontSize: 13,
              height: 1.45,
              color: LandingColors.textBody,
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle('Choose an amount (ZAR)'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final amount in _config.suggestedAmounts)
                ChoiceChip(
                  label: Text('R ${amount.round()}'),
                  selected: _selectedPreset == amount.round(),
                  selectedColor: LandingColors.headerFooterBg.withValues(alpha: 0.2),
                  onSelected: _submitting
                      ? null
                      : (_) {
                          setState(() {
                            _selectedPreset = amount.round();
                            _amountCtrl.text = '${amount.round()}';
                          });
                        },
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountCtrl,
            enabled: !_submitting,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: _inputDecoration('Custom amount (ZAR)'),
            onChanged: (value) {
              final parsed = int.tryParse(value.trim());
              setState(() {
                _selectedPreset = _config.suggestedAmounts
                        .map((e) => e.round())
                        .contains(parsed)
                    ? parsed
                    : null;
              });
            },
            validator: (value) {
              final parsed = num.tryParse((value ?? '').trim());
              if (parsed == null) return 'Enter a valid amount';
              if (parsed < _config.minAmount) {
                return 'Minimum is ZAR ${_config.minAmount}';
              }
              if (parsed > _config.maxAmount) {
                return 'Maximum is ZAR ${_config.maxAmount}';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _sectionTitle('Your details'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            enabled: !_submitting,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('Email (required for PayFast receipt)'),
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
                  controller: _firstNameCtrl,
                  enabled: !_submitting,
                  decoration: _inputDecoration('First name (optional)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lastNameCtrl,
                  enabled: !_submitting,
                  decoration: _inputDecoration('Last name (optional)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteCtrl,
            enabled: !_submitting,
            maxLines: 3,
            maxLength: 280,
            decoration: _inputDecoration('Note (optional)'),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 12),
            _notice(_submitError!, tone: _NoticeTone.error),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: LandingColors.headerFooterBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Continue to PayFast',
                      style: AppTypography.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          _sectionTitle('Contact & terms'),
          const SizedBox(height: 8),
          Text(
            'Questions about donations: ${_config.contactEmail}'
            '${_config.contactPhone != null ? ' · ${_config.contactPhone}' : ''}.\n'
            'By continuing you will leave this site and complete payment on '
            'PayFast’s secure checkout. A browser “success” page is not proof '
            'of payment — settlement is confirmed by our server after PayFast '
            'notifies us.',
            style: AppTypography.inter(
              fontSize: 14,
              height: 1.5,
              color: LandingColors.textBody,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.termsAndConditions),
            child: const Text('View terms & conditions'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTypography.lora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: LandingColors.burgundy,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: LandingColors.burgundy.withValues(alpha: 0.2)),
      ),
    );
  }

  Widget _notice(
    String text, {
    required _NoticeTone tone,
    VoidCallback? onRetry,
  }) {
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
      padding: const EdgeInsets.all(14),
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
            style: AppTypography.inter(fontSize: 14, height: 1.45, color: color),
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
