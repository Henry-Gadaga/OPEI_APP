import 'package:flutter/material.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/l10n/app_localizations.dart';

class ErrorHelper {
  /// Locale used to resolve user-facing error copy from controllers and
  /// repositories that do not have access to a [BuildContext].
  ///
  /// Kept in sync with the active app locale by the root widget. Defaults to
  /// English until the locale has bootstrapped.
  static Locale activeLocale = const Locale('en');

  static AppLocalizations get _l10n => lookupAppLocalizations(activeLocale);
  static AppLocalizations get l10n => _l10n;

  static String getErrorMessage(dynamic error, {String? context}) {
    if (error is ApiError) {
      return _getFriendlyErrorMessage(error, context);
    }
    if (error is Exception) {
      final msg = error.toString().replaceAll('Exception: ', '');
      return _makeUserFriendly(msg, context);
    }
    return _makeUserFriendly(error.toString(), context);
  }

  static String _getFriendlyErrorMessage(ApiError error, String? context) {
    final l10n = _l10n;
    final msg = error.message.toLowerCase();

    // Compact repository/network error codes (keeps repositories language-agnostic).
    if (msg.contains('e-2001')) return l10n.errTimeoutConnection;
    if (msg.contains('e-2002')) return l10n.errUnableToConnect;
    if (msg.contains('e-2003')) return l10n.errGenericRetry;
    if (msg.contains('e-2101') ||
        msg.contains('e-2103') ||
        msg.contains('e-2104') ||
        msg.contains('e-2105') ||
        msg.contains('e-2106') ||
        msg.contains('e-2107') ||
        msg.contains('e-2201') ||
        msg.contains('e-2203') ||
        msg.contains('e-2204') ||
        msg.contains('e-2205') ||
        msg.contains('e-2206') ||
        msg.contains('e-2302') ||
        msg.contains('e-2303') ||
        msg.contains('e-2401') ||
        msg.contains('e-2402') ||
        msg.contains('e-2501') ||
        msg.contains('e-2502') ||
        msg.contains('e-2503') ||
        msg.contains('e-2504') ||
        msg.contains('e-2505') ||
        msg.contains('e-2601')) {
      return l10n.errGenericRetry;
    }
    if (msg.contains('e-2102') || msg.contains('e-2202')) {
      return l10n.errSessionExpired;
    }
    if (msg.contains('e-2301')) return l10n.referralEnterValidCodeError;
    if (msg.contains('e-2602')) return l10n.errTransferTypeWireAch;
    if (msg.contains('e-2603')) return l10n.errAccountTypeCheckingSavings;
    if (msg.contains('e-2604')) return l10n.errBeneficiaryTypeIndBus;
    if (msg.contains('e-2605')) return l10n.errAchIndividualOnly;
    if (msg.contains('e-2606')) return l10n.errRoutingDigits;
    if (msg.contains('e-2607')) return l10n.errAccountNumberDigits;

    // Network errors
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return l10n.errTimeoutConnection;
    }
    if (msg.contains('no internet') || msg.contains('connection')) {
      return l10n.errUnableToConnect;
    }

    // Authentication errors
    if (error.statusCode == 401) {
      return l10n.errSessionExpired;
    }
    if (error.statusCode == 403) {
      return l10n.errNoPermission;
    }

    // Context-specific errors for send money
    if (context == 'lookup') {
      if (error.statusCode == 404 ||
          msg.contains('recipient not found') ||
          msg.contains('not found') ||
          msg.contains('user not found')) {
        return l10n.errLookupAccountNotFound;
      }
      if (error.statusCode == 400) {
        if (msg.contains('email must be an email') ||
            msg.contains('invalid email') ||
            msg.contains('valid email')) {
          return l10n.errInvalidEmail;
        }
        if (msg.contains('validation') ||
            msg.contains('missing') ||
            msg.contains('required')) {
          return l10n.errEnterEmail;
        }
        return l10n.errInvalidEmail;
      }
      if (error.statusCode == 401 || msg.contains('unauthorized')) {
        return l10n.errSessionExpired;
      }
      if (error.statusCode == 409 ||
          (error.statusCode != null && error.statusCode! >= 500)) {
        return l10n.errServerSideShortly;
      }
      return l10n.errLookupRecipientFailed;
    }

