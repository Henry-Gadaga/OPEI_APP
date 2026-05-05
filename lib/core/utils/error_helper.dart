import 'package:flutter/material.dart';
import 'package:opei/core/network/api_error.dart';

class ErrorHelper {
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
    final msg = error.message.toLowerCase();
    
    // Network errors
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'The request took too long. Please check your connection and try again.';
    }
    if (msg.contains('no internet') || msg.contains('connection')) {
      return 'Unable to connect. Please check your internet connection.';
    }
    
    // Authentication errors
    if (error.statusCode == 401) {
      return 'Your session expired. Please sign in again.';
    }
    if (error.statusCode == 403) {
      return 'You do not have permission to perform this action.';
    }
    
    // Context-specific errors for send money
    if (context == 'lookup') {
      // 404 - Recipient not found
      if (error.statusCode == 404 || msg.contains('recipient not found') || msg.contains('not found') || msg.contains('user not found')) {
        return 'We could not find an account with that email address.';
      }
      // 400 - Validation errors (missing email, invalid format)
      if (error.statusCode == 400) {
        if (msg.contains('email must be an email') || msg.contains('invalid email') || msg.contains('valid email')) {
          return 'Please enter a valid email address.';
        }
        if (msg.contains('validation') || msg.contains('missing') || msg.contains('required')) {
          return 'Please enter an email address to continue.';
        }
        return 'Please enter a valid email address.';
      }
      // 401 - Unauthorized (expired token, missing auth)
      if (error.statusCode == 401 || msg.contains('unauthorized')) {
        return 'Your session has expired. Please sign in again.';
      }
      // 409/500 - Internal errors
      if (error.statusCode == 409 || (error.statusCode != null && error.statusCode! >= 500)) {
        return 'Something went wrong on our side. Please try again shortly.';
      }
      return 'Unable to find recipient. Please check the email and try again.';
    }
    
    if (context == 'preview') {
      // Specific backend error codes
      if (msg.contains('cannot transfer to the same wallet')) {
        return "You can't send money to your own wallet.";
      }
      if (msg.contains('amount must be greater than zero')) {
        return 'Enter an amount above 0.00 to continue.';
      }
      if (msg.contains('insufficient_funds') || msg.contains('insufficient funds')) {
        return 'Your balance is too low for this transfer.';
      }
      if (msg.contains('fee_exceeds_amount') || msg.contains('fee exceeds amount')) {
        return "The fee is more than the amount you're sending.";
      }
      if (msg.contains('sender wallet not found')) {
        return "We couldn't find your wallet. Please refresh and try again.";
      }
      if (msg.contains('recipient wallet not found') || msg.contains('receiver wallet not found')) {
        return "This user's wallet couldn't be found. Please check the email and try again.";
      }
      // Validation errors
      if (error.statusCode == 400 && (msg.contains('validation') || msg.contains('invalid') || msg.contains('bad request'))) {
        return 'Please enter valid information to continue.';
      }
      return 'Unable to calculate transfer details. Please try again.';
    }
    
    if (context == 'transfer') {
      // Specific backend error messages for POST /wallets/transfer
      if (msg.contains('cannot transfer to the same wallet')) {
        return "You can't send money to your own wallet.";
      }
      if (msg.contains('amount must be greater than zero')) {
        return 'The amount must be greater than zero.';
      }
      if (msg.contains('insufficient_funds') || msg.contains('insufficient funds')) {
        return 'Your balance is too low for this transfer.';
      }
      // Validation errors (400 with array or generic validation message)
      if (error.statusCode == 400 && (msg.contains('validation') || msg.contains('invalid') || msg.contains('bad request') || msg.contains('['))) {
        return 'Please check your details and try again.';
      }
      if (msg.contains('sender wallet not found')) {
        return "We couldn't find your wallet. Please refresh and try again.";
      }
      if (msg.contains('recipient wallet not found')) {
        return "This user doesn't seem to have a wallet on Opei.";
      }
      // Conflict (409 - duplicate/idempotency)
      if (error.statusCode == 409 || msg.contains('conflict')) {
        return 'This transfer has already been processed.';
      }
      // Internal server error (500)
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Something went wrong on our side. Please try again shortly.';
      }
      return 'Unable to complete the transfer. Please try again.';
    }

    if (context == 'deposit') {
      if (error.statusCode == 401) {
        return 'Your session expired. Please sign in again.';
      }
      if (error.statusCode == 400) {
        return 'Invalid request. Please check your details and try again.';
      }
      if (error.statusCode == 503) {
        return 'Service is temporarily unavailable. Please try again shortly.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Something went wrong. Please try again.';
      }
    }

    if (context == 'payout') {
      if (error.statusCode == 401) {
        return 'Your session expired. Please sign in again.';
      }
      if (error.statusCode == 404) {
        if (msg.contains('beneficiary')) {
          return 'Receiver not found. They may have been removed.';
        }
        if (msg.contains('review')) {
          return 'This quote is no longer available. Please try again.';
        }
        return 'We couldn\'t find that record. Please try again.';
      }
      if (error.statusCode == 409) {
        return 'This payout was already submitted.';
      }
      if (error.statusCode == 502) {
        return 'Mobile money provider is unreachable right now. Please try again shortly.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Something went wrong on our side. Please try again shortly.';
      }
      if (error.statusCode == 400) {
        if (msg.contains('insufficient') || msg.contains('reserve failed')) {
          return 'Your balance is too low to send this amount.';
        }
        if (msg.contains('expired') || msg.contains('inactive')) {
          return 'This quote expired. Please request a new one.';
        }
        if (msg.contains('exchange rate') || msg.contains('rate')) {
          return 'Exchange rate is unavailable right now. Please try again.';
        }
        if (msg.contains('amount')) {
          return 'Please enter a valid amount.';
        }
        return error.message;
      }
    }

    if (context == 'us_bank') {
      if (error.statusCode == 401) {
        return 'Your session expired. Please sign in again.';
      }
      if (error.statusCode == 502) {
        if (msg.contains('provider marked') || msg.contains('failed')) {
          return 'Your bank rejected this account. Double-check the routing and account numbers, then try again.';
        }
        return 'Bank network is unavailable right now. Please try again shortly.';
      }
      if (error.statusCode == 503) {
        return 'Bank service is temporarily unavailable. Please try again shortly.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Something went wrong on our side. Please try again shortly.';
      }
      if (error.statusCode == 400) {
        if (msg.contains('routing')) {
          return 'Routing number must be exactly 9 digits.';
        }
        if (msg.contains('account number') || msg.contains('accountnumber')) {
          return 'Account number must be between 4 and 17 digits.';
        }
        if (msg.contains('ach') && msg.contains('business')) {
          return 'ACH transfers are only available for individual beneficiaries. Choose Wire for businesses.';
        }
        if (msg.contains('destination.type') ||
            msg.contains('transfer type')) {
          return 'Transfer type must be Wire or ACH.';
        }
        if (msg.contains('accounttype') || msg.contains('account type')) {
          return 'Account type must be Checking or Savings.';
        }
        if (msg.contains('beneficiary.type') ||
            msg.contains('beneficiary type')) {
          return 'Beneficiary type must be Individual or Business.';
        }
        if (msg.contains('country')) {
          return 'Country must be a valid 2-letter code (e.g. US).';
        }
        if (msg.contains('postcode') || msg.contains('post code')) {
          return 'Please check the post code.';
        }
        if (msg.contains('validation') ||
            msg.contains('invalid') ||
            msg.contains('bad request') ||
            msg.contains('[')) {
          return 'Please check the bank details and try again.';
        }
        return error.message;
      }
      if (msg.contains('provider marked')) {
        return 'Your bank rejected this account. Double-check the details and try again.';
      }
    }

    if (context == 'beneficiary') {
      if (error.statusCode == 401) {
        return 'Your session expired. Please sign in again.';
      }
      if (error.statusCode == 404) {
        return 'No receivers found yet.';
      }
      if (error.statusCode == 502 || error.statusCode == 503) {
        return 'Mobile money provider is unreachable right now. Please try again shortly.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Something went wrong on our side. Please try again shortly.';
      }
      if (error.statusCode == 400) {
        if (msg.contains('phone') || msg.contains('account number') || msg.contains('accountnumber') || msg.contains('digits')) {
          return 'That phone number doesn\'t look right. Please check and try again.';
        }
        if (msg.contains('network')) {
          return 'That network isn\'t supported for this country.';
        }
        if (msg.contains('account name') || msg.contains('accountname') || msg.contains('first and last')) {
          return 'Please enter the receiver\'s full name (first and last).';
        }
        if (msg.contains('validation') || msg.contains('invalid') || msg.contains('bad request') || msg.contains('[')) {
          return 'Please check the receiver details and try again.';
        }
        return error.message;
      }
      if (msg.contains('provider marked beneficiary as failed') ||
          msg.contains('provider marked')) {
        return 'The mobile money provider couldn\'t verify this number. Please double-check it.';
      }
    }

    if (context == 'withdraw') {
      if (error.statusCode == 401) {
        return 'Your session expired. Please sign in again.';
      }
      if (error.statusCode == 503) {
        return 'Service is temporarily unavailable. Please try again shortly.';
      }
      if (error.statusCode != null && error.statusCode! >= 500) {
        return 'Something went wrong. Please try again.';
      }
      if (error.statusCode == 400) {
        if (msg.contains('insufficient')) {
          return "You don't have enough balance to complete this.";
        }
        return 'Invalid request. Please check your details and try again.';
      }
    }
    
    // Server errors
    if (error.statusCode != null && error.statusCode! >= 500) {
      return 'Something went wrong on our end. Please try again in a moment.';
    }
    
    // Bad request errors
    if (error.statusCode == 400) {
      if (msg.contains('validation') || msg.contains('invalid')) {
        return 'Please check your information and try again.';
      }
      return error.message; // Return original if it's already user-friendly
    }
    
    // Return original message if it's already clean
    if (_isUserFriendly(error.message)) {
      return error.message;
    }
    
    return 'Something went wrong. Please try again.';
  }
  
  static String _makeUserFriendly(String message, String? context) {
    final msg = message.toLowerCase();
    
    // Generic error patterns
    if (msg.contains('socketexception') || msg.contains('failed host lookup')) {
      return 'Unable to connect. Please check your internet connection.';
    }
    if (msg.contains('formatexception') || msg.contains('json')) {
      return 'We received an unexpected response. Please try again.';
    }
    if (msg.contains('timeout')) {
      return 'The request took too long. Please try again.';
    }
    
    // Return original if already user-friendly
    if (_isUserFriendly(message)) {
      return message;
    }
    
    // Default fallback
    return 'Something went wrong. Please try again.';
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
