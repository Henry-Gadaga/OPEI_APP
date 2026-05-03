/// Phone dial-code metadata used by the signup phone picker.
///
/// `minDigits` / `maxDigits` refer to the **national subscriber number**
/// (i.e. what the user types AFTER the dial code). Set generously where
/// numbering plans vary; tighter for the most common signup countries.
class CountryDial {
  final String iso;
  final String dialCode; // e.g. "234" — without leading +
  final int minDigits;
  final int maxDigits;
  final String emoji; // 🇳🇬 etc. (kept here so we don't recompute every build)

  const CountryDial({
    required this.iso,
    required this.dialCode,
    required this.minDigits,
    required this.maxDigits,
    required this.emoji,
  });
}

/// Convert a 2-letter ISO into a flag emoji (🇺🇸, 🇳🇬, etc.).
/// Falls back to an empty string if the ISO is malformed.
String _flagEmoji(String iso) {
  if (iso.length != 2) return '';
  final upper = iso.toUpperCase();
  final base = 0x1F1E6; // 🇦
  final a = 'A'.codeUnitAt(0);
  return String.fromCharCodes(
    upper.codeUnits.map((c) => base + (c - a)),
  );
}

/// Concise list — covers all African countries + major global markets.
/// Anything missing falls back to [_kDefaultDial].
const CountryDial _kDefaultDial = CountryDial(
  iso: 'XX',
  dialCode: '',
  minDigits: 5,
  maxDigits: 15,
  emoji: '🌍',
);

final Map<String, CountryDial> kDialCodes = {
  for (final c in _rawDialCodes)
    c.iso: CountryDial(
      iso: c.iso,
      dialCode: c.dialCode,
      minDigits: c.minDigits,
      maxDigits: c.maxDigits,
      emoji: _flagEmoji(c.iso),
    ),
};

CountryDial dialCodeFor(String iso) =>
    kDialCodes[iso.toUpperCase()] ?? _kDefaultDial;

/// Default ISO to highlight at the top of the picker.
const String kDefaultDialIso = 'US';

// Source data — kept terse on purpose. Numbering-plan ranges sourced from
// ITU E.164 + Wikipedia. For unlisted countries we'll fall back to (5..15).
class _RawDial {
  final String iso;
  final String dialCode;
  final int minDigits;
  final int maxDigits;
  const _RawDial(this.iso, this.dialCode, this.minDigits, this.maxDigits);
}