    if (context == 'preview') {
      if (msg.contains('cannot transfer to the same wallet')) {
        return l10n.errSameWallet;
      }
      if (msg.contains('amount must be greater than zero')) {
        return l10n.errAmountAboveZero;
      }
      if (msg.contains('insufficient_funds') ||
          msg.contains('insufficient funds')) {
        return l10n.errBalanceTooLow;
      }
      if (msg.contains('fee_exceeds_amount') ||
          msg.contains('fee exceeds amount')) {
        return l10n.errFeeExceedsAmount;
      }
      if (msg.contains('sender wallet not found')) {
        return l10n.errSenderWalletNotFound;
      }
      if (msg.contains('recipient wallet not found') ||
          msg.contains('receiver wallet not found')) {
        return l10n.errRecipientWalletNotFound;
      }
      if (error.statusCode == 400 &&
          (msg.contains('validation') ||
              msg.contains('invalid') ||
              msg.contains('bad request'))) {
        return l10n.errEnterValidInfo;
      }
      return l10n.errPreviewFailed;
    }

    if (context == 'transfer') {
      if (msg.contains('cannot transfer to the same wallet')) {
        return l10n.errSameWallet;
      }
      if (msg.contains('amount must be greater than zero')) {
        return l10n.errAmountGreaterThanZero;
      }
      if (msg.contains('insufficient_funds') ||
          msg.contains('insufficient funds')) {
        return l10n.errBalanceTooLow;
      }
      if (error.statusCode == 400 &&
          (msg.contains('validation') ||
              msg.contains('invalid') ||
              msg.contains('bad request') ||
              msg.contains('['))) {
        return l10n.errCheckDetails;
      }
      if (msg.contains('sender wallet not found')) {
        return l10n.errSenderWalletNotFound;
      }
      if (msg.contains('recipient wallet not found')) {
        return l10n.errRecipientNoWallet;
      }
      if (error.statusCode == 409 || msg.contains('conflict')) {
        return l10n.errTransferAlreadyProcessed;
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return l10n.errServerSideShortly;
      }
      return l10n.errTransferFailed;
    }

    if (context == 'deposit') {
      if (error.statusCode == 401) {
        return l10n.errSessionExpired;
      }
      if (error.statusCode == 400) {
        return l10n.errInvalidRequestCheckDetails;
      }
      if (error.statusCode == 503) {
        return l10n.errServiceUnavailable;
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return l10n.errGenericRetry;
      }
    }

    if (context == 'payout') {
      if (error.statusCode == 401) {
        return l10n.errSessionExpired;
      }
      if (error.statusCode == 404) {
        if (msg.contains('beneficiary')) {
          return l10n.errReceiverNotFound;
        }
        if (msg.contains('review')) {
          return l10n.errQuoteUnavailable;
        }
        return l10n.errRecordNotFound;
      }
      if (error.statusCode == 409) {
        return l10n.errPayoutAlreadySubmitted;
      }
      if (error.statusCode == 502) {
        return l10n.errMobileMoneyUnreachable;
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return l10n.errServerSideShortly;
      }
      if (error.statusCode == 400) {
        if (msg.contains('insufficient') || msg.contains('reserve failed')) {
          return l10n.errBalanceTooLowSend;
        }
        if (msg.contains('expired') || msg.contains('inactive')) {
          return l10n.errQuoteExpired;
        }
        if (msg.contains('exchange rate') || msg.contains('rate')) {
          return l10n.errRateUnavailable;
        }
        if (msg.contains('amount')) {
          return l10n.errEnterValidAmount;
        }
        return error.message;
      }
    }

