import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.responsiveSpacingUnit;

    return ResponsiveScaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.legalTitle,
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: OpeiBrand.ink,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing * 2,
          spacing * 2,
          spacing * 2,
          spacing * 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(context, l10n),
            SizedBox(height: spacing * 2),
            _buildDocumentsStrip(context, l10n),
            SizedBox(height: spacing * 2),
            ..._documentParagraphs(context, l10n.termsDocumentBody),
            _contactCard(context, l10n),
            SizedBox(height: spacing * 2),
            _section(context, l10n.legalCopyrightNotice),
            _footerLinks(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opei',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.ink,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.go('/welcome'),
          child: Text(
            l10n.legalBackToHomeCta,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.termsAndConditionsTitle,
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: OpeiBrand.ink,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.legalLastUpdated,
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: OpeiBrand.inkSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsStrip(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.legalDocumentsTitle,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.inkSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            l10n.privacyPolicyTitle,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            l10n.termsAndConditionsTitle,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: kPrimaryFontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: OpeiBrand.inkSecondary,
        height: 1.55,
      ),
    ),
  );

  Widget _contactCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.legalCompanyName,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
            ),
          ),
          SizedBox(height: 8),
          Text(
            l10n.legalSupportEmail,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              color: OpeiBrand.inkSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            l10n.legalCompanyAddress,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              color: OpeiBrand.inkSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4),
          Text(
            l10n.legalCompanyPhone,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              color: OpeiBrand.inkSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _documentParagraphs(BuildContext context, String body) {
    final chunks = body
        .split('\n\n')
        .map((chunk) => chunk.trim())
        .where((chunk) => chunk.isNotEmpty);

    return chunks.map((chunk) => _section(context, chunk)).toList();
  }

  Widget _footerLinks(BuildContext context, AppLocalizations l10n) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: () => context.go('/privacy'),
          child: Text(
            l10n.privacyPolicyTitle,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/terms'),
          child: Text(
            l10n.termsAndConditionsTitle,
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.primary,
            ),
          ),
        ),
      ],
    );
  }
}
