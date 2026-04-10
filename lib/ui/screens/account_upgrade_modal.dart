import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/account_upgrade_notifier.dart';

/// Modal (bottom sheet) do opcjonalnego upgrade konta anonimowego po zakupie Pro.
///
/// Wywoływać przez [showAccountUpgradeModal] po sukcesie purchase().
/// Użytkownik może pominąć — upgrade jest zawsze opcjonalny.
///
/// Korzyść dla użytkownika: historia drzemek i status Pro przeżywają
/// reinstalację i zmianę urządzenia (userId jest zachowany po stronie Appwrite).
class AccountUpgradeModal extends ConsumerStatefulWidget {
  const AccountUpgradeModal({super.key});

  @override
  ConsumerState<AccountUpgradeModal> createState() =>
      _AccountUpgradeModalState();
}

class _AccountUpgradeModalState extends ConsumerState<AccountUpgradeModal> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(accountUpgradeProvider.notifier).upgrade(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountUpgradeProvider);

    // Przy sukcesie — zamknij modal automatycznie.
    ref.listen<AccountUpgradeState>(accountUpgradeProvider, (_, next) {
      if (next is AccountUpgradeSuccess && mounted) {
        Navigator.of(context).pop(true); // true = upgrade wykonany
      }
    });

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.kBgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: switch (state) {
        AccountUpgradeSuccess() => _SuccessView(),
        _ => _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            passCtrl: _passCtrl,
            obscurePass: _obscurePass,
            onToggleObscure: () =>
                setState(() => _obscurePass = !_obscurePass),
            onSubmit: _submit,
            isLoading: state is AccountUpgradeLoading,
            errorMessage:
                state is AccountUpgradeError ? state.message : null,
          ),
      },
    );
  }
}

// ── Widoki ────────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscurePass,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.isLoading,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscurePass;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: AppColors.kAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zabezpiecz swoje dane',
                      style: GoogleFonts.syne(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kTextPrimary,
                      ),
                    ),
                    Text(
                      'Opcjonalnie — możesz pominąć',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Opis korzyści
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.kBgDeep,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Text(
              'Przypisz email do konta — Twoja historia drzemek i status Pro '
              'przeżyją reinstalację lub zmianę telefonu.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.kTextSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Email
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.dmSans(color: AppColors.kTextPrimary),
            decoration: _inputDecoration('Email', Icons.mail_rounded),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Podaj email';
              if (!v.contains('@') || !v.contains('.')) {
                return 'Nieprawidłowy format email';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Hasło
          TextFormField(
            controller: passCtrl,
            obscureText: obscurePass,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.dmSans(color: AppColors.kTextPrimary),
            decoration: _inputDecoration(
              'Hasło (min. 8 znaków)',
              Icons.lock_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePass
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: AppColors.kTextMuted,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) {
              if (v == null || v.length < 8) {
                return 'Hasło musi mieć co najmniej 8 znaków';
              }
              return null;
            },
          ),

          // Błąd
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.kError.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.kError.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_rounded,
                      color: AppColors.kError, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.kError,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Przyciski
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.kBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Pomiń',
                    style: GoogleFonts.dmSans(color: AppColors.kTextSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.kBgDeep,
                          ),
                        )
                      : Text(
                          'Przypisz email',
                          style: GoogleFonts.syne(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.kTextMuted),
        filled: true,
        fillColor: AppColors.kBgDeep,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.kBorder),
        ),
      );
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.kSuccess.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.kSuccess, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'Konto zabezpieczone!',
          style: GoogleFonts.syne(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.kTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Historia i status Pro są teraz powiązane z Twoim emailem.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.kTextSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

// ── Helper do wywoływania modalu ──────────────────────────────────────────────

/// Wyświetla modal upgrade po zakupie Pro.
///
/// Zwraca `true` jeśli użytkownik zakończył upgrade sukcesem, `false` jeśli pominął.
Future<bool> showAccountUpgradeModal(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AccountUpgradeModal(),
  );
  return result ?? false;
}