    if (context == 'us_bank') {
      if (error.statusCode == 401) {
        return l10n.errSessionExpired;
      }
      if (error.statusCode == 502) {
        if (msg.contains('provider marked') || msg.contains('failed')) {
          return l10n.errBankRejectedAccount;
        }
        return l10n.errBankNetworkUnavailable;
      }
      if (error.statusCode == 503) {
        return l10n.errBankServiceUnavailable;
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return l10n.errServerSideShortly;
      }
      if (error.statusCode == 400) {
        if (msg.contains('routing')) {
          return l10n.errRoutingDigits;
        }
        if (msg.contains('account number') || msg.contains('accountnumber')) {
          return l10n.errAccountNumberDigits;
        }
        if (msg.contains('ach') && msg.contains('business')) {
          return l10n.errAchIndividualOnly;
        }
        if (msg.contains('destination.type') ||
            msg.contains('transfer type')) {
          return l10n.errTransferTypeWireAch;
        }
        if (msg.contains('accounttype') || msg.contains('account type')) {
          return l10n.errAccountTypeCheckingSavings;
        }
        if (msg.contains('beneficiary.type') ||
            msg.contains('beneficiary type')) {
          return l10n.errBeneficiaryTypeIndBus;
        }
        if (msg.contains('country')) {
          return l10n.errCountryCode;
        }
        if (msg.contains('postcode') || msg.contains('post code')) {
          return l10n.errPostCode;
        }
        if (msg.contains('validation') ||
            msg.contains('invalid') ||
            msg.contains('bad request') ||
            msg.contains('[')) {
          return l10n.errCheckBankDetails;
        }
        return error.message;
      }
      if (msg.contains('provider marked')) {
        return l10n.errBankRejectedAccountShort;
      }
    }

    if (context == 'beneficiary') {
      if (error.statusCode == 401) {
        return l10n.errSessionExpired;
      }
      if (error.statusCode == 404) {
        return l10n.errNoReceivers;
      }
      if (error.statusCode == 502 || error.statusCode == 503) {
        return l10n.errMobileMoneyUnreachable;
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return l10n.errServerSideShortly;
      }
      if (error.statusCode == 400) {
        if (msg.contains('phone') ||
            msg.contains('account number') ||
            msg.contains('accountnumber') ||
            msg.contains('digits')) {
          return l10n.errPhoneInvalid;
        }
        if (msg.contains('network')) {
          return l10n.errNetworkUnsupported;
        }
        if (msg.contains('account name') ||
            msg.contains('accountname') ||
            msg.contains('first and last')) {
          return l10n.errReceiverFullName;
        }
        if (msg.contains('validation') ||
            msg.contains('invalid') ||
            msg.contains('bad request') ||
            msg.contains('[')) {
          return l10n.errCheckReceiverDetails;
        }
        return error.message;
      }
      if (msg.contains('provider marked beneficiary as failed') ||
          msg.contains('provider marked')) {
        return l10n.errProviderCantVerify;
      }
    }

    if (context == 'withdraw') {
      if (error.statusCode == 401) {
        return l10n.errSessionExpired;
      }
      if (error.statusCode == 503) {
        return l10n.errServiceUnavailable;
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return l10n.errGenericRetry;
      }
      if (error.statusCode == 400) {
        if (msg.contains('insufficient')) {
          return l10n.errNotEnoughBalance;
        }
        return l10n.errInvalidRequestCheckDetails;
      }
    }

    // Server errors
    if (error.statusCode != null && error.statusCode! >= 500) {
      return l10n.errServerOurEnd;
    }

    // Bad request errors
    if (error.statusCode == 400) {
      if (msg.contains('validation') || msg.contains('invalid')) {
        return l10n.errCheckInformation;
      }
      return error.message; // Return original if it's already user-friendly
    }

    // Return original message if it's already clean
    if (_isUserFriendly(error.message)) {
      return error.message;
    }

    return l10n.errGenericRetry;
  }

  static String _makeUserFriendly(String message, String? context) {
    final l10n = _l10n;
    final msg = message.toLowerCase();

    // Generic error patterns
    if (msg.contains('socketexception') || msg.contains('failed host lookup')) {
      return l10n.errUnableToConnect;
    }
    if (msg.contains('formatexception') || msg.contains('json')) {
      return l10n.errUnexpectedResponse;
    }
    if (msg.contains('timeout')) {
      return l10n.errTimeoutRetry;
    }

    // Return original if already user-friendly
    if (_isUserFriendly(message)) {
      return message;
    }

    // Default fallback
    return l10n.errGenericRetry;
  }

  static bool _isUserFriendly(String message) {
    // Check if message looks user-friendly (no stack traces, code references, etc.)
    final lowerMsg = message.toLowerCase();
    final technicalTerms = [
      'exception',
      'error:',
      'stack trace',
      'at line',
      '0x',
      'null',
      'undefined',
      'rpc',
      'http',
      'dio',
      'socket',
    ];

    for (final term in technicalTerms) {
      if (lowerMsg.contains(term)) return false;
    }

    return message.length < 150 && !message.contains('\n');
  }
}

void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: const Color(0xFFFF3B30),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ),
  );
}

void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: const Color(0xFF34C759),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ),
  );
}
