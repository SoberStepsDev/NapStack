import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/legal/legal_document_assets.dart';
import '../../core/legal/legal_launch.dart';
import '../../core/legal/legal_ui_strings.dart';
import '../../core/legal/legal_urls.dart';
import '../../core/theme/app_colors.dart';

/// Lista dokumentów prawnych: treści w aplikacji + opcjonalne linki WWW + licencje OSS.
class LegalInfoScreen extends StatelessWidget {
  const LegalInfoScreen({super.key});

  Future<void> _openExternal(
    BuildContext context,
    String url,
    String label,
  ) async {
    final copy = LegalUiStrings.of(context);
    final ok = await launchLegalUrl(url);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${copy.cannotOpen}$label')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = LegalUiStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.kBgBase,
      appBar: AppBar(
        backgroundColor: AppColors.kBgBase,
        foregroundColor: AppColors.kTextPrimary,
        elevation: 0,
        title: Text(
          copy.legalInfoAppBar,
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              copy.legalInfoIntro,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.kTextSecondary,
                height: 1.4,
              ),
            ),
          ),
          _tile(
            icon: Icons.article_outlined,
            title: legalDocumentTitle('privacy', context),
            subtitle: copy.subtitleInApp,
            onTap: () => context.push('/legal/privacy'),
          ),
          if (kPrivacyPolicyUrl.isNotEmpty)
            _tile(
              icon: Icons.language,
              title: copy.privacyWwwTitle,
              subtitle: copy.subtitleExternal,
              onTap: () =>
                  _openExternal(context, kPrivacyPolicyUrl, 'polityka www'),
            ),
          _tile(
            icon: Icons.description_outlined,
            title: legalDocumentTitle('terms', context),
            subtitle: copy.subtitleInApp,
            onTap: () => context.push('/legal/terms'),
          ),
          if (kTermsOfServiceUrl.isNotEmpty)
            _tile(
              icon: Icons.language,
              title: copy.termsWwwTitle,
              subtitle: copy.subtitleExternal,
              onTap: () =>
                  _openExternal(context, kTermsOfServiceUrl, 'regulamin www'),
            ),
          _tile(
            icon: Icons.receipt_long_outlined,
            title: legalDocumentTitle('consumer', context),
            subtitle: copy.subtitleInApp,
            onTap: () => context.push('/legal/consumer'),
          ),
          if (kConsumerInfoUrl.isNotEmpty)
            _tile(
              icon: Icons.language,
              title: copy.consumerWwwTitle,
              subtitle: copy.subtitleExternal,
              onTap: () =>
                  _openExternal(context, kConsumerInfoUrl, 'konsument www'),
            ),
          _tile(
            icon: Icons.code_outlined,
            title: copy.ossTitle,
            subtitle: copy.ossSubtitle,
            trailing: const Icon(Icons.chevron_right,
                size: 20, color: AppColors.kTextMuted),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'NapStack',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.nightlight_round,
                  color: AppColors.kAccent,
                  size: 48,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
  }) {
    return Card(
      color: AppColors.kBgCard,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.kBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.kAccent),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: AppColors.kTextPrimary,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.kTextMuted,
                ),
              ),
        trailing: trailing ??
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.kTextMuted),
        onTap: onTap,
      ),
    );
  }
}
