import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.responsiveSpacingUnit;

    return ResponsiveScaffold(
      backgroundColor: OpeiBrand.surface,
      appBar: AppBar(
        backgroundColor: OpeiBrand.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Legal',
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
            _buildTopHeader(context),
            SizedBox(height: spacing * 2),
            _buildDocumentsStrip(context),
            SizedBox(height: spacing * 2),
            _section(
              context,
              'This Privacy Policy ("Policy") explains how Opei Technologies LLC ("Opei," "we," "us," or "our") collects, uses, discloses, and protects personal information in connection with your use of the Opei mobile application, website, APIs, and related services (collectively, the "Platform" or "Services").',
            ),
            _section(
              context,
              'By accessing or using Opei, you acknowledge that you have read and understood this Privacy Policy.',
            ),
            _title(context, '1. Who We Are'),
            _section(
              context,
              'Opei is a financial technology platform operated by Opei Technologies LLC, a company registered in the State of Delaware, United States.',
            ),
            _section(
              context,
              'This Privacy Policy applies to all users of the Opei Platform.',
            ),
            _title(context, '2. Information We Collect'),
            _section(
              context,
              'We collect information necessary to provide, secure, and improve the Services.',
            ),
            _subtitle(context, '2.1 Information You Provide'),
            _section(context, 'This may include:'),
            _bullets(context, const [
              'Full name',
              'Date of birth',
              'Email address',
              'Phone number',
              'Government-issued identification (for KYC)',
              'Residential address',
              'Payment details',
              'Wallet addresses',
              'Transaction-related information',
              'Communications with support',
            ]),
            _subtitle(context, '2.2 Information Collected Automatically'),
            _section(
              context,
              'When you use Opei, we may automatically collect:',
            ),
            _bullets(context, const [
              'Device information (model, OS, identifiers)',
              'IP address',
              'App usage data',
              'Log data',
              'Time and date of access',
              'Crash and performance data',
            ]),
            _subtitle(context, '2.3 Information from Third Parties'),
            _section(context, 'We may receive information from:'),
            _bullets(context, const [
              'Identity verification providers',
              'Payment processors',
              'Card issuers',
              'Mobile money providers',
              'Blockchain networks',
              'Fraud and risk monitoring services',
            ]),
            _title(context, '3. How We Use Your Information'),
            _section(context, 'We use personal information to:'),
            _bullets(context, const [
              'Provide and operate the Services',
              'Verify identity and comply with KYC requirements',
              'Process transactions',
              'Prevent fraud and abuse',
              'Comply with legal and regulatory obligations',
              'Improve product functionality',
              'Communicate with users',
              'Respond to support requests',
              'Enforce our Terms & Conditions',
            ]),
            _section(context, 'We do not sell personal data.'),
            _title(context, '4. Legal Bases for Processing'),
            _section(context, 'We process personal data based on:'),
            _bullets(context, const [
              'Performance of a contract',
              'Legal and regulatory obligations',
              'Legitimate business interests',
              'User consent (where required)',
            ]),
            _title(context, '5. Sharing & Disclosure of Information'),
            _section(context, 'We may share personal information with:'),
            _subtitle(context, '5.1 Service Providers'),
            _section(context, 'Including:'),
            _bullets(context, const [
              'KYC and identity verification providers',
              'Payment and card processing partners',
              'Mobile money operators',
              'Blockchain infrastructure providers',
              'Cloud hosting and analytics providers',
            ]),
            _section(
              context,
              'These parties process data only as necessary to provide their services.',
            ),
            _subtitle(context, '5.2 Legal & Regulatory Authorities'),
            _section(context, 'We may disclose information where required to:'),
            _bullets(context, const [
              'Comply with applicable laws',
              'Respond to lawful requests',
              'Enforce legal rights',
              'Protect users and the Platform',
            ]),
            _subtitle(context, '5.3 Business Transfers'),
            _section(
              context,
              'In the event of a merger, acquisition, reorganization, or sale of assets, personal data may be transferred as part of that transaction.',
            ),
            _title(context, '6. International Data Transfers'),
            _section(
              context,
              'Your information may be transferred to and processed in countries outside your country of residence, including the United States.',
            ),
            _section(
              context,
              'We take reasonable measures to ensure adequate data protection safeguards are in place.',
            ),
            _title(context, '7. Data Retention'),
            _section(context, 'We retain personal information:'),
            _bullets(context, const [
              'As long as necessary to provide the Services',
              'To comply with legal and regulatory obligations',
              'For fraud prevention and dispute resolution',
            ]),
            _section(
              context,
              'Retention periods may vary depending on the type of data and applicable laws.',
            ),
            _title(context, '8. Data Security'),
            _section(
              context,
              'We implement reasonable administrative, technical, and organizational measures to protect personal data against unauthorized access, loss, misuse, or alteration.',
            ),
            _section(
              context,
              'However, no system is completely secure, and we cannot guarantee absolute security.',
            ),
            _title(context, '9. Your Rights'),
            _section(
              context,
              'Depending on your jurisdiction, you may have the right to:',
            ),
            _bullets(context, const [
              'Access your personal data',
              'Correct inaccurate data',
              'Request deletion of data (subject to legal obligations)',
              'Restrict or object to processing',
              'Withdraw consent where applicable',
            ]),
            _section(
              context,
              'Requests may be subject to identity verification and legal limitations.',
            ),
            _title(context, '10. Cookies & Tracking Technologies'),
            _section(
              context,
              'Opei may use cookies or similar technologies on its website to:',
            ),
            _bullets(context, const [
              'Improve functionality',
              'Analyze usage',
              'Enhance user experience',
            ]),
            _section(
              context,
              'Mobile applications may use equivalent technologies.',
            ),
            _title(context, '11. Children\'s Privacy'),
            _section(
              context,
              'Opei is not intended for individuals under the age of 18. We do not knowingly collect personal data from minors.',
            ),
            _title(context, '12. Third-Party Links'),
            _section(
              context,
              'The Platform may contain links to third-party websites or services. We are not responsible for their privacy practices.',
            ),
            _title(context, '13. Changes to This Policy'),
            _section(
              context,
              'We may update this Privacy Policy from time to time.',
            ),
            _section(
              context,
              'Changes take effect when posted. Continued use of the Services constitutes acceptance of the updated Policy.',
            ),
            _title(context, '14. Contact Us'),
            _section(
              context,
              'If you have questions or concerns about this Privacy Policy, contact us at:',
            ),
            _contactCard(context),
            SizedBox(height: spacing * 2),
            _section(context, '© 2026 Opei Technologies LLC.'),
            _footerLinks(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
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
          child: const Text(
            'Back to Home',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: OpeiBrand.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Privacy Policy',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: OpeiBrand.ink,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Last updated: 3 January 2025',
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

  Widget _buildDocumentsStrip(BuildContext context) {
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
        children: const [
          Text(
            'Documents',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.inkSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Privacy Policy',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Terms & Conditions',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: kPrimaryFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: OpeiBrand.ink,
      ),
    ),
  );

  Widget _subtitle(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: kPrimaryFontFamily,
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        color: OpeiBrand.ink,
      ),
    ),
  );

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

  Widget _bullets(BuildContext context, List<String> items) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      color: OpeiBrand.inkSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        color: OpeiBrand.inkSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _contactCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Opei Technologies LLC",
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Email: info@opeillc.com",
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              color: OpeiBrand.inkSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "500 Westover Dr, 31775\nSanford, NC 27330\nUnited States",
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              color: OpeiBrand.inkSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Phone: +1 (681) 547-8620",
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

  Widget _footerLinks(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        GestureDetector(
          onTap: () => context.go('/privacy'),
          child: const Text(
            'Privacy Policy',
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
          child: const Text(
            'Terms & Conditions',
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
