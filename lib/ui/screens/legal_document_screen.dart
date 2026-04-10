import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/legal/legal_document_assets.dart';
import '../../core/legal/legal_ui_strings.dart';
import '../../core/theme/app_colors.dart';

/// Wyświetla treść polityki / regulaminu z pliku Markdown w assetach.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({required this.docId, super.key});

  final String docId;

  @override
  Widget build(BuildContext context) {
    final copy = LegalUiStrings.of(context);
    final asset = legalDocumentAsset(docId, context);
    final title = legalDocumentTitle(docId, context);

    if (asset == null) {
      return Scaffold(
        backgroundColor: AppColors.kBgBase,
        appBar: AppBar(
          backgroundColor: AppColors.kBgBase,
          foregroundColor: AppColors.kTextPrimary,
        ),
        body: Center(
          child: Text(
            '${copy.docUnknown}$docId',
            style: GoogleFonts.dmSans(color: AppColors.kTextSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kBgBase,
      appBar: AppBar(
        backgroundColor: AppColors.kBgBase,
        foregroundColor: AppColors.kTextPrimary,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: FutureBuilder<String>(
        key: ValueKey<String>(asset),
        future: rootBundle.loadString(asset),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  copy.docLoadError,
                  style: GoogleFonts.dmSans(color: AppColors.kTextSecondary),
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.kAccent),
            );
          }

          return Markdown(
            data: snapshot.data!,
            selectable: true,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            styleSheet: _sheet(context),
          );
        },
      ),
    );
  }

  MarkdownStyleSheet _sheet(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    return base.copyWith(
      h1: GoogleFonts.syne(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.kTextPrimary,
        height: 1.25,
      ),
      h2: GoogleFonts.syne(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.kTextPrimary,
        height: 1.3,
      ),
      h3: GoogleFonts.dmSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.kTextPrimary,
      ),
      p: GoogleFonts.dmSans(
        fontSize: 14,
        height: 1.55,
        color: AppColors.kTextSecondary,
      ),
      listBullet: GoogleFonts.dmSans(
        fontSize: 14,
        color: AppColors.kTextSecondary,
      ),
      strong: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.kTextPrimary,
      ),
      tableHead: GoogleFonts.dmSans(
        fontWeight: FontWeight.w700,
        color: AppColors.kTextPrimary,
      ),
      tableBody: GoogleFonts.dmSans(color: AppColors.kTextSecondary),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.kBorder.withValues(alpha: 0.6)),
        ),
      ),
      blockquote: GoogleFonts.dmSans(
        fontSize: 13,
        fontStyle: FontStyle.italic,
        color: AppColors.kTextMuted,
      ),
      a: GoogleFonts.dmSans(
        fontSize: 14,
        color: AppColors.kAccent,
        decoration: TextDecoration.underline,
      ),
 );
  }
}
