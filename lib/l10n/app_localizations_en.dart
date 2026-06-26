// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Opei - USD Financial Tools';

  @override
  String get languageChooseTitle => 'Choose your language';

  @override
  String get languageChooseSubtitle =>
      'Pick your preferred language.\nYou can change it anytime in Profile.';

  @override
  String get languageEnglishTitle => 'English';

  @override
  String get languageEnglishSubtitle => 'English';

  @override
  String get languagePortugueseTitle => 'Português';

  @override
  String get languagePortugueseSubtitle => 'Portuguese';

  @override
  String get continueCta => 'Continue';

  @override
  String get welcomeCreateAccount => 'Create account';

  @override
  String get welcomeAlreadyHaveAccount => 'Already have an account?';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String get welcomeLegalPrefix => 'By continuing you agree to our ';

  @override
  String get welcomeLegalTerms => 'Terms';

  @override
  String get welcomeLegalAnd => ' and ';

  @override
  String get welcomeLegalPrivacy => 'Privacy Policy';

  @override
  String get loginHeaderTitle => 'Sign in';

  @override
  String get loginHeaderSubtitle => 'Access your Opei account securely.';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginWelcomeSubtitle => 'Sign in to continue to your account';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get emailAddressHint => 'name@example.com';

  @override
  String get emailRequiredError => 'Email is required';

  @override
  String get emailInvalidError => 'Please enter a valid email';

  @override
  String get pinLabel => '6-digit PIN';

  @override
  String get forgotPinCta => 'Forgot PIN?';

  @override
  String get forgotPinTitle => 'Forgot PIN?';

  @override
  String get forgotPinSubtitle => 'Reset it in two quick steps.';

  @override
  String get forgotPinEmailCodeTitle => 'We\'ll email a code';

  @override
  String get forgotPinEmailCodeSubtitle =>
      'Enter the email associated with your account and we\'ll send a 6-digit code.';

  @override
  String get forgotPinSendCodeCta => 'Send code';

  @override
  String get forgotPinRememberedCta => 'Remembered it?';

  @override
  String get pinHint => '••••••';

  @override
  String get pinRequiredError => 'PIN is required';

  @override
  String get pinInvalidError => 'PIN must be exactly 6 digits';

  @override
  String get loginSignInCta => 'Sign in';

  @override
  String get loginUseFaceId => 'Use Face ID';

  @override
  String get loginUseFingerprint => 'Use fingerprint';

  @override
  String get orSeparator => 'or';

  @override
  String get createNewAccountCta => 'Create new account';

  @override
  String get signupSubtitleEmail => 'Let\'s start with your email.';

  @override
  String get signupSubtitlePhone => 'Now your phone number.';

  @override
  String get signupSubtitlePin => 'Choose a 6-digit PIN.';

  @override
  String get signupTitle => 'Create account';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get signupPinHelper =>
      'Keep this safe - it authorises all your payments.';

  @override
  String get signupCreateAccountCta => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get resetPinTitle => 'Reset PIN';

  @override
  String get resetPinSubtitle => 'Enter the code and choose a new PIN.';

  @override
  String get resetPinCodeAndNewPinTitle => 'Code & new PIN';

  @override
  String get resetPinCodePrefix => 'Enter the 6-digit code we sent to ';

  @override
  String get resetPinCodeSuffix => ' and choose your new PIN.';

  @override
  String get resetPinVerificationCodeLabel => 'Verification code';

  @override
  String get resetPinVerificationCodeHint => '6-digit code';

  @override
  String get resetPinNewPinLabel => 'New 6-digit PIN';

  @override
  String get resetPinConfirmPinLabel => 'Confirm new PIN';

  @override
  String get resetPinHelperText =>
      'You\'ll use this to sign in and authorise payments.';

  @override
  String get resetPinCta => 'Reset PIN';

  @override
  String get resetPinDidntGetCode => 'Didn\'t get a code?';

  @override
  String get resetPinRequestNewCta => 'Request new';

  @override
  String get resetPinUpdatedTitle => 'PIN updated';

  @override
  String get resetPinUpdatedSubtitle =>
      'Your new 6-digit PIN is set. Sign in to continue.';

  @override
  String get resetPinGoToSignInCta => 'Go to sign in';

  @override
  String get verifyEmailTitle => 'Verify email';

  @override
  String get verifyEmailSubtitle =>
      'Step 2 of 4  •  Enter the 6-digit code we sent.';

  @override
  String get verifyEmailInboxTitle => 'Check your inbox';

  @override
  String get verifyEmailSentToPrefix => 'We sent a 6-digit code to ';

  @override
  String get verifyEmailWrongEmailCta => 'Wrong email? Start over';

  @override
  String get verifyEmailSigningOut => 'Signing out...';

  @override
  String get verifyEmailVerifying => 'Verifying...';

  @override
  String get verifyEmailDidntGetCode => 'Didn\'t get the code? ';

  @override
  String get verifyEmailResendCta => 'Resend';

  @override
  String verifyEmailResendIn(Object timerText) {
    return 'Resend code in $timerText';
  }

  @override
  String get verifyEmailCodeSent => 'Verification code sent';

  @override
  String get verifyEmailNotFoundError =>
      'Email not found. Please sign up again.';

  @override
  String get topupSheetTitle => 'Top up card';

  @override
  String get topupAmountLabel => 'TOP UP AMOUNT';

  @override
  String get topupPreviewCta => 'Preview top-up';

  @override
  String get loadingPreview => 'Loading preview...';

  @override
  String get paymentBreakdown => 'PAYMENT BREAKDOWN';

  @override
  String get topupAmountRow => 'Top-up amount';

  @override
  String get feeRow => 'Fee';

  @override
  String get totalToPayRow => 'Total to pay';

  @override
  String get afterThisPayment => 'AFTER THIS PAYMENT';

  @override
  String get walletBalanceRow => 'Wallet balance';

  @override
  String get confirmTopupCta => 'Confirm top-up';

  @override
  String get editAmountCta => 'Edit amount';

  @override
  String get youAreToppingUpLabel => 'YOU\'RE TOPPING UP';

  @override
  String get youAreWithdrawingLabel => 'YOU\'RE WITHDRAWING';

  @override
  String get topupCompleteTitle => 'Top-up complete';

  @override
  String get topupCompleteSubtitle => 'Your card balance will update shortly.';

  @override
  String get referenceLabel => 'Reference';

  @override
  String get amountLabel => 'Amount';

  @override
  String get totalPaidLabel => 'Total paid';

  @override
  String get doneCta => 'Done';

  @override
  String get topupFailedTitle => 'Top-up failed';

  @override
  String get topupFailedSubtitle =>
      'Unable to complete top-up. Please try again.';

  @override
  String get tryAgainCta => 'Try again';

  @override
  String get closeCta => 'Close';

  @override
  String get withdrawSheetTitle => 'Withdraw from card';

  @override
  String get withdrawAmountLabel => 'WITHDRAWAL AMOUNT';

  @override
  String get withdrawPreviewCta => 'Preview withdrawal';

  @override
  String get withdrawAmountRow => 'Withdraw amount';

  @override
  String get youWillReceiveRow => 'You\'ll receive';

  @override
  String get afterThisWithdrawal => 'AFTER THIS WITHDRAWAL';

  @override
  String get cardBalanceNowRow => 'Card balance now';

  @override
  String get cardBalanceAfterRow => 'Card balance after';

  @override
  String get confirmWithdrawalCta => 'Confirm withdrawal';

  @override
  String get withdrawalCompleteTitle => 'Withdrawal complete';

  @override
  String get withdrawalCompleteSubtitle =>
      'Funds will arrive in your wallet shortly.';

  @override
  String get statusLabel => 'Status';

  @override
  String get withdrawalFailedTitle => 'Withdrawal failed';

  @override
  String get withdrawalFailedSubtitle =>
      'Unable to complete the withdrawal. Please try again.';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSectionAccountInfo => 'Account Information';

  @override
  String get profileSectionPersonalInfo => 'Personal Information';

  @override
  String get profileSectionAddress => 'Address';

  @override
  String get profileSectionVerification => 'Verification Status';

  @override
  String get profileSectionRewards => 'Rewards';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSectionLegal => 'Legal';

  @override
  String get profileSectionActions => 'Account Actions';

  @override
  String get profileSectionSecurity => 'Security Settings';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Phone';

  @override
  String get profileVerificationStageLabel => 'Verification Stage';

  @override
  String get profileFullNameLabel => 'Full Name';

  @override
  String get profileDobLabel => 'Date of Birth';

  @override
  String get profileGenderLabel => 'Gender';

  @override
  String get profileNationalityLabel => 'Nationality';

  @override
  String get profileIdTypeLabel => 'ID Type';

  @override
  String get profileIdNumberLabel => 'ID Number';

  @override
  String get profileCountryLabel => 'Country';

  @override
  String get profileStateLabel => 'State';

  @override
  String get profileCityLabel => 'City';

  @override
  String get profileAddressLabel => 'Address';

  @override
  String get profileZipCodeLabel => 'Zip Code';

  @override
  String get profileUpdateAddressCta => 'Update Address';

  @override
  String get profileAddAddressCta => 'Add Address';

  @override
  String get profileNoAddressSubtitle => 'No address added yet';

  @override
  String get profileIdentityVerifiedTitle => 'Identity Verified';

  @override
  String get profileIdentityVerifiedSubtitle =>
      'Your identity has been successfully verified';

  @override
  String get profileReferralsLabel => 'Referrals';

  @override
  String get profileReferralsSubtitle => 'Share your link and track earnings';

  @override
  String get profileLanguageLabel => 'Language';

  @override
  String get profileTermsLabel => 'Terms & Conditions';

  @override
  String get profilePrivacyLabel => 'Privacy Policy';

  @override
  String get profileLogoutLabel => 'Log Out';

  @override
  String get profileUnableLoadTitle => 'Unable to load profile';

  @override
  String get retryCta => 'Retry';

  @override
  String get profileKycPromptTitle => 'Complete Your Profile';

  @override
  String get profileKycPromptSubtitle =>
      'Verify your identity to unlock all features';

  @override
  String get naValue => 'N/A';

  @override
  String get languageUpdatedPortuguese => 'Language updated to Portuguese.';

  @override
  String get languageUpdatedEnglish => 'Language updated to English.';

  @override
  String get languageUpdateFailed =>
      'Could not update language. Please try again.';

  @override
  String get selectLanguageTitle => 'Select language';

  @override
  String get selectLanguageSubtitle => 'Choose your app language preference.';

  @override
  String get languageUseEnglishSubtitle => 'Use English throughout the app';

  @override
  String get languageUsePortugueseSubtitle =>
      'Use Portuguese throughout the app';

  @override
  String get logoutTitle => 'Log out';

  @override
  String get logoutSubtitle => 'You\'ll need to sign in again next time';

  @override
  String get cancelCta => 'Cancel';

  @override
  String get quickAuthPinLabel => 'PIN Authentication';

  @override
  String get loadingText => 'Loading...';

  @override
  String get enabledText => 'Enabled';

  @override
  String get disabledText => 'Disabled';

  @override
  String get faceIdPrompt => 'Set up Face ID for quick sign-in';

  @override
  String get fingerprintPrompt => 'Set up fingerprint for quick sign-in';

  @override
  String get faceIdDisabled => 'Face ID sign-in disabled.';

  @override
  String get fingerprintDisabled => 'Fingerprint sign-in disabled.';

  @override
  String get biometricUpdateFailed =>
      'Could not update biometric settings. Please try again.';

  @override
  String get faceIdSignInLabel => 'Face ID Sign-in';

  @override
  String get fingerprintSignInLabel => 'Fingerprint Sign-in';

  @override
  String get biometricEnabledSubtitle => 'Enabled - sign in with a glance';

  @override
  String get faceIdDisabledSubtitle => 'Use Face ID instead of typing your PIN';

  @override
  String get fingerprintDisabledSubtitle =>
      'Use your fingerprint instead of typing your PIN';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingAfternoon => 'Good afternoon';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardNavHome => 'Home';

  @override
  String get dashboardNavCards => 'Cards';

  @override
  String get dashboardNavActivity => 'Activity';

  @override
  String get dashboardNavAgent => 'Agent';

  @override
  String get dashboardNavProfile => 'Profile';

  @override
  String get dashboardRecentActivity => 'Recent activity';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String get dashboardNoTransactionsTitle => 'No transactions yet';

  @override
  String get dashboardNoTransactionsSubtitle =>
      'Your money moves will appear here.';

  @override
  String get dashboardActivityLoadFailedTitle => 'Couldn\'t load activity';

  @override
  String get dashboardUsdWallet => 'USD Wallet';

  @override
  String dashboardReservedHeld(Object reserved) {
    return '$reserved held';
  }

  @override
  String get dashboardActionAdd => 'Add';

  @override
  String get dashboardActionSend => 'Send';

  @override
  String get dashboardActionWithdraw => 'Withdraw';

  @override
  String get dashboardActionCards => 'Cards';

  @override
  String get transactionsNoActivityTitle => 'No activity yet';

  @override
  String get transactionsNoActivitySubtitle =>
      'You haven\'t made any moves yet.\nNew activity will appear here instantly.';

  @override
  String get transactionsAllCaughtUp => 'You\'re all caught up';

  @override
  String get transactionsSingle => 'transaction';

  @override
  String get transactionsPlural => 'transactions';

  @override
  String transactionsCountLabel(Object count, Object unit) {
    return '$count $unit';
  }

  @override
  String get transactionsHeaderSubtitle =>
      'Every move on your account, in one place.';

  @override
  String transactionsHeaderTimeline(Object countLabel) {
    return '$countLabel · all on one timeline';
  }

  @override
  String get transactionsMoneyIn => 'Money in';

  @override
  String get transactionsMoneyOut => 'Money out';

  @override
  String get depositAddMoneyTitle => 'Add Money';

  @override
  String get depositAddMoneySubtitle => 'Choose how you want to add funds';

  @override
  String get depositExpressP2PTitle => 'Express P2P';

  @override
  String get depositExpressP2PSubtitle => 'Pay local currency, get USD fast';

  @override
  String get depositP2PExchangeTitle => 'P2P Exchange';

  @override
  String get depositP2PExchangeSubtitle =>
      'Bank transfer, Mobile Payments and more';

  @override
  String get depositStablecoinTitle => 'USD Stablecoin';

  @override
  String get depositStablecoinSubtitle =>
      'Receive USDT or USDC to your Opei wallet';

  @override
  String get depositSelectMethodTitle => 'Select Method';

  @override
  String get depositChooseMethodSubtitle =>
      'Choose the method you want to deposit with';

  @override
  String get depositSelectNetworkTitle => 'Select Network';

  @override
  String depositChooseNetworkSubtitle(Object currency) {
    return 'Choose the network for your $currency deposit';
  }

  @override
  String get depositFetchAddressFailed => 'Failed to fetch deposit address';

  @override
  String get depositAddressTitle => 'Deposit Address';

  @override
  String get depositScanTitle => 'Scan to deposit';

  @override
  String depositSendOnNetwork(Object currency, Object network) {
    return 'Send $currency on $network';
  }

  @override
  String get depositQrUnavailable => 'QR unavailable';

  @override
  String get depositAddressCopied => 'Address copied';

  @override
  String get depositCopyCta => 'Copy';

  @override
  String get depositImportantTitle => 'Important';

  @override
  String depositInfoOnlySend(Object currency, Object network) {
    return 'Only send $currency on $network network';
  }

  @override
  String get depositInfoWrongAssetWarning =>
      'Other assets or networks will cause permanent loss';

  @override
  String get depositInfoBalanceUpdates =>
      'Balance updates after network confirmations';
}
