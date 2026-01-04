import 'package:flutter/material.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.responsiveSpacingUnit;

    return ResponsiveScaffold(
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: spacing * 2,
          vertical: spacing * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OPEI PRIVACY POLICY',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OpeiColors.pureBlack,
                  ),
            ),
            SizedBox(height: spacing),
            Text(
              'Last Updated: 3 January 2025',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OpeiColors.grey600,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            SizedBox(height: spacing * 2),
            _buildParagraph(
              context,
              'This Privacy Policy ("Policy") explains how Yege Technologies LLC ("Yege Technologies," "we," "us," or "our") collects, uses, discloses, and protects personal information in connection with your use of the Opei mobile application, website, APIs, and related services (collectively, the "Platform" or "Services").',
            ),
            _buildParagraph(
              context,
              'By accessing or using Opei, you acknowledge that you have read and understood this Privacy Policy.',
            ),
            SizedBox(height: spacing * 2),
            _buildSection(context, '1. WHO WE ARE', [
              'Opei is a financial technology platform operated by Yege Technologies LLC, a company registered in the State of Delaware, United States.',
              'This Privacy Policy applies to all users of the Opei Platform.',
            ]),
            _buildSection(context, '2. INFORMATION WE COLLECT', [
              'We collect information necessary to provide, secure, and improve the Services.',
            ]),
            _buildSubsection(context, '2.1 Information You Provide', [
              'This may include:',
            ]),
            _buildBulletList(context, [
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
            _buildSubsection(context, '2.2 Information Collected Automatically', [
              'When you use Opei, we may automatically collect:',
            ]),
            _buildBulletList(context, [
              'Device information (model, OS, identifiers)',
              'IP address',
              'App usage data',
              'Log data',
              'Time and date of access',
              'Crash and performance data',
            ]),
            _buildSubsection(context, '2.3 Information from Third Parties', [
              'We may receive information from:',
            ]),
            _buildBulletList(context, [
              'Identity verification providers',
              'Payment processors',
              'Card issuers',
              'Mobile money providers',
              'Blockchain networks',
              'Fraud and risk monitoring services',
            ]),
            _buildSection(context, '3. HOW WE USE YOUR INFORMATION', [
              'We use personal information to:',
            ]),
            _buildBulletList(context, [
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
            _buildParagraph(context, 'We do not sell personal data.'),
            _buildSection(context, '4. LEGAL BASES FOR PROCESSING', [
              'We process personal data based on:',
            ]),
            _buildBulletList(context, [
              'Performance of a contract',
              'Legal and regulatory obligations',
              'Legitimate business interests',
              'User consent (where required)',
            ]),
            _buildSection(context, '5. SHARING & DISCLOSURE OF INFORMATION', [
              'We may share personal information with:',
            ]),
            _buildSubsection(context, '5.1 Service Providers', [
              'Including:',
            ]),
            _buildBulletList(context, [
              'KYC and identity verification providers',
              'Payment and card processing partners',
              'Mobile money operators',
              'Blockchain infrastructure providers',
              'Cloud hosting and analytics providers',
            ]),
            _buildParagraph(
                context, 'These parties process data only as necessary to provide their services.'),
            _buildSubsection(context, '5.2 Legal & Regulatory Authorities', [
              'We may disclose information where required to:',
            ]),
            _buildBulletList(context, [
              'Comply with applicable laws',
              'Respond to lawful requests',
              'Enforce legal rights',
              'Protect users and the Platform',
            ]),
            _buildSubsection(context, '5.3 Business Transfers', [
              'In the event of a merger, acquisition, reorganization, or sale of assets, personal data may be transferred as part of that transaction.',
            ]),
            _buildSection(context, '6. INTERNATIONAL DATA TRANSFERS', [
              'Your information may be transferred to and processed in countries outside your country of residence, including the United States.',
              'We take reasonable measures to ensure adequate data protection safeguards are in place.',
            ]),
            _buildSection(context, '7. DATA RETENTION', [
              'We retain personal information:',
            ]),
            _buildBulletList(context, [
              'As long as necessary to provide the Services',
              'To comply with legal and regulatory obligations',
              'For fraud prevention and dispute resolution',
            ]),
            _buildParagraph(
              context,
              'Retention periods may vary depending on the type of data and applicable laws.',
            ),
            _buildSection(context, '8. DATA SECURITY', [
              'We implement reasonable administrative, technical, and organizational measures to protect personal data against unauthorized access, loss, misuse, or alteration.',
              'However, no system is completely secure, and we cannot guarantee absolute security.',
            ]),
            _buildSection(context, '9. YOUR RIGHTS', [
              'Depending on your jurisdiction, you may have the right to:',
            ]),
            _buildBulletList(context, [
              'Access your personal data',
              'Correct inaccurate data',
              'Request deletion of data (subject to legal obligations)',
              'Restrict or object to processing',
              'Withdraw consent where applicable',
            ]),
            _buildParagraph(
              context,
              'Requests may be subject to identity verification and legal limitations.',
            ),
            _buildSection(context, '10. COOKIES & TRACKING TECHNOLOGIES', [
              'Opei may use cookies or similar technologies on its website to:',
            ]),
            _buildBulletList(context, [
              'Improve functionality',
              'Analyze usage',
              'Enhance user experience',
            ]),
            _buildParagraph(context, 'Mobile applications may use equivalent technologies.'),
            _buildSection(context, '11. CHILDREN\'S PRIVACY', [
              'Opei is not intended for individuals under the age of 18. We do not knowingly collect personal data from minors.',
            ]),
            _buildSection(context, '12. THIRD-PARTY LINKS', [
              'The Platform may contain links to third-party websites or services. We are not responsible for their privacy practices.',
            ]),
            _buildSection(context, '13. CHANGES TO THIS POLICY', [
              'We may update this Privacy Policy from time to time.',
              'Changes take effect when posted. Continued use of the Services constitutes acceptance of the updated Policy.',
            ]),
            _buildSection(context, '14. CONTACT US', [
              'If you have questions or concerns about this Privacy Policy, contact us at:',
            ]),
            _buildContactInfo(context),
            SizedBox(height: spacing * 4),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> paragraphs) {
    final spacing = context.responsiveSpacingUnit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing * 2),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: OpeiColors.pureBlack,
              ),
        ),
        SizedBox(height: spacing),
        ...paragraphs.map((p) => _buildParagraph(context, p)),
      ],
    );
  }

  Widget _buildSubsection(BuildContext context, String title, List<String> paragraphs) {
    final spacing = context.responsiveSpacingUnit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing * 1.5),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: OpeiColors.pureBlack,
              ),
        ),
        SizedBox(height: spacing * 0.5),
        ...paragraphs.map((p) => _buildParagraph(context, p)),
      ],
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    final spacing = context.responsiveSpacingUnit;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: OpeiColors.grey700,
              height: 1.6,
            ),
      ),
    );
  }

  Widget _buildBulletList(BuildContext context, List<String> items) {
    final spacing = context.responsiveSpacingUnit;
    return Padding(
      padding: EdgeInsets.only(left: spacing * 2, bottom: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: spacing * 0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: OpeiColors.grey700,
                      ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: OpeiColors.grey700,
                          height: 1.6,
                        ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    final spacing = context.responsiveSpacingUnit;
    return Container(
      padding: EdgeInsets.all(spacing * 2),
      decoration: BoxDecoration(
        color: OpeiColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yege Technologies LLC',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: OpeiColors.pureBlack,
                ),
          ),
          SizedBox(height: spacing),
          _buildContactRow(context, 'Email:', 'info@yegetechnologies.com'),
          _buildContactRow(context, 'Address:', '8 The Green STE A\nDover, Delaware, 19901\nUnited States'),
          _buildContactRow(context, 'Phone:', '+1 (202) 773-8179'),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, String label, String value) {
    final spacing = context.responsiveSpacingUnit;
    return Padding(
      padding: EdgeInsets.only(bottom: spacing * 0.75),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OpeiColors.grey600,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: OpeiColors.grey700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
