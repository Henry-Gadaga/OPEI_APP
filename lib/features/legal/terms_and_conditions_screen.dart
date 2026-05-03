import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
        padding: EdgeInsets.fromLTRB(spacing * 2, spacing * 2, spacing * 2, spacing * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopHeader(context),
            SizedBox(height: spacing * 2),
            _buildDocumentsStrip(context),
            SizedBox(height: spacing * 2),
            _section(
              context,
              'These Terms and Conditions ("Terms") govern your access to and use of the Opei mobile application, website, APIs, and related services (collectively, the "Platform" or "Services").',
            ),
            _section(
              context,
              'By creating an account, accessing, or using Opei, you confirm that you have read, understood, and agreed to be bound by these Terms. If you do not agree, you must not use the Platform.',
            ),
            _title(context, '1. About Opei'),
            _section(
              context,
              'Opei is a financial technology platform operated by Opei Technologies LLC ("Opei Technologies," "we," "us," or "our").',
            ),
            _section(
              context,
              'Opei provides software tools that enable users to access financial services offered and executed by independent third-party service providers, including but not limited to payment processors, card issuers, mobile money operators, blockchain networks, and identity verification providers.',
            ),
            _section(
              context,
              'Opei is not a bank, financial institution, money transmitter, or investment advisor. Opei does not hold customer funds, does not insure funds, and does not provide custody services except as facilitated through third-party partners.',
            ),
            _title(context, '2. Eligibility'),
            _section(context, 'To use Opei, you must:'),
            _bullets(context, const [
              'Be at least 18 years old',
              'Have legal capacity to enter into a binding agreement',
              'Provide accurate, current, and complete information',
              'Not be prohibited from using financial services under applicable laws',
            ]),
            _section(context, 'We reserve the right to refuse service to any person at any time.'),
            _title(context, '3. Account Registration'),
            _section(context, 'You agree that:'),
            _bullets(context, const [
              'You will create and maintain only one account',
              'All information you provide is accurate and truthful',
              'You will keep your login credentials secure',
              'You are responsible for all activity conducted through your account',
            ]),
            _section(context, 'You are solely responsible for maintaining the confidentiality of your account credentials.'),
            _title(context, '4. KYC, Verification & Compliance'),
            _section(context, 'Opei may require identity verification ("KYC") at any time.'),
            _section(context, 'You acknowledge that:'),
            _bullets(context, const [
              'Verification is conducted by third-party providers',
              'Verification may be delayed, rejected, or revoked',
              'Access to Services may be restricted during review',
              'Verification decisions are final',
            ]),
            _section(context, 'Opei may suspend or terminate accounts to comply with:'),
            _bullets(context, const [
              'Anti-money laundering laws',
              'Counter-terrorism financing laws',
              'Fraud prevention requirements',
              'Legal or regulatory obligations',
            ]),
            _title(context, '5. Wallet Services & Funds'),
            _section(context, 'Balances displayed on Opei are informational only and reflect data received from third-party providers.'),
            _section(context, 'You acknowledge that:'),
            _bullets(context, const [
              'Funds are processed and held by third-party partners',
              'Delays, reversals, or errors may occur',
              'Opei does not guarantee settlement times',
              'Opei is not responsible for failures or actions of third-party providers',
            ]),
            _title(context, '6. Transactions & Irreversibility'),
            _section(context, 'All transactions initiated through Opei are final and irreversible.'),
            _section(context, 'You are solely responsible for:'),
            _bullets(context, const [
              'Providing correct recipient details',
              'Entering correct amounts',
              'Providing correct wallet or payment addresses (including crypto addresses)',
              'Confirming payment receipt before releasing funds',
            ]),
            _section(context, 'Opei is not responsible for losses resulting from user error.'),
            _title(context, '7. Peer-to-Peer (P2P) Transactions'),
            _section(context, 'Peer-to-peer ("P2P") transactions facilitated through Opei are conducted directly between users. Opei is not a party to any P2P transaction and does not act as a buyer, seller, agent, broker, or escrow provider.'),
            _subtitle(context, '7.1 User Responsibility'),
            _section(context, 'You are solely responsible for:'),
            _bullets(context, const [
              'Confirming receipt of full payment',
              'Providing accurate payment details',
              'Completing all required actions within the specified timeframes',
            ]),
            _subtitle(context, '7.2 Payment Confirmation Deadline'),
            _section(context, 'If a user fails to confirm receipt of payment within thirty (30) minutes (or such other timeframe displayed in the application), the transaction may be automatically processed, cancelled, or released in accordance with platform rules.'),
            _section(context, 'Failure to confirm payment within the required timeframe may result in irreversible loss of funds.'),
            _subtitle(context, '7.3 Irreversibility'),
            _section(context, 'Once funds are released or a transaction is completed, the action is final and cannot be reversed, regardless of dispute, mistake, or misunderstanding.'),
            _subtitle(context, '7.4 No Liability for User Error'),
            _section(context, 'Opei is not responsible or liable for losses arising from:'),
            _bullets(context, const [
              'Failure to confirm payment on time',
              'Cancelling a trade after payment has been sent',
              'Releasing funds without confirming payment',
              'Disputes between users',
              'Incorrect or incomplete information provided by either party',
            ]),
            _subtitle(context, '7.5 User Disputes'),
            _section(context, 'Any dispute arising from a P2P transaction is strictly between the participating users. Opei may, at its discretion, review disputes but has no obligation to intervene or resolve them.'),
            _title(context, '8. Virtual Cards'),
            _section(context, 'Virtual cards are issued and managed by third-party providers.'),
            _section(context, 'You acknowledge that:'),
            _bullets(context, const [
              'Card availability may change',
              'Merchants may decline cards',
              'Opei does not control merchant acceptance',
              'Card transactions may be delayed or reversed',
            ]),
            _section(context, 'Opei is not responsible for merchant disputes.'),
            _title(context, '9. Fees'),
            _section(context, 'Fees may apply for certain Services.'),
            _section(context, 'You agree that:'),
            _bullets(context, const [
              'Fees may change with notice',
              'Fees are non-refundable once charged',
              'Third-party fees may apply',
            ]),
            _title(context, '10. Suspension, Freeze & Termination'),
            _section(context, 'Opei may suspend, restrict, or terminate accounts at any time for:'),
            _bullets(context, const [
              'Fraud or suspected fraud',
              'Compliance requirements',
              'Legal obligations',
              'Risk management purposes',
            ]),
            _section(context, 'Temporary freezes may occur without prior notice.'),
            _title(context, '11. User Information, Accuracy & Account Restrictions'),
            _section(context, 'You agree to provide accurate, complete, and truthful information at all times, including:'),
            _bullets(context, const [
              'Personal identification details',
              'Payment details',
              'Wallet addresses',
              'Bank or mobile money information',
            ]),
            _section(context, 'You acknowledge that:'),
            _bullets(context, const [
              'Incorrect or misleading information may result in failed transactions or loss of funds',
              'Opei is not responsible for losses caused by incorrect details provided by users',
              'Opei may suspend, restrict, or permanently block accounts for compliance, security, or risk reasons',
            ]),
            _title(context, '12. User Responsibilities'),
            _section(context, 'You agree not to:'),
            _bullets(context, const [
              'Use Opei for illegal purposes',
              'Circumvent platform controls',
              'Misrepresent information',
              'Exploit system vulnerabilities',
            ]),
            _section(context, 'You are responsible for all actions taken using your account.'),
            _title(context, '13. Third-Party Services'),
            _section(context, 'Opei relies on third-party providers.'),
            _section(context, 'We do not control and are not responsible for:'),
            _bullets(context, const [
              'Downtime',
              'Errors',
              'Security incidents',
              'Service interruptions',
            ]),
            _section(context, 'Use of third-party services is at your own risk.'),
            _title(context, '14. Disclaimers'),
            _section(context, 'THE SERVICES ARE PROVIDED "AS IS" AND "AS AVAILABLE."'),
            _section(context, 'WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF:'),
            _bullets(context, const [
              'MERCHANTABILITY',
              'FITNESS FOR A PARTICULAR PURPOSE',
              'NON-INFRINGEMENT',
            ]),
            _section(context, 'WE DO NOT GUARANTEE AVAILABILITY, PERFORMANCE, OR RESULTS.'),
            _title(context, '15. Limitation of Liability'),
            _section(context, 'TO THE MAXIMUM EXTENT PERMITTED BY LAW, OPEI AND OPEI TECHNOLOGIES SHALL NOT BE LIABLE FOR:'),
            _bullets(context, const [
              'INDIRECT OR CONSEQUENTIAL DAMAGES',
              'LOSS OF PROFITS',
              'LOSS OF DATA',
              'USER ERRORS',
              'THIRD-PARTY FAILURES',
            ]),
            _section(context, 'TOTAL LIABILITY SHALL NOT EXCEED THE FEES PAID BY YOU IN THE PRECEDING TWELVE (12) MONTHS.'),
            _title(context, '16. Indemnification'),
            _section(context, 'You agree to indemnify and hold harmless Opei and Opei Technologies from claims arising from:'),
            _bullets(context, const [
              'Your use of the Services',
              'Your violation of these Terms',
              'Your violation of applicable law',
            ]),
            _title(context, '17. Service Availability'),
            _section(context, 'Opei does not guarantee uninterrupted access to the Services and may suspend, modify, or discontinue any part of the Platform at any time without liability.'),
            _title(context, '18. Inactive Accounts'),
            _section(context, 'Accounts with prolonged inactivity may be restricted, suspended, or closed in accordance with applicable laws and partner requirements.'),
            _title(context, '19. Assignment'),
            _section(context, 'Opei may assign or transfer these Terms, in whole or in part, without restriction. Users may not assign their rights without prior written consent.'),
            _title(context, '20. Entire Agreement'),
            _section(context, 'These Terms constitute the entire agreement between you and Opei and supersede all prior agreements or communications.'),
            _title(context, '21. Force Majeure'),
            _section(context, 'Opei shall not be liable for any failure or delay in performance resulting from events beyond its reasonable control, including but not limited to acts of God, power outages, internet or system failures, labor disputes, governmental actions, war, terrorism, natural disasters, or failures of third-party service providers.'),
            _title(context, '22. Privacy'),
            _section(context, 'Your use of Opei is governed by our Privacy Policy, which explains how personal data is collected and processed.'),
            _title(context, '23. Changes to Terms'),
            _section(context, 'We may update these Terms at any time. Continued use of the Services constitutes acceptance of updated Terms.'),
            _title(context, '24. Governing Law & Jurisdiction'),
            _section(context, 'These Terms are governed by the laws of the State of Delaware, United States, without regard to conflict-of-law principles.'),
            _title(context, '25. Severability'),
            _section(context, 'If any provision of these Terms is found invalid or unenforceable, the remaining provisions shall remain in full force and effect.'),
            _title(context, '26. Contact Information'),
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
          'Terms & Conditions',
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
            style: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 13.5, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Text(
            'Terms & Conditions',
            style: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 13.5, fontWeight: FontWeight.w600),
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
                      const Text('• ', style: TextStyle(fontFamily: kPrimaryFontFamily, color: OpeiBrand.inkSecondary)),
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
          Text('Opei Technologies LLC', style: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 14.5, fontWeight: FontWeight.w700, color: OpeiBrand.ink)),
          SizedBox(height: 8),
          Text('Support Email: info@opeillc.com', style: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 13.5, color: OpeiBrand.inkSecondary)),
          SizedBox(height: 4),
          Text('500 Westover Dr, 31775\nSanford, NC 27330\nUnited States', style: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 13.5, color: OpeiBrand.inkSecondary, height: 1.4)),
          SizedBox(height: 4),
          Text('Phone: +1 (681) 547-8620', style: TextStyle(fontFamily: kPrimaryFontFamily, fontSize: 13.5, color: OpeiBrand.inkSecondary)),
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
