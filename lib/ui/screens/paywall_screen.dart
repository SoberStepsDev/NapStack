import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/legal/legal_document_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/account_upgrade_notifier.dart';
import '../../features/pro/pro_provider.dart';
import 'account_upgrade_modal.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  /// Czy modal upgrade był już pokazany w tej sesji PaywallScreen.
  bool _upgradeShown = false;

  @override
  Widget build(BuildContext context) {
    final proState = ref.watch(proActionsProvider);

    // Reagujemy na sukces zakupu (przejście: loading → data(true)).
    // Pokazujemy modal upgrade raz — użytkownik może pominąć.
    ref.listen<AsyncValue<bool>>(proActionsProvider, (prev, next) {
      final justPurchased =
          (prev?.isLoading ?? false) && next.value == true && !next.isLoading;

      if (justPurchased && !_upgradeShown && mounted) {
        _upgradeShown = true;
        ref.read(accountUpgradeProvider.notifier).reset();

        // Krótkie opóźnienie — dajemy UI chwilę na wyrenderowanie "Pro aktywny"
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!context.mounted) return;
          showAccountUpgradeModal(context);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.kBgDeep,
      body: Stack(
        children: [
          // Gradient tła
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A1628), AppColors.kBgDeep],
                  stops: [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Dekoracyjne kółko w tle
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.kAccent.withValues(alpha: 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.kBgCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.kBorder),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.kTextSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        _HeroSection(),
                        const SizedBox(height: 32),
                        _FeatureList(),
                        const SizedBox(height: 32),
                        _PriceCard(),
                        const SizedBox(height: 20),
                        _PurchaseButton(proState: proState, ref: ref),
                        const SizedBox(height: 12),
                        _RestoreButton(ref: ref),
                        const SizedBox(height: 20),
                        _PaywallLegalLinks(),
                        const SizedBox(height: 16),
                        _LegalNote(),
                      ],
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
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pro icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.kAccentGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.kAccent.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.kBgDeep,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'NapStack Pro',
          style: GoogleFonts.syne(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.kTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Odblokuj pełny potencjał drzemek.\nJednorazowy zakup, na zawsze.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.kTextSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Features ──────────────────────────────────────────────────────────────────

class _FeatureList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kBorder, width: 1),
      ),
      child: Column(
        children: const [
          _FeatureRow(
            icon: Icons.nightlight_round,
            color: AppColors.kFullCycleColor,
            title: 'Full Cycle — 90 min',
            subtitle: 'Pełny cykl REM dla głębokiej regeneracji',
          ),
          _Divider(),
          _FeatureRow(
            icon: Icons.layers_rounded,
            color: AppColors.kAccent,
            title: 'Nieograniczony Nap Stack',
            subtitle: 'Planuj tyle drzemek ile chcesz (free: maks. 3)',
          ),
          _Divider(),
          _FeatureRow(
            icon: Icons.bar_chart_rounded,
            color: AppColors.kSuccess,
            title: 'Pełne statystyki',
            subtitle: 'Historia, seria dni, ulubiony preset',
          ),
          _Divider(),
          _FeatureRow(
            icon: Icons.devices_rounded,
            color: AppColors.kCoffeeNapColor,
            title: 'Synchronizacja między urządzeniami',
            subtitle: 'Historia przeżywa reinstalację',
          ),
          _Divider(),
          _FeatureRow(
            icon: Icons.support_rounded,
            color: AppColors.kPowerNapColor,
            title: 'Wspierasz solo developera',
            subtitle: 'NapStack to projekt Patryk AI — dzięki! 🙏',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.kTextSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.kSuccess, size: 18),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}

// ── Price card ────────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kAccent.withValues(alpha: 0.12),
            AppColors.kAccentDark.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.kAccent.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Jednorazowy zakup',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.kTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '3,99 EUR',
                style: GoogleFonts.syne(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kAccent,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Płacisz raz — masz na zawsze',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.kTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Buttons ───────────────────────────────────────────────────────────────────

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({required this.proState, required this.ref});
  final AsyncValue<bool> proState;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isLoading = proState.isLoading;
    final isAlreadyPro = proState.value == true;

    if (isAlreadyPro) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.kSuccess.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.kSuccess.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.kSuccess, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pro już aktywny!',
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.kSuccess,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => ref.read(proActionsProvider.notifier).purchase(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.kBgDeep,
                ),
              )
            : Text(
                'Kup NapStack Pro — 3,99 EUR',
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => ref.read(proActionsProvider.notifier).restore(),
      child: const Text('Przywróć zakupy'),
    );
  }
}

class _PaywallLegalLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.dmSans(
      fontSize: 12,
      color: AppColors.kAccent,
      fontWeight: FontWeight.w600,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        TextButton(
          onPressed: () => context.push('/legal/privacy'),
          child: Text(legalDocumentTitle('privacy', context), style: style),
        ),
        TextButton(
          onPressed: () => context.push('/legal/terms'),
          child: Text(legalDocumentTitle('terms', context), style: style),
        ),
        TextButton(
          onPressed: () => context.push('/legal/consumer'),
          child: Text(legalDocumentTitle('consumer', context), style: style),
        ),
      ],
    );
  }
}

class _LegalNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Jednorazowy zakup. Bez subskrypcji. Brak automatycznych odnowień.\n'
      'Płatność pobrana przez Google Play. Zakup nieprzypisany do konta email.',
      textAlign: TextAlign.center,
      style: GoogleFonts.dmSans(
        fontSize: 11,
        color: AppColors.kTextMuted,
        height: 1.5,
      ),
    );
  }
}
