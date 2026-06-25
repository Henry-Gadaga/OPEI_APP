class ReferralCodeParser {
  ReferralCodeParser._();

  static final RegExp _urlPattern = RegExp(
    r'(?:https?:\/\/)?(?:www\.)?opei\.app\/r\/([A-Za-z0-9]+)',
    caseSensitive: false,
  );

  static final RegExp _codePattern = RegExp(r'^[A-Za-z0-9]+$');

  static String normalize(String rawInput) {
    final input = rawInput.trim();
    if (input.isEmpty) return '';

    final urlMatch = _urlPattern.firstMatch(input);
    final extracted = urlMatch?.group(1) ?? input;
    final normalized = extracted.trim().toUpperCase();

    if (normalized.isEmpty) return '';
    if (!_codePattern.hasMatch(normalized)) return '';
    return normalized;
  }
}
