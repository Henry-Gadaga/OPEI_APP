import 'package:flutter/material.dart';

import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

/// Tiny trust strip used at the bottom of auth/onboarding screens.
/// "🔒 Bank-grade encryption" — small, calm, never shouty.
class OpeiTrustFooter extends StatelessWidget {
  final String? label;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const OpeiTrustFooter({
    super.key,
    this.label,
    this.icon = Icons.lock_rounded,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: OpeiBrand.inkTertiary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label ??
                  AppLocalizations.of(context)!.trustFooterBankGradeEncryption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkTertiary,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
