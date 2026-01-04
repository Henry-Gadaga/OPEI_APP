import 'package:flutter/material.dart';
import 'package:opei/responsive/responsive_widgets.dart';
import 'package:opei/responsive/responsive_tokens.dart';
import 'package:opei/theme.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
          'Terms & Conditions',
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
              'OPEI TERMS AND CONDITIONS',
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
              'These Terms and Conditions ("Terms") govern your access to and use of the Opei mobile application, website, APIs, and related services (collectively, the "Platform" or "Services").',
            ),
            _buildParagraph(
              context,
              'By creating an account, accessing, or using Opei, you confirm that you have read, understood, and agreed to be bound by these Terms. If you do not agree, you must not use the Platform.',
            ),
            SizedBox(height: spacing * 2),
            _buildSection(context, '1. ABOUT OPEI', [
              'Opei is a financial technology platform operated by Yege Technologies LLC ("Yege Technologies," "we," "us," or "our").',
              'Opei provides software tools that enable users to access financial services offered and executed by independent third-party service providers, including but not limited to payment processors, card issuers, mobile money operators, blockchain networks, and identity verification providers.',
              'Opei is not a bank, financial institution, money transmitter, or investment advisor. Opei does not hold customer funds, does not insure funds, and does not provide custody services except as facilitated through third-party partners.',
            ]),
            _buildSection(context, '2. ELIGIBILITY', [
              'To use Opei, you must:',
            ]),
            _buildBulletList(context, [
              'Be at least 18 years old',
              'Have legal capacity to enter into a binding agreement',
              'Provide accurate, current, and complete information',
              'Not be prohibited from using financial services under applicable laws',
            ]),
            _buildParagraph(
                context, 'We reserve the right to refuse service to any person at any time.'),
            _buildSection(context, '3. ACCOUNT REGISTRATION', [
              'You agree that:',
            ]),
            _buildBulletList(context, [
              'You will create and maintain only one account',
              'All information you provide is accurate and truthful',
              'You will keep your login credentials secure',
              'You are responsible for all activity conducted through your account',
            ]),
            _buildParagraph(
              context,
              'You are solely responsible for maintaining the confidentiality of your account credentials.',
            ),
            _buildSection(context, '4. KYC, VERIFICATION & COMPLIANCE', [
              'Opei may require identity verification ("KYC") at any time.',
              'You acknowledge that:',
            ]),
            _buildBulletList(context, [
              'Verification is conducted by third-party providers',
              'Verification may be delayed, rejected, or revoked',
              'Access to Services may be restricted during review',
              'Verification decisions are final',
            ]),
            _buildParagraph(
                context, 'Opei may suspend or terminate accounts to comply with:'),
            _buildBulletList(context, [
              'Anti-money laundering laws',
              'Counter-terrorism financing laws',
              'Fraud prevention requirements',
              'Legal or regulatory obligations',
            ]),
            _buildSection(context, '5. WALLET SERVICES & FUNDS', [
              'Balances displayed on Opei are informational only and reflect data received from third-party providers.',
              'You acknowledge that:',
            ]),
            _buildBulletList(context, [
              'Funds are processed and held by third-party partners',
              'Delays, reversals, or errors may occur',
              'Opei does not guarantee settlement times',
              'Opei is not responsible for failures or actions of third-party providers',
            ]),
            _buildSection(context, '6. TRANSACTIONS & IRREVERSIBILITY', [
              'All transactions initiated through Opei are final and irreversible.',
              'You are solely responsible for:',
            ]),
            _buildBulletList(context, [
              'Providing correct recipient details',
              'Entering correct amounts',
              'Providing correct wallet or payment addresses (including crypto addresses)',
              'Confirming payment receipt before releasing funds',
            ]),
            _buildParagraph(context, 'Opei is not responsible for losses resulting from user error.'),
            _buildSection(context, '7. PEER-TO-PEER (P2P) TRANSACTIONS', [
              'Peer-to-peer ("P2P") transactions facilitated through Opei are conducted directly between users. Opei is not a party to any P2P transaction and does not act as a buyer, seller, agent, broker, or escrow provider.',
              'You acknowledge and agree that:',
            ]),
            _buildSubsection(context, '7.1 User Responsibility', [
              'You are solely responsible for:',
            ]),
            _buildBulletList(context, [
              'Confirming receipt of full payment',
              'Providing accurate payment details',
              'Completing all required actions within the specified timeframes',
            ]),
            _buildSubsection(context, '7.2 Payment Confirmation Deadline', [
              'If a user fails to confirm receipt of payment within thirty (30) minutes (or such other timeframe displayed in the application), the transaction may be automatically processed, cancelled, or released in accordance with platform rules.',
              'Failure to confirm payment within the required timeframe may result in irreversible loss of funds.',
            ]),
            _buildSubsection(context, '7.3 Irreversibility', [
              'Once funds are released or a transaction is completed, the action is final and cannot be reversed, regardless of dispute, mistake, or misunderstanding.',
            ]),
            _buildSubsection(context, '7.4 No Liability for User Error', [
              'Opei is not responsible or liable for losses arising from:',
            ]),
            _buildBulletList(context, [
              'Failure to confirm payment on time',
              'Cancelling a trade after payment has been sent',
              'Releasing funds without confirming payment',
              'Disputes between users',
              'Incorrect or incomplete information provided by either party',
            ]),
            _buildSubsection(context, '7.5 User Disputes', [
              'Any dispute arising from a P2P transaction is strictly between the participating users. Opei may, at its discretion, review disputes but has no obligation to intervene or resolve them.',
            ]),
            _buildSection(context, '8. VIRTUAL CARDS', [
              'Virtual cards are issued and managed by third-party providers.',
              'You acknowledge that:',
            ]),
            _buildBulletList(context, [
              'Card availability may change',
              'Merchants may decline cards',
              'Opei does not control merchant acceptance',
              'Card transactions may be delayed or reversed',
            ]),
            _buildParagraph(context, 'Opei is not responsible for merchant disputes.'),
            _buildSection(context, '9. FEES', [
              'Fees may apply for certain Services.',
              'You agree that:',
            ]),
            _buildBulletList(context, [
              'Fees may change with notice',
              'Fees are non-refundable once charged',
              'Third-party fees may apply',
            ]),
            _buildSection(context, '10. SUSPENSION, FREEZE & TERMINATION', [
              'Opei may suspend, restrict, or terminate accounts at any time for:',
            ]),
            _buildBulletList(context, [
              'Fraud or suspected fraud',
              'Compliance requirements',
              'Legal obligations',
              'Risk management purposes',
            ]),
            _buildParagraph(context, 'Temporary freezes may occur without prior notice.'),
            _buildSection(
                context, '11. USER INFORMATION, ACCURACY & ACCOUNT RESTRICTIONS', [
              'You agree to provide accurate, complete, and truthful information at all times, including:',
            ]),
            _buildBulletList(context, [
              'Personal identification details',
              'Payment details',
              'Wallet addresses',
              'Bank or mobile money information',
            ]),
            _buildParagraph(context, 'You acknowledge that:'),
            _buildBulletList(context, [
              'Incorrect or misleading information may result in failed transactions or loss of funds',
              'Opei is not responsible for losses caused by incorrect details provided by users',
              'Opei may suspend, restrict, or permanently block accounts for compliance, security, or risk reasons',
            ]),
            _buildSection(context, '12. USER RESPONSIBILITIES', [
              'You agree not to:',
            ]),
            _buildBulletList(context, [
              'Use Opei for illegal purposes',
              'Circumvent platform controls',
              'Misrepresent information',
              'Exploit system vulnerabilities',
            ]),
            _buildParagraph(
                context, 'You are responsible for all actions taken using your account.'),
            _buildSection(context, '13. THIRD-PARTY SERVICES', [
              'Opei relies on third-party providers.',
              'We do not control and are not responsible for:',
            ]),
            _buildBulletList(context, [
              'Downtime',
              'Errors',
              'Security incidents',
              'Service interruptions',
            ]),
            _buildParagraph(context, 'Use of third-party services is at your own risk.'),
            _buildSection(context, '14. DISCLAIMERS', [
              'THE SERVICES ARE PROVIDED "AS IS" AND "AS AVAILABLE."',
              'WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF:',
            ]),
            _buildBulletList(context, [
              'MERCHANTABILITY',
              'FITNESS FOR A PARTICULAR PURPOSE',
              'NON-INFRINGEMENT',
            ]),
            _buildParagraph(context, 'WE DO NOT GUARANTEE AVAILABILITY, PERFORMANCE, OR RESULTS.'),
            _buildSection(context, '15. LIMITATION OF LIABILITY', [
              'TO THE MAXIMUM EXTENT PERMITTED BY LAW, OPEI AND YEGE TECHNOLOGIES SHALL NOT BE LIABLE FOR:',
            ]),
            _buildBulletList(context, [
              'INDIRECT OR CONSEQUENTIAL DAMAGES',
              'LOSS OF PROFITS',
              'LOSS OF DATA',
              'USER ERRORS',
              'THIRD-PARTY FAILURES',
            ]),
            _buildParagraph(
              context,
              'TOTAL LIABILITY SHALL NOT EXCEED THE FEES PAID BY YOU IN THE PRECEDING TWELVE (12) MONTHS.',
            ),
            _buildSection(context, '16. INDEMNIFICATION', [
              'You agree to indemnify and hold harmless Opei and Yege Technologies from claims arising from:',
            ]),
            _buildBulletList(context, [
              'Your use of the Services',
              'Your violation of these Terms',
              'Your violation of applicable law',
            ]),
            _buildSection(context, '17. SERVICE AVAILABILITY', [
              'Opei does not guarantee uninterrupted access to the Services and may suspend, modify, or discontinue any part of the Platform at any time without liability.',
            ]),
            _buildSection(context, '18. INACTIVE ACCOUNTS', [
              'Accounts with prolonged inactivity may be restricted, suspended, or closed in accordance with applicable laws and partner requirements.',
            ]),
            _buildSection(context, '19. ASSIGNMENT', [
              'Opei may assign or transfer these Terms, in whole or in part, without restriction. Users may not assign their rights without prior written consent.',
            ]),
            _buildSection(context, '20. ENTIRE AGREEMENT', [
              'These Terms constitute the entire agreement between you and Opei and supersede all prior agreements or communications.',
            ]),
            _buildSection(context, '21. FORCE MAJEURE', [
              'Opei shall not be liable for any failure or delay in performance resulting from events beyond its reasonable control, including but not limited to acts of God, power outages, internet or system failures, labor disputes, governmental actions, war, terrorism, natural disasters, or failures of third-party service providers.',
            ]),
            _buildSection(context, '22. PRIVACY', [
              'Your use of Opei is governed by our Privacy Policy, which explains how personal data is collected and processed.',
            ]),
            _buildSection(context, '23. CHANGES TO TERMS', [
              'We may update these Terms at any time. Continued use of the Services constitutes acceptance of updated Terms.',
            ]),
            _buildSection(context, '24. GOVERNING LAW & JURISDICTION', [
              'These Terms are governed by the laws of the State of Delaware, United States, without regard to conflict-of-law principles.',
            ]),
            _buildSection(context, '25. SEVERABILITY', [
              'If any provision of these Terms is found invalid or unenforceable, the remaining provisions shall remain in full force and effect.',
            ]),
            _buildSection(context, '26. CONTACT INFORMATION', []),
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
