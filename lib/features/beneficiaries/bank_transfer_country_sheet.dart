import 'package:flutter/material.dart';
import 'package:opei/core/navigation/opei_page_transitions.dart';
import 'package:opei/features/beneficiaries/us_bank/us_bank_receivers_screen.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

/// Bank-Transfer country picker. Only the US is enabled for now; more
/// corridors get appended here as they roll out.
class BankTransferCountrySheet extends StatelessWidget {
  const BankTransferCountrySheet({super.key});

  static const _countries = [
    ('🇺🇸', 'United States', 'US'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: OpeiBrand.hairlineStrong,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 22),

          // Header
          Text(
            AppLocalizations.of(context)!.addressSelectCountryTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.4,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            AppLocalizations.of(context)!.bankTransferCountriesSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: OpeiBrand.inkSecondary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 22),

          const Divider(
              height: 1, thickness: 0.5, color: OpeiBrand.hairline),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _countries.length,
            separatorBuilder: (context, i) => const Divider(
              height: 1,
              thickness: 0.5,
              color: OpeiBrand.hairline,
            ),
            itemBuilder: (context, i) {
              final (flag, name, code) = _countries[i];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    if (code == 'US') {
                      navigator.push(
                        OpeiPageRoute(
                          builder: (_) => const UsBankReceiversScreen(),
                        ),
                      );
                    }
                  },
                  splashColor: OpeiBrand.primary.withValues(alpha: 0.04),
                  highlightColor: OpeiBrand.surfaceMuted,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Text(
                          flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: OpeiBrand.ink,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: OpeiBrand.inkTertiary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(
              height: 1, thickness: 0.5, color: OpeiBrand.hairline),

          SizedBox(height: 16 + bottomPadding),
        ],
      ),
    );
  }
}