const List<_RawDial> _rawDialCodes = [
  // -------- Africa --------
  _RawDial('DZ', '213', 9, 9),
  _RawDial('AO', '244', 9, 9),
  _RawDial('BJ', '229', 8, 8),
  _RawDial('BW', '267', 7, 8),
  _RawDial('BF', '226', 8, 8),
  _RawDial('BI', '257', 8, 8),
  _RawDial('CM', '237', 9, 9),
  _RawDial('CV', '238', 7, 7),
  _RawDial('CF', '236', 8, 8),
  _RawDial('TD', '235', 8, 8),
  _RawDial('KM', '269', 7, 7),
  _RawDial('CG', '242', 9, 9),
  _RawDial('CD', '243', 9, 9),
  _RawDial('CI', '225', 10, 10),
  _RawDial('DJ', '253', 8, 8),
  _RawDial('EG', '20', 10, 10),
  _RawDial('GQ', '240', 9, 9),
  _RawDial('ER', '291', 7, 7),
  _RawDial('SZ', '268', 8, 8),
  _RawDial('ET', '251', 9, 9),
  _RawDial('GA', '241', 7, 8),
  _RawDial('GM', '220', 7, 7),
  _RawDial('GH', '233', 9, 9),
  _RawDial('GN', '224', 8, 9),
  _RawDial('GW', '245', 7, 7),
  _RawDial('KE', '254', 9, 9),
  _RawDial('LS', '266', 8, 8),
  _RawDial('LR', '231', 7, 8),
  _RawDial('LY', '218', 9, 10),
  _RawDial('MG', '261', 9, 9),
  _RawDial('MW', '265', 9, 9),
  _RawDial('ML', '223', 8, 8),
  _RawDial('MR', '222', 8, 8),
  _RawDial('MU', '230', 7, 8),
  _RawDial('MA', '212', 9, 9),
  _RawDial('MZ', '258', 9, 9),
  _RawDial('NA', '264', 9, 9),
  _RawDial('NE', '227', 8, 8),
  _RawDial('NG', '234', 10, 10),
  _RawDial('RW', '250', 9, 9),
  _RawDial('ST', '239', 7, 7),
  _RawDial('SN', '221', 9, 9),
  _RawDial('SC', '248', 7, 7),
  _RawDial('SL', '232', 8, 8),
  _RawDial('SO', '252', 7, 8),
  _RawDial('ZA', '27', 9, 9),
  _RawDial('SS', '211', 9, 9),
  _RawDial('SD', '249', 9, 9),
  _RawDial('TZ', '255', 9, 9),
  _RawDial('TG', '228', 8, 8),
  _RawDial('TN', '216', 8, 8),
  _RawDial('UG', '256', 9, 9),
  _RawDial('ZM', '260', 9, 9),
  _RawDial('ZW', '263', 9, 9),

  // -------- North America --------
  _RawDial('US', '1', 10, 10),
  _RawDial('CA', '1', 10, 10),
  _RawDial('MX', '52', 10, 10),

  // -------- Europe --------
  _RawDial('GB', '44', 10, 10),
  _RawDial('IE', '353', 9, 9),
  _RawDial('FR', '33', 9, 9),
  _RawDial('DE', '49', 10, 11),
  _RawDial('ES', '34', 9, 9),
  _RawDial('IT', '39', 9, 10),
  _RawDial('NL', '31', 9, 9),
  _RawDial('BE', '32', 8, 9),
  _RawDial('PT', '351', 9, 9),
  _RawDial('CH', '41', 9, 9),
  _RawDial('AT', '43', 10, 11),
  _RawDial('SE', '46', 7, 9),
  _RawDial('NO', '47', 8, 8),
  _RawDial('DK', '45', 8, 8),
  _RawDial('FI', '358', 9, 10),
  _RawDial('PL', '48', 9, 9),
  _RawDial('GR', '30', 10, 10),
  _RawDial('TR', '90', 10, 10),

  // -------- Middle East --------
  _RawDial('AE', '971', 9, 9),
  _RawDial('SA', '966', 9, 9),
  _RawDial('QA', '974', 8, 8),
  _RawDial('KW', '965', 8, 8),
  _RawDial('BH', '973', 8, 8),
  _RawDial('OM', '968', 8, 8),
  _RawDial('IL', '972', 8, 9),
  _RawDial('JO', '962', 8, 9),
  _RawDial('LB', '961', 7, 8),
  _RawDial('IQ', '964', 9, 10),
  _RawDial('IR', '98', 10, 10),
  _RawDial('SY', '963', 8, 9),
  _RawDial('YE', '967', 7, 9),

  // -------- Asia --------
  _RawDial('IN', '91', 10, 10),
  _RawDial('PK', '92', 10, 10),
  _RawDial('BD', '880', 10, 10),
  _RawDial('LK', '94', 9, 9),
  _RawDial('NP', '977', 10, 10),
  _RawDial('CN', '86', 11, 11),
  _RawDial('JP', '81', 10, 10),
  _RawDial('KR', '82', 9, 10),
  _RawDial('SG', '65', 8, 8),
  _RawDial('MY', '60', 9, 10),
  _RawDial('TH', '66', 9, 9),
  _RawDial('ID', '62', 9, 12),
  _RawDial('PH', '63', 10, 10),
  _RawDial('VN', '84', 9, 10),

  // -------- Oceania --------
  _RawDial('AU', '61', 9, 9),
  _RawDial('NZ', '64', 8, 9),

  // -------- Latin America --------
  _RawDial('BR', '55', 10, 11),
  _RawDial('AR', '54', 10, 11),
  _RawDial('CL', '56', 9, 9),
  _RawDial('CO', '57', 10, 10),
  _RawDial('PE', '51', 9, 9),
  _RawDial('VE', '58', 10, 10),
  _RawDial('UY', '598', 8, 9),
  _RawDial('PY', '595', 9, 9),
  _RawDial('EC', '593', 9, 9),
  _RawDial('BO', '591', 8, 8),
];
