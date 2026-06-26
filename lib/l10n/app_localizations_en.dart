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
  String get phoneNumberRequiredError => 'Phone number is required';

  @override
  String phoneNumberExactDigitsError(Object digits) {
    return 'Phone number must be exactly $digits digits';
  }

  @override
  String phoneNumberMinDigitsError(Object digits) {
    return 'Phone number must be at least $digits digits';
  }

  @override
  String phoneNumberMaxDigitsError(Object digits) {
    return 'Phone number can be at most $digits digits';
  }

  @override
  String get legalTitle => 'Legal';

  @override
  String get legalBackToHomeCta => 'Back to Home';

  @override
  String get legalLastUpdated => 'Last updated: 3 January 2025';

  @override
  String get legalDocumentsTitle => 'Documents';

  @override
  String get termsAndConditionsTitle => 'Terms & Conditions';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get legalCompanyName => 'Opei Technologies LLC';

  @override
  String get legalSupportEmail => 'Support Email: info@opeillc.com';

  @override
  String get legalSupportEmailShort => 'Email: info@opeillc.com';

  @override
  String get legalCompanyAddress =>
      '500 Westover Dr, 31775\nSanford, NC 27330\nUnited States';

  @override
  String get legalCompanyPhone => 'Phone: +1 (681) 547-8620';

  @override
  String get legalCopyrightNotice => '© 2026 Opei Technologies LLC.';

  @override
  String get termsDocumentBody =>
      'These Terms and Conditions govern your access to and use of Opei services.\n\nBy creating an account or using Opei, you agree to these Terms.\n\nOpei is a financial technology platform and relies on third-party providers for payments, cards, identity verification, and related services.\n\nYou must provide accurate information, keep your account credentials secure, and use the platform lawfully.\n\nTransactions may be irreversible. You are responsible for recipient details, amounts, and confirmation steps.\n\nFor P2P transactions, users transact directly with each other. Opei may review disputes at its discretion.\n\nVirtual card and wallet services are subject to third-party availability, rules, and processing outcomes.\n\nFees may apply and may change over time. Third-party fees can also apply.\n\nOpei may suspend, restrict, or terminate accounts for compliance, fraud prevention, risk, or legal reasons.\n\nServices are provided \"as is\" and \"as available\". To the extent permitted by law, liability is limited.\n\nThese Terms may be updated. Continued use of Opei means acceptance of updated Terms.';

  @override
  String get privacyPolicyDocumentBody =>
      'This Privacy Policy explains how Opei collects, uses, and protects personal information.\n\nBy using Opei, you acknowledge and accept this Privacy Policy.\n\nWe may collect data you provide (such as name, email, phone, address, and verification details) and technical usage data.\n\nWe use personal information to operate services, verify identity, process transactions, improve product quality, and comply with legal obligations.\n\nWe may share data with trusted service providers and authorities when required by law.\n\nYour information may be processed in countries outside your residence, including the United States.\n\nWe retain data for as long as needed for service operation, compliance, fraud prevention, and dispute resolution.\n\nWe apply administrative, technical, and organizational safeguards, but no system can guarantee absolute security.\n\nDepending on jurisdiction, you may have rights such as access, correction, deletion requests, and objection to processing.\n\nWe may update this Policy over time. Continued use of Opei means acceptance of updated Policy terms.';

  @override
  String get selectCountryCodeTitle => 'Select country code';

  @override
  String get searchCountryCodeHint => 'Search country or code';

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

  @override
  String get sendMoneyTitle => 'Send Money';

  @override
  String get sendMoneyRecipientEmailLabel => 'Recipient email';

  @override
  String get sendMoneyEnterEmailError => 'Please enter an email';

  @override
  String get sendMoneyValidEmailError => 'Please enter a valid email';

  @override
  String get sendMoneySendingToLabel => 'Sending to';

  @override
  String get sendMoneyEnterAmountError => 'Please enter an amount';

  @override
  String get sendMoneyValidAmountError => 'Please enter a valid amount';

  @override
  String get sendMoneyNoPreview => 'No preview available';

  @override
  String get sendMoneyRecipientSection => 'RECIPIENT';

  @override
  String get sendMoneyTransferAmountRow => 'Transfer amount';

  @override
  String get sendMoneyTotalToChargeRow => 'Total to charge';

  @override
  String get sendMoneySendNowCta => 'Send now';

  @override
  String get sendMoneyTransferCompleteTitle => 'Transfer complete';

  @override
  String sendMoneyTransferCompleteSubtitle(
    Object amount,
    Object recipientName,
  ) {
    return 'You sent $amount to $recipientName';
  }

  @override
  String get sendMoneyAmountSentRow => 'Amount sent';

  @override
  String get sendMoneyNewBalanceRow => 'Your new balance';

  @override
  String get sendMoneyTransferFailedTitle => 'Transfer failed';

  @override
  String get sendMoneyTransferFailedSubtitle =>
      'The transfer could not be completed. Please try again.';

  @override
  String get onboardingCancelTitle => 'Cancel setup?';

  @override
  String get onboardingCancelMessage =>
      'You will be signed out and returned to home. You can continue onboarding after logging in again.';

  @override
  String get onboardingKeepGoingCta => 'Keep going';

  @override
  String get onboardingCancelSetupCta => 'Cancel setup';

  @override
  String get referralEnterValidCodeError => 'Enter a valid referral code';

  @override
  String get referralTooLateVerifiedError => 'Too late - already verified';

  @override
  String get referralAppliedSuccess => 'Referral applied successfully.';

  @override
  String get referralTryAgainLater => 'Try again later';

  @override
  String get referralInvalidCodeError => 'Invalid code - check and try again';

  @override
  String get referralSelfCodeError => 'You can\'t use your own code';

  @override
  String get referralAlreadyHasReferrerError => 'You already have a referrer';

  @override
  String get referralApplyTitle => 'Apply referral';

  @override
  String get referralGotCodeTitle => 'Got a referral code?';

  @override
  String get referralOptionalSubtitle =>
      'Optional step. You can only apply a referral before verification.';

  @override
  String get referralApplyCta => 'Apply referral';

  @override
  String get referralSkipForNowCta => 'Skip for now';

  @override
  String get referralLoadFailedMessage =>
      'Could not load referral details. Try again.';

  @override
  String get referralCodeCopied => 'Code copied to clipboard';

  @override
  String get referralShareCodeSubtitle =>
      'Share your code with friends. They enter it during signup.';

  @override
  String get referralStatsLabel => 'YOUR STATS';

  @override
  String get referralInvitedLabel => 'Invited';

  @override
  String get referralSuccessfulLabel => 'Successful';

  @override
  String get referralTotalEarnedLabel => 'Total earned';

  @override
  String get referralHeaderTitle => 'Refer & Earn';

  @override
  String get referralHeaderSubtitle => 'Invite friends and earn rewards.';

  @override
  String get referralYourCodeLabel => 'YOUR CODE';

  @override
  String get referralCopiedCta => 'Copied';

  @override
  String get referralCouldNotLoadTitle => 'Couldn\'t load referral details';

  @override
  String get addressWhereDoYouLiveTitle => 'Where do you live?';

  @override
  String get addressWhereDoYouLiveSubtitle =>
      'Required to verify your account. Stays completely private.';

  @override
  String get addressLineLabel => 'Address line';

  @override
  String get addressStreetHintExample => '123 Main Street';

  @override
  String get addressAptSuiteLabel => 'Apt / Suite';

  @override
  String get addressAptHintExample => 'Apt 4B';

  @override
  String get addressZipCodeLabel => 'ZIP code';

  @override
  String get addressCityLabel => 'City';

  @override
  String get addressCityHintExample => 'New York';

  @override
  String get addressStateLabel => 'State';

  @override
  String get addressStateHintExample => 'NY';

  @override
  String get addressBvnLabel => 'BVN';

  @override
  String get addressBvnHintExample => '11-digit Bank Verification Number';

  @override
  String get mobileMoneyReceiversTitle => 'Mobile Money receivers';

  @override
  String get mobileMoneyAddNewReceiverCta => 'Add new receiver';

  @override
  String get mobileMoneyUnnamedReceiver => 'Unnamed receiver';

  @override
  String get mobileMoneyNoReceiversTitle => 'No receivers yet';

  @override
  String get mobileMoneyNoReceiversSubtitle =>
      'Add your first receiver to start sending mobile money.';

  @override
  String get mobileMoneyLoadReceiversFailed => 'Couldn\'t load receivers';

  @override
  String get mobileMoneyChooseNetworkError => 'Please choose a network.';

  @override
  String get mobileMoneyReceiverAdded => 'Receiver added.';

  @override
  String get mobileMoneyNewReceiverTitle => 'New receiver';

  @override
  String get mobileMoneyLabel => 'Mobile Money';

  @override
  String get mobileMoneyReceiverNameLabel => 'Receiver name';

  @override
  String get mobileMoneyReceiverFullNameHint => 'Full name';

  @override
  String get mobileMoneyReceiverFullNameRequired =>
      'Enter the receiver\'s full name.';

  @override
  String get mobileMoneyReceiverFirstLastNameRequired =>
      'Include first and last name.';

  @override
  String mobileMoneyDigitsHint(Object digits) {
    return '$digits digits';
  }

  @override
  String get mobileMoneyPhoneRequired => 'Enter the phone number.';

  @override
  String mobileMoneyPhoneExactDigitsForCountry(
    Object digits,
    Object countryName,
  ) {
    return 'Phone number must be exactly $digits digits for $countryName.';
  }

  @override
  String get mobileMoneyPhoneLeadingZeroError =>
      'Don\'t include the leading 0 — the country code is added for you.';

  @override
  String mobileMoneyLocalNumberHelper(Object dialCode) {
    return 'Enter the local number without the leading 0. We\'ll send it as $dialCode.';
  }

  @override
  String get mobileMoneySaveReceiverCta => 'Save receiver';

  @override
  String get requiredLabel => 'REQUIRED';

  @override
  String get okLabel => 'OK';

  @override
  String get mobileMoneyNoNetworksForCountry =>
      'No networks available for this country.';

  @override
  String get usBankAchIndividualsOnlyError =>
      'ACH transfers are only available for individuals. Switch to Wire for businesses.';

  @override
  String get usBankReceiverAdded => 'Receiver added.';

  @override
  String get usBankNewReceiverTitle => 'New receiver';

  @override
  String get usBankHeaderSubtitle => 'United States · Bank Transfer';

  @override
  String get usBankWireOptionLabel => 'Wire';

  @override
  String get usBankIndividualOptionLabel => 'Individual';

  @override
  String get usBankBusinessOptionLabel => 'Business';

  @override
  String get usBankAchIndividualsOnlyInfo =>
      'ACH is only available for individuals. Switch to Wire to send to a business.';

  @override
  String get usBankCheckingOptionLabel => 'Checking';

  @override
  String get usBankSavingsOptionLabel => 'Savings';

  @override
  String get usBankAccountDigitsHelper => '4 – 17 digits';

  @override
  String get usBankAccountDigitsError => 'Must be 4 – 17 digits.';

  @override
  String get usBankRoutingDigitsHelper => 'Exactly 9 digits';

  @override
  String get usBankRoutingHint => '9 digits';

  @override
  String get usBankRoutingDigitsError => 'Must be exactly 9 digits.';

  @override
  String get usBankBankNameHint => 'e.g. Chase Bank';

  @override
  String get usBankBankNameRequired => 'Enter the bank name.';

  @override
  String get usBankBankAddressHint => 'e.g. 270 Park Avenue';

  @override
  String get usBankBankAddressRequired => 'Enter the bank address.';

  @override
  String get fieldRequiredError => 'Required.';

  @override
  String get usBankBusinessNameHint => 'e.g. Saul Atta LLC';

  @override
  String get usBankFullNameHint => 'e.g. John Doe';

  @override
  String get usBankBeneficiaryNameRequired => 'Enter the beneficiary name.';

  @override
  String get usBankBeneficiaryAddressHint => 'e.g. 123 Tech Avenue, Suite 400';

  @override
  String get usBankAddressRequired => 'Enter an address.';

  @override
  String get usBankBeneficiaryCityHint => 'Austin';

  @override
  String get usBankBeneficiaryStateHint => 'Texas';

  @override
  String get cardsLoadFailedMessage =>
      'We couldn\'t load your cards. Please try again.';

  @override
  String get cardsNotFoundError => 'We couldn\'t find this card.';

  @override
  String get cardsTerminateConfirmTitle => 'Terminate this card?';

  @override
  String cardsTerminateConfirmSubtitle(Object cardLabel) {
    return 'This card will be permanently removed. You won’t be able to use or view $cardLabel again.';
  }

  @override
  String get cardsTerminateMoveFundsWarning =>
      'Make sure you’ve moved any remaining funds before confirming.';

  @override
  String get genericIssueTitle => 'We ran into an issue';

  @override
  String get loadingSecurelyLabel => 'Loading securely...';

  @override
  String get cardsCopySampleAddressCta => 'Copy sample address';

  @override
  String get cardsCopyAddressCta => 'Copy address';

  @override
  String get cardsAddressTitle => 'Card Address';

  @override
  String get cardsSampleAddressHelper =>
      'Sample data shown for layout. Real card addresses will appear here once provided by the gateway.';

  @override
  String get cardsEmptyStateTitle => 'Your Opei Visa Card';

  @override
  String get cardsEmptyStateSubtitle =>
      'Pay anywhere Visa is accepted —\nsubscriptions, travel, and shopping.';

  @override
  String get cardsCreateCardCta => 'Create card';

  @override
  String get cardsHolderLabel => 'Card holder';

  @override
  String get cardsYourNamePlaceholder => 'YOUR NAME';

  @override
  String get addressBvnHelper => 'Required for Nigerian residents.';

  @override
  String get addressHomeAddressTitle => 'Home address';

  @override
  String get addressOnboardingStepSubtitle =>
      'Step 3 of 4  •  Your residential details.';

  @override
  String get addressUpdateSubtitle => 'Update your residential details.';

  @override
  String get addressSelectCountryHint => 'Select country';

  @override
  String get addressSelectCountryTitle => 'Select country';

  @override
  String get addressSearchCountryHint => 'Search country';

  @override
  String get addressUpdatedTitle => 'Address updated';

  @override
  String get addressUpdatedSubtitle =>
      'Your residential details have been saved.';

  @override
  String get kycIdentityVerificationTitle => 'Identity Verification';

  @override
  String get kycCheckingStatus => 'Checking your verification status...';

  @override
  String get kycApprovedTitle => 'KYC approved';

  @override
  String get kycApprovedSubtitle =>
      'You\'re fully verified. Continue to your dashboard.';

  @override
  String get kycUnderReviewTitle => 'Under review';

  @override
  String get kycUnderReviewSubtitle =>
      'We\'ll email you within 24 hours once the review finishes.';

  @override
  String get kycDeclinedTitle => 'KYC declined';

  @override
  String get kycDeclinedSubtitle =>
      'Check your email for the reason and next steps, or contact support if you need help.';

  @override
  String get kycRetryVerificationCta => 'Retry verification';

  @override
  String get kycUnableFetchStatus =>
      'Unable to fetch your status. Please try again.';

  @override
  String get kycVerifyIdentityTitle => 'Verify your\nidentity';

  @override
  String get kycVerifyIdentitySubtitle =>
      'One last step — a quick ID check and selfie. Takes about 2 minutes.';

  @override
  String get kycChecklistGovernmentIdTitle => 'Government-issued ID';

  @override
  String get kycChecklistGovernmentIdSubtitle =>
      'Passport, driver\'s licence or national ID';

  @override
  String get kycChecklistSelfieTitle => 'A quick selfie';

  @override
  String get kycChecklistSelfieSubtitle => 'Matched against your ID photo';

  @override
  String get kycChecklistTwoMinutesTitle => 'About 2 minutes';

  @override
  String get kycChecklistTwoMinutesSubtitle => 'Most checks complete instantly';

  @override
  String get kycDataPrivacyNote =>
      'Your data is encrypted and never shared. We verify with a trusted partner.';

  @override
  String get kycStartVerificationCta => 'Start verification';

  @override
  String get kycPermissionInProgressError =>
      'A permission request is already in progress. Please wait a moment and try again.';

  @override
  String get kycPermissionRequiredError =>
      'Camera and microphone access are required to continue.';

  @override
  String get kycAllowAccessTitle => 'Allow access';

  @override
  String get kycAllowAccessMessage =>
      'Camera, microphone and media permissions are needed to capture your verification selfie. Please enable them in Settings to continue.';

  @override
  String get kycNotNowCta => 'Not now';

  @override
  String get kycOpenSettingsCta => 'Open Settings';

  @override
  String get kycPreparingVerification => 'Preparing verification…';

  @override
  String get kycCouldNotOpenVerificationTab =>
      'Could not open verification tab. Copying link…';

  @override
  String get kycAlreadyVerifiedTitle => 'Already verified';

  @override
  String get kycGoToDashboardCta => 'Go to dashboard';

  @override
  String get kycAddressRequiredTitle => 'Address required';

  @override
  String get kycCompleteAddressCta => 'Complete address';

  @override
  String get kycAccountInactiveTitle => 'Account inactive';

  @override
  String get kycSignInAgainTitle => 'Sign in again';

  @override
  String get kycGoToSignInCta => 'Go to sign in';

  @override
  String get kycSomethingWentWrongTitle => 'Something went wrong';

  @override
  String get kycAllSetTitle => 'You\'re all set!';

  @override
  String get kycAllSetSubtitle =>
      'Your identity has been verified. Welcome to Opei.';

  @override
  String get kycContinueToDashboardCta => 'Continue to dashboard';

  @override
  String get callCta => 'Call';

  @override
  String get couldNotOpenDialer => 'Could not open dialer.';

  @override
  String get buyerNumberCopied => 'Buyer number copied';

  @override
  String get addImageCta => 'Add image';

  @override
  String get copiedLabel => 'Copied';

  @override
  String get cardsTransactionsTitle => 'Card Transactions';

  @override
  String get cardsVirtualReadyMessage => 'Your virtual card is ready!';

  @override
  String get cardsVirtualCardLabel => 'Virtual Card';

  @override
  String get cardsKeepCardCta => 'Keep card';

  @override
  String get cardsTerminateCta => 'Terminate';

  @override
  String get cardsCreateVirtualCardCta => 'Create Virtual Card';

  @override
  String get cardsTopUpAction => 'Top Up';

  @override
  String get cardsWithdrawAction => 'Withdraw';

  @override
  String get cardsTransactionsAction => 'Transactions';

  @override
  String get cardsFreezeAction => 'Freeze Card';

  @override
  String get cardsUnfreezeAction => 'Unfreeze Card';

  @override
  String cardsValueCopied(Object label) {
    return '$label copied';
  }

  @override
  String get editCta => 'Edit';

  @override
  String get deactivateCta => 'Deactivate';

  @override
  String get backCta => 'Back';

  @override
  String get goBackCta => 'Go back';

  @override
  String get iUnderstandCta => 'I understand';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get providerLabel => 'Provider';

  @override
  String get frenchLabel => 'French';

  @override
  String get p2pTradeCancelledSnack => 'Trade cancelled.';

  @override
  String get p2pAdSubmittedReviewSnack => 'Ad submitted for review.';

  @override
  String get p2pClearFiltersCta => 'Clear filters';

  @override
  String get p2pApplyFiltersCta => 'Apply filters';

  @override
  String get p2pThanksForRatingSnack => 'Thanks for rating!';

  @override
  String get p2pDisputeSubmittedSnack =>
      'Dispute submitted. Support has been notified.';

  @override
  String get p2pImageUnavailable => 'Image unavailable';

  @override
  String get p2pSubmitDisputeCta => 'Submit dispute';

  @override
  String get p2pCreateAdTitle => 'Create P2P Ad';

  @override
  String get p2pChooseAdType => 'Choose ad type';

  @override
  String get p2pAddPaymentMethodCta => 'Add payment method';

  @override
  String get p2pSelectCurrency => 'Select Currency';

  @override
  String get p2pPreferredLanguage => 'Preferred language';

  @override
  String get p2pPreferredCurrency => 'Preferred currency';

  @override
  String get p2pChoosePayoutCurrencySubtitle =>
      'Choose the currency you want to get paid in';

  @override
  String get p2pPayoutCurrencyLabel => 'Payout currency';

  @override
  String p2pSelectOrAddPaymentMethodsForCurrency(Object currency) {
    return 'Select or add payment methods for $currency';
  }

  @override
  String get p2pCreateBuyAdTitle => 'Create BUY ad';

  @override
  String get p2pCreateBuyAdSubtitle =>
      'Set the amount, limits and price you’re willing to pay.';

  @override
  String get sendReceiverFallback => 'Receiver';

  @override
  String get sendReceiverBadge => 'Receiver';

  @override
  String get sendAmountTitle => 'Enter amount';

  @override
  String sendAmountSubtitle(Object currencyCode) {
    return 'How much will they receive in $currencyCode?';
  }

  @override
  String sendAmountAmountError(Object currencyCode) {
    return 'Enter an amount in $currencyCode above 0 to continue.';
  }

  @override
  String get sendAmountDescriptionMinError =>
      'Enter a clear description (at least 3 characters).';

  @override
  String get sendAmountDescriptionMaxError =>
      'Description is too long (max 120 characters).';

  @override
  String get sendAmountCostHint =>
      'You\'ll see the USD cost and exchange rate before confirming.';

  @override
  String get sendDescriptionLabel => 'Description *';

  @override
  String get sendDescriptionHint => 'What is this payment for?';

  @override
  String get sendPreviewQuoteUnavailable =>
      'Quote unavailable. Please go back and try again.';

  @override
  String get sendPreviewTitle => 'Review transfer';

  @override
  String get sendPreviewSubtitle => 'Check the details before confirming.';

  @override
  String sendPreviewBalanceShortfall(Object shortfall) {
    return 'Your balance is \$$shortfall short. Top up to continue.';
  }

  @override
  String get sendPreviewReservingFunds => 'Reserving funds…';

  @override
  String get sendPreviewSendingPayment => 'Sending payment…';

  @override
  String get sendPreviewConfirmCta => 'Confirm & send';

  @override
  String get sendPreviewYouPayLabel => 'YOU PAY';

  @override
  String get sendPreviewTheyReceiveLabel => 'THEY RECEIVE';

  @override
  String get sendPreviewRecipientBadge => 'Recipient';

  @override
  String get sendPreviewSendAmountRow => 'Send amount';

  @override
  String get sendPreviewTransferFeeRow => 'Transfer fee';

  @override
  String get sendPreviewTotalChargedRow => 'Total charged';

  @override
  String get sendPreviewWalletAfterRow => 'Wallet after';

  @override
  String get sendPreviewNoteRow => 'Note';

  @override
  String sendPreviewQuoteExpiresAt(Object time) {
    return 'Quote expires at $time';
  }

  @override
  String get sendResultMoneySentTitle => 'Money sent';

  @override
  String sendResultMoneySentSubtitle(Object receiverName) {
    return 'Your payment to $receiverName has been delivered.';
  }

  @override
  String get sendResultCompletedStatus => 'COMPLETED';

  @override
  String get sendResultPaymentFailedTitle => 'Payment failed';

  @override
  String get sendResultPaymentFailedSubtitle =>
      'The provider couldn\'t process this payment. No funds were taken.';

  @override
  String get sendResultFailedStatus => 'FAILED';

  @override
  String get sendResultSendingInProgressTitle => 'Sending in progress';

  @override
  String sendResultSendingInProgressSubtitle(Object receiverName) {
    return 'Your payment is on its way to $receiverName. We\'ll notify you once it\'s confirmed.';
  }

  @override
  String get sendResultProcessingStatus => 'PROCESSING';

  @override
  String get sendResultStatusUnknownTitle => 'Status unknown';

  @override
  String get sendResultStatusUnknownSubtitle =>
      'Check Activity in a few moments to see the outcome.';

  @override
  String get sendResultUnknownStatus => 'UNKNOWN';

  @override
  String get sendResultReceivedLabel => 'RECEIVED';

  @override
  String get sendResultDateRow => 'Date';

  @override
  String get quickAuthEnterPinTitle => 'Enter your PIN';

  @override
  String get quickAuthNoPinTitle => 'No PIN set up';

  @override
  String get quickAuthEnterPinSubtitle => 'Use your 6-digit PIN to sign in';

  @override
  String get quickAuthNoPinSubtitle => 'Set up a PIN in your account settings';

  @override
  String get quickAuthVerifyingTitle => 'Verifying';

  @override
  String get quickAuthVerifyingSubtitle => 'One moment please';

  @override
  String get quickAuthFaceIdBanner => 'Use Face ID for faster sign-in';

  @override
  String get quickAuthFingerprintBanner => 'Use fingerprint for faster sign-in';

  @override
  String get quickAuthEnableCta => 'Enable';

  @override
  String get quickAuthDismissTooltip => 'Dismiss';

  @override
  String get quickAuthUsePasswordCta => 'Use password';

  @override
  String get p2pBuyerLabel => 'Buyer';

  @override
  String get p2pSellerLabel => 'Seller';

  @override
  String get p2pSelectStarRatingError => 'Please select a star rating.';

  @override
  String get p2pFailedSubmitRatingError =>
      'Failed to submit rating. Please try again.';

  @override
  String p2pRateCounterpartyTitle(Object counterparty) {
    return 'Rate $counterparty';
  }

  @override
  String get p2pHowWasExperienceSubtitle => 'How was your experience?';

  @override
  String get p2pWhatWentWellLabel => 'What went well?';

  @override
  String get p2pCommentsLabel => 'Comments';

  @override
  String get p2pShareExperienceHint => 'Share your experience...';

  @override
  String get p2pSubmitRatingCta => 'Submit rating';

  @override
  String get refreshCta => 'Refresh';

  @override
  String get addressLabel => 'Address';

  @override
  String get accountNumberLabel => 'Account number';

  @override
  String get accountNameLabel => 'Account name';

  @override
  String get detailsLabel => 'Details';

  @override
  String get networkLabel => 'Network';

  @override
  String get paymentMethodsLabel => 'Payment methods';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get exchangeRateLabel => 'Exchange rate';

  @override
  String get withdrawChooseMethodSubtitle => 'Choose a withdrawal method';

  @override
  String get withdrawMobileMoneyTitle => 'Mobile Money';

  @override
  String get withdrawMobileMoneySubtitle => 'M-Pesa, Airtel Money and more';

  @override
  String get withdrawBankTransferTitle => 'Bank Transfer';

  @override
  String get withdrawBankTransferSubtitle => 'Send to bank account';

  @override
  String get withdrawP2PExchangeTitle => 'P2P Exchange';

  @override
  String get withdrawP2PExchangeSubtitle =>
      'Sell to buyers and get paid directly';

  @override
  String get withdrawStablecoinSubtitle =>
      'Send USDT or USDC to your crypto wallet';

  @override
  String get withdrawEnterAmountError => 'Please enter an amount';

  @override
  String get withdrawEnterDestinationError =>
      'Please enter a destination address';

  @override
  String get withdrawEnterValidAmountError =>
      'Please enter a valid amount greater than zero';

  @override
  String withdrawDetailsSubtitle(Object currency, Object network) {
    return 'Enter the details for your $currency withdrawal on $network.';
  }

  @override
  String get withdrawAmountHelper => 'Enter the amount you want to send';

  @override
  String get withdrawAmountPlaceholder => '0.00';

  @override
  String get withdrawDestinationAddressLabel => 'Destination address';

  @override
  String get withdrawDestinationAddressHelper =>
      'Paste the wallet address that will receive the funds';

  @override
  String get withdrawDestinationAddressPlaceholder => 'Wallet address';

  @override
  String get withdrawMemoOptionalLabel => 'Memo (optional)';

  @override
  String get withdrawMemoHelper => 'Add a note for your own records';

  @override
  String get withdrawMemoPlaceholder => 'Memo or description';

  @override
  String get withdrawInfoDoubleCheck =>
      'Double-check the network and address before submitting.';

  @override
  String get withdrawInfoStatusUpdates =>
      'We\'ll notify you when the transfer status updates.';

  @override
  String get withdrawReviewTitle => 'Review withdrawal';

  @override
  String withdrawReviewSubtitle(Object currency) {
    return 'Confirm these details before we send your $currency.';
  }

  @override
  String get withdrawAssetLabel => 'Asset';

  @override
  String get withdrawNetworkLabel => 'Network';

  @override
  String get withdrawDestinationLabel => 'Destination';

  @override
  String get withdrawConfirmCta => 'Confirm';

  @override
  String get withdrawSubmittedTitle => 'Withdrawal submitted';

  @override
  String get withdrawSentTitle => 'Withdrawal sent';

  @override
  String withdrawSentSubtitle(Object asset, Object network) {
    return 'We are processing your $asset transfer on $network network. You will receive an update as soon as confirmations land.';
  }

  @override
  String get withdrawRequestedLabel => 'Requested';

  @override
  String get cardsCardNumberLabel => 'Card number';

  @override
  String get cardsExpiresLabel => 'Expires';

  @override
  String get cardsExpiryDateLabel => 'Expiry date';

  @override
  String get cardsCvvLabel => 'CVV';

  @override
  String copyLabelWithValue(Object value) {
    return 'Copy $value';
  }

  @override
  String get cardsUseCaseSubscriptionsTitle => 'Subscriptions';

  @override
  String get cardsUseCaseSubscriptionsSubtitle => 'Netflix, Spotify, and more';

  @override
  String get cardsUseCaseOnlineShoppingTitle => 'Online Shopping';

  @override
  String get cardsUseCaseOnlineShoppingSubtitle => 'Purchase from any store';

  @override
  String get cardsUseCaseTravelTitle => 'Travel & Tickets';

  @override
  String get cardsUseCaseTravelSubtitle => 'Book flights and hotels';

  @override
  String get cardsUseCaseGamingTitle => 'Gaming';

  @override
  String get cardsUseCaseGamingSubtitle => 'In-app purchases and games';

  @override
  String get cardsUseCaseInternationalTitle => 'International Store Payments';

  @override
  String get cardsUseCaseInternationalSubtitle => 'Shop from anywhere';

  @override
  String get cardsUseCaseSecureTitle => 'Secure Online Purchases';

  @override
  String get cardsUseCaseSecureSubtitle => 'Protected transactions';

  @override
  String get cardsSettingUpCardLoading => 'Setting up your card...';

  @override
  String get cardsReadyToCreate => 'Your virtual card is ready to create.';

  @override
  String get cardsTopupToCreate =>
      'Top up your wallet to continue card creation.';

  @override
  String get cardsPaymentSummaryLabel => 'PAYMENT SUMMARY';

  @override
  String get cardsTopupRequiredLabel => 'TOP UP REQUIRED';

  @override
  String get cardsCreateMyCardCta => 'Create my card';

  @override
  String get cardsAddFundsCta => 'Add funds';

  @override
  String get cardsCreationFeeRow => 'Creation fee';

  @override
  String get cardsActivationFeeRow => 'Activation fee';

  @override
  String get cardsOnYourCardRow => 'On your card';

  @override
  String get cardsAmountNeededRow => 'Amount needed';

  @override
  String get cardsCreatingCardLoading => 'Creating your card...';

  @override
  String get expressStatusFindingAgent => 'Finding agent';

  @override
  String get expressStatusPayNow => 'Pay now';

  @override
  String get expressStatusVerifying => 'Verifying';

  @override
  String get expressStatusUnderReview => 'Under review';

  @override
  String get expressStatusCompleted => 'Completed';

  @override
  String get expressStatusExpired => 'Expired';

  @override
  String get expressStatusCancelled => 'Cancelled';

  @override
  String get expressStatusProcessing => 'Processing';

  @override
  String get expressStatusAvailable => 'Available';

  @override
  String get expressStatusWaitingPayment => 'Waiting payment';

  @override
  String get expressStatusConfirmPayment => 'Confirm payment';

  @override
  String get expressCustomerPaysRow => 'Customer pays';

  @override
  String get expressYouReleaseRow => 'You release';

  @override
  String get expressYouReceiveRow => 'You receive';

  @override
  String get expressYouPayRow => 'You pay';

  @override
  String get agentContactTitle => 'Agent contact';

  @override
  String get needToFollowUpTitle => 'Need to follow up?';

  @override
  String get disputeExplainIssueHint => 'Explain the issue...';

  @override
  String get addNoteOptionalHint => 'Add a note (optional)';

  @override
  String get transactionsEarlierGroup => 'Earlier';

  @override
  String get transactionsTodayGroup => 'Today';

  @override
  String get transactionsYesterdayGroup => 'Yesterday';

  @override
  String get transactionsFailedStatus => 'Failed';

  @override
  String get transactionsCancelledStatus => 'Cancelled';

  @override
  String get transactionsReversedStatus => 'Reversed';

  @override
  String get transactionsRefundedStatus => 'Refunded';

  @override
  String get usBankTransferSetupTitle => 'Transfer setup';

  @override
  String get usBankTransferTypeLabel => 'Transfer type';

  @override
  String get usBankBeneficiaryTypeLabel => 'Beneficiary type';

  @override
  String get usBankAccountTypeLabel => 'Account type';

  @override
  String get usBankAccountNumbersTitle => 'Account numbers';

  @override
  String get usBankRoutingNumberLabel => 'Routing number';

  @override
  String get usBankBankInformationTitle => 'Bank information';

  @override
  String get usBankBankNameLabel => 'Bank name';

  @override
  String get usBankBankAddressLabel => 'Bank address';

  @override
  String get usBankRemittancePurposeTitle => 'Remittance purpose';

  @override
  String get usBankBeneficiaryDetailsTitle => 'Beneficiary details';

  @override
  String get usBankBusinessNameLabel => 'Business name';

  @override
  String get usBankFullNameLabel => 'Full name';

  @override
  String get referralCodeHint => 'Paste code or https://opei.app/r/CODE';

  @override
  String get sendMoneyAmountHint => '0.00';

  @override
  String get allLabel => 'All';

  @override
  String get ratingLabel => 'Rating';

  @override
  String get tradesLabel => 'Trades';

  @override
  String get sinceLabel => 'Since';

  @override
  String get rateLabel => 'Rate';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get createdLabel => 'Created';

  @override
  String get availableLabel => 'Available';

  @override
  String get additionalDetailsLabel => 'Additional Details';

  @override
  String get remainingLabel => 'Remaining';

  @override
  String get totalAmountLabel => 'Total amount';

  @override
  String get minOrderLabel => 'Min order';

  @override
  String get maxOrderLabel => 'Max order';

  @override
  String get minLabel => 'Min';

  @override
  String get maxLabel => 'Max';

  @override
  String get aboutLabel => 'About';

  @override
  String get memberSinceLabel => 'Member since';

  @override
  String get notAvailableLabel => 'Not available';

  @override
  String get verifiedLabel => 'Verified';

  @override
  String get addedLabel => 'Added';

  @override
  String get addCta => 'Add';

  @override
  String get somethingWentWrongTitle => 'Something went wrong';

  @override
  String get p2pBuyLabel => 'Buy';

  @override
  String get p2pSellLabel => 'Sell';

  @override
  String get p2pSectionTitle => 'P2P';

  @override
  String get p2pCouldNotLoadAdsTitle => 'We couldn’t load your ads';

  @override
  String get p2pCouldNotLoadOrdersTitle => 'We couldn’t load your orders';

  @override
  String get p2pOrdersTabLabel => 'Orders';

  @override
  String get p2pMyAdsTabLabel => 'My Ads';

  @override
  String get p2pAmountFiltersTitle => 'Amount filters';

  @override
  String get p2pLoadingProfileLabel => 'Loading profile…';

  @override
  String get p2pRefreshSessionCta => 'Refresh session';

  @override
  String get p2pSetUpProfileTitle => 'Set up your P2P profile';

  @override
  String get p2pSetUpProfileSubtitle =>
      'Let buyers and sellers know who they’re dealing with. A verified profile speeds up trust checks and trade approvals.';

  @override
  String get p2pProfileHighlightNameBio =>
      'Share a friendly name and short bio';

  @override
  String get p2pProfileHighlightLimits =>
      'Unlock higher limits with verified details';

  @override
  String get p2pCreateProfileCta => 'Create profile';

  @override
  String get p2pProfileDetailsTitle => 'Profile details';

  @override
  String get p2pAccountToolsTitle => 'Account tools';

  @override
  String get p2pManageAcceptedAccountsSubtitle =>
      'Manage the accounts you accept for trades. Each method is tied to a single currency.';

  @override
  String get p2pNoPaymentMethodsYetTitle => 'No payment methods yet';

  @override
  String get p2pNoPaymentMethodsYetSubtitle =>
      'Add your first method to make it easier for buyers to pay you.';

  @override
  String get p2pNoOrdersInViewTitle => 'No orders in this view';

  @override
  String get p2pNoOrdersInViewSubtitle =>
      'Once you start trading, your activity will show here.';

  @override
  String get p2pMinimumAmountLabel => 'Minimum amount';

  @override
  String get p2pMaximumAmountLabel => 'Maximum amount';

  @override
  String get p2pManagePayoutAccountsSubtitle => 'Manage payout accounts';

  @override
  String get p2pSearchCurrencyHint => 'Search currency';

  @override
  String get p2pPaidLabel => 'Paid';

  @override
  String get p2pReleasedLabel => 'Released';

  @override
  String get p2pCompletedLabel => 'Completed';

  @override
  String get p2pReasonLabel => 'Reason';

  @override
  String get p2pOrderIdLabel => 'Order ID';

  @override
  String get p2pShareShortNoteHint => 'Share a short note (<=500 chars)';

  @override
  String get p2pPrepareProofUploadsError =>
      'Couldn’t prepare proof uploads. Please try again.';

  @override
  String get p2pDisputeReasonHint => 'Seller never released after I sent funds';

  @override
  String get p2pSellUsdTitle => 'Sell USD';

  @override
  String get p2pSellUsdSubtitle => 'Receive fiat or mobile money.';

  @override
  String get p2pBuyUsdTitle => 'Buy USD';

  @override
  String get p2pBuyUsdSubtitle => 'Specify how you will pay sellers.';

  @override
  String get p2pTotalAmountUsdLabel => 'Total amount (USD)';

  @override
  String get p2pPriceUsdLabel => 'Price (USD)';

  @override
  String get p2pMinOrderUsdLabel => 'Min order (USD)';

  @override
  String get p2pMaxOrderUsdLabel => 'Max order (USD)';

  @override
  String get p2pInstructionsOptionalLabel => 'Instructions (optional)';

  @override
  String get p2pInstructionsProofHint => 'e.g., Proof of transfer required';

  @override
  String get p2pDisplayNameLabel => 'Display name';

  @override
  String get p2pDisplayNameHint => 'Johnex';

  @override
  String get p2pUsernameLabel => 'Username';

  @override
  String get p2pUsernameHint => 'john_fx';

  @override
  String get p2pBioLabel => 'Bio';

  @override
  String get p2pBioHint => '10 years trading USD/ZMW';

  @override
  String get p2pPriceRateLabel => 'Price (rate)';

  @override
  String get p2pInstructionsAvailableHint => 'e.g., Available 08:00-21:00';

  @override
  String get p2pInstructionsNeedProofHint => 'e.g., Need proof of transfer';

  @override
  String get p2pNameOnAccountHint => 'Name on account';

  @override
  String get p2pAccountNumberHint => 'Account number';

  @override
  String get p2pExtraDetailsOptionalLabel => 'Extra details (optional)';

  @override
  String get p2pBranchReferenceHint => 'Branch, reference';

  @override
  String get p2pChooseHowYouPayTitle => 'Choose how you’ll pay';

  @override
  String p2pSelectSellerPaymentMethodSubtitle(Object currency) {
    return 'Select one of the seller’s payment methods for $currency.';
  }

  @override
  String get p2pSelectPayoutRailTitle => 'Select payout rail';

  @override
  String p2pChooseBuyerPaymentMethodSubtitle(Object currency) {
    return 'Choose the payment method the buyer should use for $currency.';
  }

  @override
  String get p2pMinimumOrderLabel => 'Minimum order';

  @override
  String get p2pBuyerPaysViaLabel => 'Buyer pays via';

  @override
  String get p2pPaymentCurrencyLabel => 'Payment currency';

  @override
  String get p2pDisputeOpenedSuccess =>
      'Dispute opened. Support will review it shortly.';

  @override
  String get p2pBackToOrdersTooltip => 'Back to orders';

  @override
  String get p2pSellerReviewsProofLabel => 'Seller reviews your payment proof.';

  @override
  String p2pUploadFailedStatus(Object status) {
    return 'Upload failed with status $status';
  }

  @override
  String p2pFailedUploadProof(Object index) {
    return 'Failed to upload proof $index. Please try again.';
  }

  @override
  String get p2pSellerDetailsHint => 'Add any details the seller should know';

  @override
  String get cardsAfterCreationRow => 'After creation';

  @override
  String get cardsAddToContinueLabel => 'Add to continue';

  @override
  String get cardsOnItsWayTitle => 'Card on its way!';

  @override
  String get cardsOnItsWayMessage =>
      'Your virtual card is being set up.\nIt will be active in a moment.';

  @override
  String get cardsLoadDetailsError => 'Couldn\'t load card details';

  @override
  String get cardsTransactionsEmptyTitle => 'No card transactions yet';

  @override
  String get cardsTransactionsEmptyMessage =>
      'When you start using this card, your transaction history will appear here.';

  @override
  String cardsTransactionBalanceRow(Object balance) {
    return 'Balance: $balance';
  }

  @override
  String get withdrawMobileMoneyCountriesSubtitle =>
      'Mobile Money supported countries';

  @override
  String withdrawChooseNetworkSubtitle(Object currency) {
    return 'Choose the network for your $currency withdrawal';
  }

  @override
  String withdrawCurrencyTitle(Object currency) {
    return 'Withdraw $currency';
  }

  @override
  String withdrawCurrencyWithdrawalLabel(Object currency) {
    return '$currency withdrawal';
  }

  @override
  String get expressP2PHubSubtitle => 'Pay local currency · get USD fast';

  @override
  String get expressStartNewDepositTitle => 'Start new deposit';

  @override
  String get expressStartNewDepositSubtitle =>
      'Choose amount and payment method';

  @override
  String get expressNoDepositsTitle => 'No deposits yet';

  @override
  String get expressNoDepositsMessage =>
      'Start a deposit to add USD to your wallet by paying a local agent.';

  @override
  String get expressLoadDepositsError => 'Couldn\'t load your deposits';

  @override
  String expressPickSendMethodHint(Object currency) {
    return 'Pick how you will send $currency to the agent.';
  }

  @override
  String get expressLoadingMethods => 'Loading methods…';

  @override
  String get expressNoMethodsForCurrency =>
      'No payment methods available for this currency yet.';

  @override
  String get expressAmountToReceiveLabel => 'AMOUNT TO RECEIVE';

  @override
  String get expressReviewTitle => 'Review';

  @override
  String get expressRateLocksHint =>
      'Rate locks on confirm. An agent will be matched to collect your local payment.';

  @override
  String get expressConfirmOrderCta => 'Confirm order';

  @override
  String get expressDepositTitle => 'Deposit';

  @override
  String get expressOrderNotFound => 'Order not found.';

  @override
  String get expressCancelOrderTitle => 'Cancel this order?';

  @override
  String get expressCancelOrderPaidRisk =>
      'If you already sent money to the agent and cancel now, that payment may be lost and cannot be recovered in-app. Cancel only if you have NOT paid yet.';

  @override
  String get expressCancelOrderMessage =>
      'This will cancel the order and stop the current express deposit flow.';

  @override
  String get expressKeepOrderCta => 'Keep order';

  @override
  String get expressYesCancelCta => 'Yes, cancel';

  @override
  String get expressOrderPlacedTitle => 'Order placed';

  @override
  String get expressOrderPlacedMessage =>
      'We\'re looking for an agent for you now. Once matched, you\'ll be notified and can continue payment.';

  @override
  String get expressCancelOrderCta => 'Cancel order';

  @override
  String get expressViewMyOrdersCta => 'View my orders';

  @override
  String get expressPayYourAgentTitle => 'Pay your agent';

  @override
  String expressSendExactlyMessage(Object amount) {
    return 'Send exactly $amount to the account below, then upload your proof.';
  }

  @override
  String get expressPayOutsideHint =>
      'Pay outside the app, then upload a screenshot or receipt as proof of payment.';

  @override
  String get expressPaymentSubmittedTitle => 'Payment submitted';

  @override
  String get expressPaymentSubmittedMessage =>
      'Your proof has been sent. Please wait while the agent confirms payment. Once approved, USD will be added to your wallet.';

  @override
  String get expressOpenDisputeCta => 'Open dispute';

  @override
  String get expressDisputeOpenedTitle => 'Dispute opened';

  @override
  String get expressDisputeUnderReviewMessage =>
      'Under review by admin. We will notify you when this is resolved.';

  @override
  String expressAmountAddedTitle(Object amount) {
    return '$amount added';
  }

  @override
  String get expressDepositCompleteMessage =>
      'Your deposit is complete and the funds are now in your Opei wallet.';

  @override
  String get expressDisputeSheetSubtitle =>
      'Tell us what happened. You can add proof screenshots (optional).';

  @override
  String get expressUploadProofTitle => 'Upload payment proof';

  @override
  String get expressUploadProofSubtitle =>
      'Add a screenshot or receipt of your payment (up to 3 images).';

  @override
  String get expressSubmitPaymentCta => 'Submit payment';

  @override
  String get expressAcceptOrderTitle => 'Accept this order?';

  @override
  String expressAcceptOrderMessage(Object amount) {
    return '$amount will be reserved from your wallet for this order. Only accept when you are ready to complete this trade to avoid potential financial loss.';
  }

  @override
  String get expressAcceptCta => 'Accept';

  @override
  String get expressAgentTitle => 'Express Agent';

  @override
  String get expressAgentSubtitle => 'Accept and complete deposits';

  @override
  String get expressAgentInactiveViewOnly =>
      'Your agent account is inactive. You can view orders but cannot accept or confirm.';

  @override
  String get expressAcceptOrderCta => 'Accept order';

  @override
  String get expressConfirmReceivedTitle => 'Confirm payment received?';

  @override
  String get expressConfirmReceivedMessage =>
      'Only continue if the money is in your account. This will release USD to the buyer and cannot be undone. A wrong confirmation may cause financial loss.';

  @override
  String get expressNotYetCta => 'Not yet';

  @override
  String get expressYesReleaseCta => 'Yes, release';

  @override
  String get expressOrderTitle => 'Order';

  @override
  String get expressUnderReviewByAdmin => 'Under review by admin.';

  @override
  String get expressPaymentProofLabel => 'PAYMENT PROOF';

  @override
  String get expressAgentInactiveConfirm =>
      'Your agent account is inactive. You cannot confirm orders.';

  @override
  String get expressConfirmReceivedCta => 'Confirm payment received';

  @override
  String expressImageLabel(Object number) {
    return 'Image $number';
  }

  @override
  String get expressCouldNotOpenImage => 'Could not open this image.';

  @override
  String get expressBuyerContactLabel => 'Buyer contact';

  @override
  String get expressBuyerContactUnavailable => 'Buyer contact unavailable';

  @override
  String expressTabAvailable(Object count) {
    return 'Available ($count)';
  }

  @override
  String expressTabQueue(Object count) {
    return 'Queue ($count)';
  }

  @override
  String get expressTabHistory => 'History';

  @override
  String get expressNoAvailableOrders => 'No orders available right now.';

  @override
  String get expressNoQueueOrders => 'No active orders in your queue.';

  @override
  String get expressNoCompletedOrders => 'No completed orders yet.';

  @override
  String get savedReceiversLabel => 'SAVED RECEIVERS';

  @override
  String get addNewReceiverTitle => 'Add new receiver';

  @override
  String get couldNotLoadReceivers => 'Couldn\'t load receivers';

  @override
  String get mobileMoneyReceiversSubtitle => 'Mobile Money · Receivers';

  @override
  String get mobileMoneyAddReceiverSubtitle =>
      'Save a number to send money quickly';

  @override
  String get mobileMoneyNoReceiversHint =>
      'Save a phone number above to send mobile\nmoney quickly next time.';

  @override
  String get usBankReceiversSubtitle => 'Bank Transfer · Receivers';

  @override
  String get usBankAddReceiverSubtitle =>
      'Save a US bank account to send quickly';

  @override
  String get usBankNoReceiversTitle => 'No receivers yet';

  @override
  String get usBankNoReceiversHint =>
      'Save a US bank account above to send\ndollars to the US quickly next time.';

  @override
  String stepIndicator(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get recipientGetsLabel => 'RECIPIENT GETS';

  @override
  String get bankTransferCountriesSubtitle =>
      'Bank Transfer supported countries';

  @override
  String get savingLabel => 'Saving';

  @override
  String get transactionNoteLabel => 'NOTE';

  @override
  String depositNetworksCount(Object name, Object count) {
    return '$name • $count networks';
  }

  @override
  String get remPurposeFamilySupport => 'Family support';

  @override
  String get remPurposeEducation => 'Education';

  @override
  String get remPurposeGiftAndDonation => 'Gift & donation';

  @override
  String get remPurposeMedicalTreatment => 'Medical treatment';

  @override
  String get remPurposeMaintenanceExpenses => 'Maintenance / living expenses';

  @override
  String get remPurposeTravel => 'Travel';

  @override
  String get remPurposeSmallValueRemittance => 'Small-value remittance';

  @override
  String get remPurposeLiberalizedRemittance => 'Liberalized remittance';

  @override
  String get remPurposePersonalTransfer => 'Personal transfer';

  @override
  String get remPurposeSalaryPayment => 'Salary payment';

  @override
  String get remPurposeLoanPayment => 'Loan payment';

  @override
  String get remPurposeTaxPayment => 'Tax payment';

  @override
  String get remPurposeUtilityBills => 'Utility bills';

  @override
  String get remPurposePropertyPurchase => 'Property purchase';

  @override
  String get remPurposePropertyRental => 'Property rental';

  @override
  String get remPurposeConstructionExpenses => 'Construction expenses';

  @override
  String get remPurposeHotelAccommodation => 'Hotel accommodation';

  @override
  String get remPurposeTransportationFees => 'Transportation fees';

  @override
  String get remPurposeDeliveryFees => 'Delivery fees';

  @override
  String get remPurposeOfficeExpenses => 'Office expenses';

  @override
  String get remPurposeAdvertisingExpenses => 'Advertising expenses';

  @override
  String get remPurposeAdvisoryFees => 'Advisory fees';

  @override
  String get remPurposeServiceCharges => 'Service charges';

  @override
  String get remPurposeBusinessInsurance => 'Business insurance';

  @override
  String get remPurposeInsuranceClaims => 'Insurance claims';

  @override
  String get remPurposeExportedGoods => 'Exported goods';

  @override
  String get remPurposeSharesInvestment => 'Shares investment';

  @override
  String get remPurposeFundInvestment => 'Fund investment';

  @override
  String get remPurposeRoyaltyFees => 'Royalty fees';

  @override
  String get remPurposeComputerServices => 'Computer services';

  @override
  String get remPurposeRewardPayment => 'Reward payment';

  @override
  String get remPurposeInfluencerPayment => 'Influencer payment';

  @override
  String get remPurposeOtherFees => 'Other fees';

  @override
  String get remPurposeOther => 'Other';

  @override
  String get errTimeoutConnection =>
      'The request took too long. Please check your connection and try again.';

  @override
  String get errUnableToConnect =>
      'Unable to connect. Please check your internet connection.';

  @override
  String get errSessionExpired => 'Your session expired. Please sign in again.';

  @override
  String get errNoPermission =>
      'You do not have permission to perform this action.';

  @override
  String get errLookupAccountNotFound =>
      'We could not find an account with that email address.';

  @override
  String get errInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errEnterEmail => 'Please enter an email address to continue.';

  @override
  String get errServerSideShortly =>
      'Something went wrong on our side. Please try again shortly.';

  @override
  String get errLookupRecipientFailed =>
      'Unable to find recipient. Please check the email and try again.';

  @override
  String get errSameWallet => 'You can\'t send money to your own wallet.';

  @override
  String get errAmountAboveZero => 'Enter an amount above 0.00 to continue.';

  @override
  String get errBalanceTooLow => 'Your balance is too low for this transfer.';

  @override
  String get errFeeExceedsAmount =>
      'The fee is more than the amount you\'re sending.';

  @override
  String get errSenderWalletNotFound =>
      'We couldn\'t find your wallet. Please refresh and try again.';

  @override
  String get errRecipientWalletNotFound =>
      'This user\'s wallet couldn\'t be found. Please check the email and try again.';

  @override
  String get errEnterValidInfo => 'Please enter valid information to continue.';

  @override
  String get errPreviewFailed =>
      'Unable to calculate transfer details. Please try again.';

  @override
  String get errAmountGreaterThanZero =>
      'The amount must be greater than zero.';

  @override
  String get errCheckDetails => 'Please check your details and try again.';

  @override
  String get errRecipientNoWallet =>
      'This user doesn\'t seem to have a wallet on Opei.';

  @override
  String get errTransferAlreadyProcessed =>
      'This transfer has already been processed.';

  @override
  String get errTransferFailed =>
      'Unable to complete the transfer. Please try again.';

  @override
  String get errInvalidRequestCheckDetails =>
      'Invalid request. Please check your details and try again.';

  @override
  String get errServiceUnavailable =>
      'Service is temporarily unavailable. Please try again shortly.';

  @override
  String get errGenericRetry => 'Something went wrong. Please try again.';

  @override
  String get errReceiverNotFound =>
      'Receiver not found. They may have been removed.';

  @override
  String get errQuoteUnavailable =>
      'This quote is no longer available. Please try again.';

  @override
  String get errRecordNotFound =>
      'We couldn\'t find that record. Please try again.';

  @override
  String get errPayoutAlreadySubmitted => 'This payout was already submitted.';

  @override
  String get errMobileMoneyUnreachable =>
      'Mobile money provider is unreachable right now. Please try again shortly.';

  @override
  String get errBalanceTooLowSend =>
      'Your balance is too low to send this amount.';

  @override
  String get errQuoteExpired => 'This quote expired. Please request a new one.';

  @override
  String get errRateUnavailable =>
      'Exchange rate is unavailable right now. Please try again.';

  @override
  String get errEnterValidAmount => 'Please enter a valid amount.';

  @override
  String get errBankRejectedAccount =>
      'Your bank rejected this account. Double-check the routing and account numbers, then try again.';

  @override
  String get errBankNetworkUnavailable =>
      'Bank network is unavailable right now. Please try again shortly.';

  @override
  String get errBankServiceUnavailable =>
      'Bank service is temporarily unavailable. Please try again shortly.';

  @override
  String get errRoutingDigits => 'Routing number must be exactly 9 digits.';

  @override
  String get errAccountNumberDigits =>
      'Account number must be between 4 and 17 digits.';

  @override
  String get errAchIndividualOnly =>
      'ACH transfers are only available for individual beneficiaries. Choose Wire for businesses.';

  @override
  String get errTransferTypeWireAch => 'Transfer type must be Wire or ACH.';

  @override
  String get errAccountTypeCheckingSavings =>
      'Account type must be Checking or Savings.';

  @override
  String get errBeneficiaryTypeIndBus =>
      'Beneficiary type must be Individual or Business.';

  @override
  String get errCountryCode =>
      'Country must be a valid 2-letter code (e.g. US).';

  @override
  String get errPostCode => 'Please check the post code.';

  @override
  String get errCheckBankDetails =>
      'Please check the bank details and try again.';

  @override
  String get errBankRejectedAccountShort =>
      'Your bank rejected this account. Double-check the details and try again.';

  @override
  String get errNoReceivers => 'No receivers found yet.';

  @override
  String get errPhoneInvalid =>
      'That phone number doesn\'t look right. Please check and try again.';

  @override
  String get errNetworkUnsupported =>
      'That network isn\'t supported for this country.';

  @override
  String get errReceiverFullName =>
      'Please enter the receiver\'s full name (first and last).';

  @override
  String get errCheckReceiverDetails =>
      'Please check the receiver details and try again.';

  @override
  String get errProviderCantVerify =>
      'The mobile money provider couldn\'t verify this number. Please double-check it.';

  @override
  String get errNotEnoughBalance =>
      'You don\'t have enough balance to complete this.';

  @override
  String get errCheckInformation =>
      'Please check your information and try again.';

  @override
  String get errServerOurEnd =>
      'Something went wrong on our end. Please try again in a moment.';

  @override
  String get errUnexpectedResponse =>
      'We received an unexpected response. Please try again.';

  @override
  String get errTimeoutRetry => 'The request took too long. Please try again.';

  @override
  String get idLabel => 'ID';

  @override
  String get submittedLabel => 'Submitted';

  @override
  String get instructionsLabel => 'Instructions';

  @override
  String get submittingLabel => 'Submitting';

  @override
  String get p2pCancelTradeCta => 'Cancel trade';

  @override
  String get p2pConfirmReleaseCta => 'Confirm release';

  @override
  String get p2pSendThisAmountTitle => 'Send this amount';

  @override
  String p2pTransferAmountBeforePaid(Object amount) {
    return 'Transfer $amount to the seller before marking payment as sent.';
  }

  @override
  String get p2pProofsSubmittedTitle => 'Proofs submitted';

  @override
  String get p2pPaymentMarkedPaidWaitingSeller =>
      'Payment marked as paid. Waiting for seller confirmation.';

  @override
  String get p2pDisputeOpenedSupportReviewSoon =>
      'Dispute opened. Our support team will review it shortly.';

  @override
  String get p2pDisputeOpenedLabel => 'Dispute opened';

  @override
  String get p2pRaiseDisputeCta => 'Raise dispute';

  @override
  String p2pYouRatedCounterparty(Object counterparty) {
    return 'You rated this $counterparty';
  }

  @override
  String get p2pFeedbackHelpsSafetySubtitle =>
      'Your feedback helps keep trades safe and respectful.';

  @override
  String get p2pOptionalCommentLabel => 'Optional comment';

  @override
  String get p2pTagsOptionalLabel => 'Tags (optional)';

  @override
  String get p2pReadyToConfirmPaymentTitle => 'Ready to confirm payment?';

  @override
  String get p2pUploadClearProofSubtitle =>
      'Upload clear payment proof so the seller can release the funds.';

  @override
  String get p2pIvePaidCta => 'I\'ve Paid';

  @override
  String get p2pBuyerMarkedPaidTitle => 'Buyer marked payment as sent';

  @override
  String get p2pConfirmFundsThenReleaseSubtitle =>
      'Confirm the funds have arrived in your account, then release the funds to complete the trade.';

  @override
  String get p2pDoNotReleaseBeforeReceiving =>
      'Do not release funds before receiving payment.';

  @override
  String get p2pReleaseLossWarning =>
      'Releasing funds without confirmed payment may cause irreversible loss. Opei is not responsible for losses resulting from releasing funds before payment is received.';

  @override
  String get p2pShortReasonMinChars =>
      'Give a short reason (at least 6 characters).';

  @override
  String get p2pTellUsWhatWentWrongSubtitle =>
      'Tell us what went wrong so our support team can review it quickly.';

  @override
  String get p2pNoAdsYetTitle => 'No ads just yet';

  @override
  String get p2pNoAdsYetSubtitle =>
      'Launch your first buy or sell ad to start trading directly with other users.';

  @override
  String get p2pSellingUsdLabel => 'Selling USD';

  @override
  String get p2pBuyingUsdLabel => 'Buying USD';

  @override
  String get p2pDeactivateAdConfirmSubtitle =>
      'This ad will no longer be visible to traders. You can reactivate it later if needed.';

  @override
  String get p2pSelectAtLeastOnePaymentMethodError =>
      'Select at least one payment method.';

  @override
  String get p2pEnterValidAmountsLimitsPriceError =>
      'Please enter valid amounts, limits and price.';

  @override
  String get p2pCreateSellAdTitle => 'Create SELL ad';

  @override
  String p2pStepOfTotal(Object step, Object total) {
    return 'Step $step of $total';
  }

  @override
  String get p2pTellOthersRecognizeSubtitle =>
      'Tell others how to recognize you. You can edit this later.';

  @override
  String get p2pChooseMethodsToPaySellers =>
      'Choose the payment methods you\'ll use to pay sellers. Only the rail name appears on your ad.';

  @override
  String p2pSelectHowBuyersPayYou(Object currency) {
    return 'Select how buyers can pay you in $currency. We\'ll share the details after a trade opens.';
  }

  @override
  String p2pNoMethodsYetForCurrency(Object currency) {
    return 'No $currency methods yet. Add one to continue.';
  }

  @override
  String get p2pSetAmountLimitsPriceInstructions =>
      'Set the amount, limits, price, and instructions (optional).';

  @override
  String get p2pAttachUpToFiveMethodsError =>
      'You can attach up to five payment methods.';

  @override
  String get p2pMaxFiveMethodsPerAd =>
      'Maximum of five payment methods per ad.';

  @override
  String get p2pAttachUpToFiveMethodsPerAd =>
      'You can attach up to five payment methods per ad.';

  @override
  String get p2pSaveProfileCta => 'Save profile';

  @override
  String get p2pSetUpProfileToContinue =>
      'Set up your P2P profile to continue.';

  @override
  String get p2pPleaseSignInAgainError => 'Please sign in again to continue.';

  @override
  String get p2pPaymentProviderInactiveError =>
      'Payment provider is currently inactive.';

  @override
  String get p2pPaymentMethodNoLongerExistsError =>
      'Payment method no longer exists.';

  @override
  String get p2pPaymentMethodAttachedToActiveAdError =>
      'This payment method is attached to an active ad and can\'t be edited.';

  @override
  String get p2pPaymentMethodInOngoingTradeError =>
      'This payment method is being used in an ongoing trade.';

  @override
  String get p2pPaymentProviderNotAvailableError =>
      'Payment provider is not available.';

  @override
  String get p2pAccountNumberExistsError =>
      'Account number already exists for this user.';

  @override
  String get p2pMaxPaymentMethodsReachedError =>
      'Maximum payment methods reached for this currency.';

  @override
  String get p2pCheckDetailsTryAgainError =>
      'Please check your details and try again.';

  @override
  String get p2pCouldNotSaveMethodError =>
      'We couldn\'t save this method. Please try again.';

  @override
  String get p2pSelectPaymentProviderError => 'Select a payment provider.';

  @override
  String get p2pNoChangesDetectedError => 'No changes detected.';

  @override
  String get p2pSelectProviderTitle => 'Select provider';

  @override
  String get p2pEditPaymentMethodTitle => 'Edit payment method';

  @override
  String get p2pAddPaymentMethodTitle => 'Add payment method';

  @override
  String get p2pUpdatePaymentMethodDetailsSubtitle =>
      'Update the details for this payment method.';

  @override
  String get p2pChooseProviderAddAccountSubtitle =>
      'Choose a provider and add your account details.';

  @override
  String get p2pNoProvidersAvailableLabel => 'No providers available';

  @override
  String get p2pUpdateMethodCta => 'Update method';

  @override
  String get p2pSaveMethodCta => 'Save method';

  @override
  String get p2pSubmitForReviewCta => 'Submit for review';

  @override
  String get p2pCouldNotLoadPaymentOptionsError =>
      'We couldn\'t load payment options. Please try again.';

  @override
  String p2pTradesCount(Object count) {
    return '$count trades';
  }

  @override
  String get p2pPriceLabel => 'Price';

  @override
  String p2pAvailableAmount(Object amount) {
    return 'Available $amount';
  }

  @override
  String get p2pTradeCreatedTitle => 'Trade created';

  @override
  String get p2pYouWillReceiveLabel => 'You will receive';

  @override
  String get p2pAdInstructionsLabel => 'Ad instructions';

  @override
  String get p2pNotifyWhenBuyerMarksPaid =>
      'We\'ll notify you once the buyer marks payment as sent. Go to Orders to review proof and release the funds.';

  @override
  String get p2pSendPaymentUsingDetails =>
      'Send payment using the details below.';

  @override
  String get p2pPayWithin30MinutesWarning =>
      'Pay within 30 minutes and confirm, or this trade will be cancelled.';

  @override
  String get p2pSellerPaymentDetailsTitle => 'Seller Payment Details';

  @override
  String get p2pSellerSharesFinalDetailsInChat =>
      'Seller will share the final account details in chat.';

  @override
  String get p2pYouSendLabel => 'You send';

  @override
  String get p2pSellerInstructionsTitle => 'Seller Instructions';

  @override
  String get p2pWaitingForSellerTitle => 'Waiting for the seller';

  @override
  String get p2pWaitingForSellerSubtitle =>
      'We\'ve notified the other party. Once they confirm payment, your USD will be released to your wallet. We\'ll let you know immediately.';

  @override
  String get p2pAddingYourProofLabel => 'Adding your proof...';

  @override
  String get p2pSubmittedProofsTitle => 'Submitted proofs';

  @override
  String get p2pVisibleToSellerSupport =>
      'Visible to the seller and support team.';

  @override
  String get p2pProofOfPaymentTitle => 'Proof of payment';

  @override
  String p2pSelectedCount(Object selected, Object total) {
    return '$selected/$total selected';
  }

  @override
  String get p2pProofSubmittedTitle => 'Proof submitted';

  @override
  String get p2pProofSubmittedSellerNotified =>
      'We\'ve notified the seller. They\'ll review your proof and release the funds once they confirm payment.';

  @override
  String get p2pWhatHappensNextTitle => 'What happens next?';

  @override
  String get p2pOnceConfirmedFundsReleased =>
      'Once confirmed, the funds are released automatically.';

  @override
  String get p2pReceiveNotificationEveryUpdate =>
      'You\'ll receive a notification for every update.';

  @override
  String get p2pCancelThisTradeTitle => 'Cancel this trade?';

  @override
  String get p2pDoNotCancelAfterSending => 'Do not cancel after sending money.';

  @override
  String get p2pCancelAfterPaymentLossWarning =>
      'Canceling after payment may cause irreversible loss. Opei is not responsible for losses resulting from user cancellation after payment.';

  @override
  String get p2pUploadProofTitle => 'Upload Proof';

  @override
  String get p2pUploadProofSubtitle =>
      'Upload 1-3 clear images showing your payment confirmation';

  @override
  String get p2pUpTo3ImagesMax5Mb => 'Up to 3 images - Max 5 MB each';

  @override
  String get p2pNoteOptionalLabel => 'Note (optional)';

  @override
  String get p2pSubmitProofCta => 'Submit Proof';

  @override
  String get p2pSideBuy => 'Buy';

  @override
  String get p2pSideSell => 'Sell';

  @override
  String get p2pUnknownMethodLabel => 'Unknown method';

  @override
  String get p2pUnknownTraderLabel => 'Unknown trader';

  @override
  String get p2pNoPaymentMethodLabel => 'No payment method';

  @override
  String p2pMethodsCount(Object count) {
    return '$count methods';
  }

  @override
  String get p2pTradeStatusPendingPayment => 'Pending payment';

  @override
  String get p2pTradeStatusPendingRelease => 'Pending release';

  @override
  String get p2pTradeStatusReleaseConfirmed => 'Release confirmed';

  @override
  String get p2pAccountLabel => 'Account';

  @override
  String get cardTransactionFallbackTitle => 'Card transaction';

  @override
  String get cardTransactionDebitLabel => 'Debit';

  @override
  String get cardTransactionCreditLabel => 'Credit';

  @override
  String get walletUsdDepositLabel => 'USD Deposit';

  @override
  String get walletUsdWithdrawalLabel => 'USD Withdrawal';

  @override
  String get walletBuyUsdLabel => 'Buy USD';

  @override
  String get walletSellUsdLabel => 'Sell USD';

  @override
  String get walletDepositWithdrawLabel => 'Deposit / Withdraw';

  @override
  String get walletMoneyReceivedLabel => 'Money received';

  @override
  String get walletMoneySentLabel => 'Money sent';

  @override
  String get walletFallbackTitle => 'Transaction';

  @override
  String get p2pTraderLabel => 'Trader';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageFrench => 'French';

  @override
  String get profileLanguagePortuguese => 'Portuguese';

  @override
  String get profileLanguageSpanish => 'Spanish';

  @override
  String get profileLanguageSwahili => 'Swahili';

  @override
  String addressFieldRequired(Object fieldName) {
    return '$fieldName is required';
  }

  @override
  String get addressMax60CharsError => 'Maximum 60 characters allowed';

  @override
  String get addressAllowedCharsError =>
      'Only letters, numbers, spaces, and ,./-/ are allowed';

  @override
  String get addressFixErrorsBelow => 'Please fix the errors below';

  @override
  String get addressUnableSubmitError =>
      'Unable to submit address. Please try again.';

  @override
  String get addressCountryRequiredError => 'Country is required';

  @override
  String get p2pMinAmountHigherThanMaxError =>
      'The minimum amount can’t be higher than the maximum.';

  @override
  String get p2pNoAdsAvailableNowInfo => 'No ads available right now.';

  @override
  String get p2pFiltersApplyFailedError =>
      'We couldn’t apply those filters. Please try again.';

  @override
  String get p2pNoAdsForStatusInfo => 'No ads found for this status yet.';

  @override
  String get p2pAdMovedToInactiveInfo => 'Ad moved to inactive.';

  @override
  String get p2pAdUpdatedInfo => 'Ad updated.';

  @override
  String get p2pDeactivateOwnAdsError =>
      'You can only deactivate your own ads.';

  @override
  String get p2pAdNoLongerAvailableError => 'This ad is no longer available.';

  @override
  String get p2pDeactivateTryAgainError =>
      'We couldn’t deactivate this ad right now. Please try again.';

  @override
  String get p2pSessionVerifyProfileError =>
      'We couldn’t verify your session. Please sign in again to view your profile.';

  @override
  String get p2pNoPermissionViewProfileError =>
      'You don’t have permission to view this profile.';

  @override
  String get p2pProfileLoadingTryAgainError =>
      'We’re having trouble loading your profile right now. Please try again.';

  @override
  String get p2pProfileLoadFailedError =>
      'We couldn’t load your profile right now. Please try again.';

  @override
  String get p2pTradeIdentifyFailedError =>
      'We couldn’t identify this trade. Please try again.';

  @override
  String get p2pNoOrdersForStatusInfo => 'No orders in this status yet.';

  @override
  String get p2pFilterUnavailableError =>
      'That filter isn’t available. Please pick another status.';

  @override
  String get p2pOrdersLoadingTryAgainError =>
      'We’re having trouble loading your orders right now. Please try again.';

  @override
  String get p2pTradeNotFoundMaybeRemovedError =>
      'We couldn’t find this trade. It may have been removed.';

  @override
  String get p2pTradeCannotCancelAnymoreError =>
      'This trade can’t be cancelled anymore.';

  @override
  String get p2pTradeAlreadyCancelledError =>
      'This trade is already cancelled.';

  @override
  String get p2pTradeCancelFailedError =>
      'We couldn’t cancel this trade. Please try again.';

  @override
  String get p2pTradeCancelTryAgainError =>
      'We couldn’t cancel this trade right now. Please try again.';

  @override
  String get p2pOnlyBuyerCanCancelTradeError =>
      'Only the buyer who opened this trade can cancel it.';

  @override
  String get p2pOnlySellerCanCancelTradeError =>
      'Only the seller who listed this ad can cancel it.';

  @override
  String get cardsDetailsLoadUnavailableError =>
      'We’re having trouble loading your card details. Please try again soon.';

  @override
  String get cardsLockedMessage => 'Card locked';

  @override
  String get cardsUnlockedMessage => 'Card unlocked';

  @override
  String get cardsTerminatedMessage => 'Card terminated';

  @override
  String get cardsUpdateUnavailableError =>
      'We’re having trouble updating your card. Please try again soon.';

  @override
  String get cardsCloseUnavailableError =>
      'We’re having trouble closing your card. Please try again soon.';

  @override
  String get cardsTopupInvalidPositiveAmountError =>
      'The amount you entered isn’t valid. Please enter a positive amount.';

  @override
  String get cardsTopupReviewDetailsError =>
      'Please review the top-up details before continuing.';

  @override
  String get cardsTopupInsufficientBalanceError =>
      'You don’t have enough balance to complete this top-up.';

  @override
  String get cardsTopupCardInactiveError =>
      'This card is not active; unfreeze it before topping up.';

  @override
  String get cardsTopupActivateProfileError =>
      'You need to activate your card profile before you can continue.';

  @override
  String get cardsTopupWalletLowBalanceError =>
      'Your wallet balance is too low for this top-up.';

  @override
  String get cardsTopupAccountLoadFailedError =>
      'Something went wrong while loading your account. Please try again.';

  @override
  String get cardsTopupSessionInvalidError =>
      'Something isn’t right with your account session. Please sign in again.';

  @override
  String get cardsTopupCardNotFoundRefreshError =>
      'We couldn’t find this card. Please refresh and try again.';

  @override
  String get cardsTopupCardNotReadyError =>
      'Your card is being set up. Please try again in a moment.';

  @override
  String get cardsTopupCardNoLongerActiveError =>
      'This card is no longer active.';

  @override
  String get cardsTopupWalletNotFoundError =>
      'We couldn’t find your wallet. Please contact support.';

  @override
  String get cardsTopupWalletUnavailableError =>
      'The wallet service is temporarily unavailable. Please try again shortly.';

  @override
  String get cardsTopupFinishSetupError =>
      'You need to finish your card setup before topping up.';

  @override
  String get cardsTopupCardNotReadyYetError =>
      'Your card isn’t ready yet. Try again in a moment.';

  @override
  String get cardsTopupCardClosedError =>
      'This card has been closed and can’t be topped up.';

  @override
  String get cardsTopupReserveBalanceLowError =>
      'You don’t have enough available balance to reserve this amount.';

  @override
  String get cardsTopupCardNotFoundOnAccountError =>
      'We couldn’t find this card on your account.';

  @override
  String get cardsTopupProviderFailureError =>
      'We couldn’t complete your card top-up right now. Please try again shortly.';

  @override
  String get cardsTopupWalletUnavailableSoonError =>
      'Wallet service is temporarily unavailable. Please try again soon.';

  @override
  String get cardsWithdrawAmountAboveZeroError =>
      'Please enter an amount above zero.';

  @override
  String get cardsWithdrawAmountNotAllowedError =>
      'This amount can’t be withdrawn right now. Please adjust it and try again.';

  @override
  String get cardsWithdrawReviewDetailsError =>
      'Please review the withdrawal details before confirming.';

  @override
  String get cardsWithdrawCardBalanceLowError =>
      'Your card balance is not enough for this withdrawal.';

  @override
  String get cardsWithdrawAmountTooLowAfterFeesError =>
      'The amount is too small once fees are applied. Try a slightly higher amount.';

  @override
  String get cardsWithdrawCardNotReadyError =>
      'This card is still being set up. Please try again shortly.';

  @override
  String get cardsWithdrawCardClosedError =>
      'This card has been closed and can’t be used for withdrawals.';

  @override
  String get cardsWithdrawMinimumBalanceRequiredError =>
      'You must keep at least \$1 on the card.';

  @override
  String get cardsWithdrawCardInactiveError =>
      'This card is not active; unfreeze it before withdrawing.';

  @override
  String get cardsWithdrawSessionVerifyError =>
      'We couldn’t verify your account session. Please sign in again.';

  @override
  String get cardsWithdrawStartFailedError =>
      'We couldn’t start the withdrawal. Please try again.';

  @override
  String get cardsWithdrawProviderUnavailableMomentError =>
      'We’re having trouble reaching the card provider. Please try again in a moment.';

  @override
  String get cardsWithdrawValidAmountAboveZeroError =>
      'Please enter a valid amount above zero.';

  @override
  String get cardsWithdrawFinishSetupError =>
      'Please finish your card setup before withdrawing.';

  @override
  String get cardsWithdrawAmountTooLowAfterFeesHigherError =>
      'The amount is too small once fees are applied. Try a higher amount.';

  @override
  String get cardsWithdrawCompleteFailedError =>
      'We couldn’t complete the withdrawal. Please try again.';

  @override
  String cardsWithdrawTooManyAttemptsError(Object duration) {
    return 'Too many attempts. Please try again in about $duration.';
  }

  @override
  String get cardsWithdrawRequestInProgressRetryError =>
      'We’re processing another request. Give it a moment before retrying.';

  @override
  String get cardsWithdrawRequestInProgressWaitError =>
      'We’re processing another request. Please wait a moment and try again.';

  @override
  String get cardsWithdrawProviderUnavailableShortlyError =>
      'We’re having trouble with the card provider right now. Please try again shortly.';

  @override
  String get cardsCreationReadyContinueInfo =>
      'Your card is ready. You can continue setting up your card.';

  @override
  String get cardsCreationCompleteProfileError =>
      'Complete your profile to continue.';

  @override
  String get cardsCreationSessionExpiredContinueError =>
      'Session expired. Please sign in again to continue.';

  @override
  String get cardsCreationServiceUnavailableError =>
      'Card service temporarily unavailable. Please try again shortly.';

  @override
  String get cardsCreationAmountAboveZeroError =>
      'Enter an amount above 0.00 to continue.';

  @override
  String get cardsCreationPreviewMissingError =>
      'Preview details are missing. Please try again.';

  @override
  String get cardsCreationAddFundsError =>
      'Add funds to your wallet before creating this card.';

  @override
  String get cardsCreationWillAppearSoonInfo =>
      'Your card is created. It will appear in your cards list shortly.';

  @override
  String get cardsCreationReadyAppearSoonInfo =>
      'Your card is ready. It will appear in your cards list shortly.';

  @override
  String get cardsCreationRegisterProfileError =>
      'You need to register your card profile before continuing.';

  @override
  String get cardsCreationBalanceLowError =>
      'Your balance is too low to complete this action.';

  @override
  String get cardsCreationServiceUnavailableSoonError =>
      'Card services are temporarily unavailable. Please try again soon.';

  @override
  String get cardsCreationRegisterProfilePromptError =>
      'Please register your card profile before continuing.';

  @override
  String get cardsCreationRequestProcessingError =>
      'This request is already being processed.';

  @override
  String get cardsPromoRegistrationIssueError =>
      'Registration issue detected. Please close and try again.';

  @override
  String get cardsPromoBalanceChangedError =>
      'Your balance changed. Please close and try again after topping up.';

  @override
  String get cardsPromoUnavailableLaterError =>
      'Virtual card is no longer available. Please try again later.';

  @override
  String get cardsPromoWalletUnavailableError =>
      'Wallet service is temporarily unavailable. Please try again shortly.';

  @override
  String get expressOrderConfirmedFundsReleased =>
      'Order confirmed. Funds released to the customer.';

  @override
  String get expressDisputeOpenedUnderReview =>
      'Dispute opened. Under admin review.';

  @override
  String get expressNotAllowedActionError =>
      'You are not allowed to perform this action.';

  @override
  String get expressOrderNoLongerExistsError => 'Order no longer exists.';

  @override
  String get expressOrderUpdatedRefreshInfo =>
      'Order updated by another action. Refreshing...';

  @override
  String get expressCouldNotPickImages => 'Could not pick images.';

  @override
  String get expressDisputeMessageRequired => 'Dispute message is required.';

  @override
  String get expressWaitingForCustomerProof =>
      'Waiting for the customer to pay and upload proof.';

  @override
  String get expressNoProofUploadedYet => 'No proof uploaded yet.';

  @override
  String get cardsRepoIncompleteProfileError =>
      'Your profile is incomplete. Please finish KYC before creating a card.';

  @override
  String get cardsRepoRegistrationUnavailableError =>
      'Card registration is temporarily unavailable. Please try again shortly.';

  @override
  String get cardsRepoVirtualCardUnavailableError =>
      'Virtual card is not available right now. Please try again later.';

  @override
  String get cardsRepoServiceUnavailableError =>
      'Card service is temporarily unavailable. Please try again shortly.';

  @override
  String get loginInvalidCredentialsError =>
      'Invalid email or PIN. Please try again.';

  @override
  String get loginAccountInactiveError =>
      'Your account is not active. Please contact support.';

  @override
  String get loginTooManyAttemptsError =>
      'Too many login attempts. Please try again in a few minutes.';

  @override
  String get cardStatusUnknown => 'Unknown';

  @override
  String get expressOrderCancelledSnack => 'Order cancelled.';

  @override
  String get expressExpiring => 'Expiring...';

  @override
  String expressExpiresInHoursMinutes(Object hours, Object minutes) {
    return 'Expires in ${hours}h ${minutes}m';
  }

  @override
  String expressExpiresInMinutesSeconds(Object minutes, Object seconds) {
    return 'Expires in ${minutes}m ${seconds}s';
  }

  @override
  String expressExpiresInSeconds(Object seconds) {
    return 'Expires in ${seconds}s';
  }

  @override
  String get expressIvePaidUploadProofCta => 'I\'ve paid — upload proof';

  @override
  String get expressOrderExpiredTitle => 'Order expired';

  @override
  String get expressOrderCancelledTitle => 'Order cancelled';

  @override
  String get expressNoAgentAcceptedOrderMessage =>
      'No agent accepted this order in time. You can start a new deposit.';

  @override
  String get expressOrderExpiredBeforeCompletionMessage =>
      'This order expired before completion. You can start a new deposit.';

  @override
  String get expressOrderCancelledStartNewDepositMessage =>
      'This order was cancelled. You can start a new deposit.';

  @override
  String expressAttachUpToImagesError(Object maxImages) {
    return 'You can attach up to $maxImages images.';
  }

  @override
  String get expressCouldNotPickImagesTryAgain =>
      'Could not pick images. Please try again.';

  @override
  String get p2pSessionVerifyManageMethodsError =>
      'We couldn’t verify your session. Please sign in again to manage payment methods.';

  @override
  String get p2pPaymentMethodsLoadTryAgainSoonError =>
      'We’re having trouble loading your payment methods right now. Please try again shortly.';

  @override
  String get p2pPaymentMethodsLoadFailedError =>
      'We couldn’t load payment methods right now. Please try again.';

  @override
  String get p2pAlreadyConfirmedPaymentError =>
      'You already confirmed payment for this trade.';

  @override
  String get p2pSubmitProofCheckTryAgainError =>
      'We couldn’t submit those proofs. Please check and try again.';

  @override
  String get p2pProofImagesTooLargeError =>
      'Those images are too large. Please upload photos under 5 MB each.';

  @override
  String get p2pProofServerIssueRetryError =>
      'Server issue while submitting your proofs. Please try again in a moment.';

  @override
  String get p2pProofSubmitNowError =>
      'We couldn’t submit your proofs right now.';

  @override
  String get p2pProofNetworkUploadRetryError =>
      'Network issue while uploading. Check your connection and retry.';

  @override
  String get p2pProofUploadFailedError => 'Upload failed. Please try again.';

  @override
  String get p2pProofSubmitFailedRetryError =>
      'Something went wrong while submitting your proofs. Please try again.';

  @override
  String get p2pOnlyAssignedSellerReleaseError =>
      'Only the seller assigned to this trade can release the funds.';

  @override
  String get p2pTradeNotFoundMaybeClosedError =>
      'We couldn’t find this trade. It may have been closed already.';

  @override
  String get p2pTradeAlreadyReleasedError =>
      'This trade has already been released.';

  @override
  String get p2pReleaseAfterBuyerMarksPaidError =>
      'You can only release once the buyer marks payment as sent.';

  @override
  String get p2pReleaseTradeFailedError =>
      'We couldn’t release this trade right now. Please try again.';

  @override
  String get p2pReleaseFundsTryAgainSoonError =>
      'We’re having trouble releasing funds right now. Please try again soon.';

  @override
  String get p2pNotPartOfTradeRatingError =>
      'You’re not part of this trade, so you can’t leave a rating.';

  @override
  String get p2pTradeNotFoundRemovedError =>
      'We couldn’t find this trade. It might have been removed.';

  @override
  String get p2pAlreadyRatedTradeError => 'You already rated this trade.';

  @override
  String get p2pCreateProfileBeforeRatingError =>
      'Please create your profile before leaving a rating.';

  @override
  String get p2pRateAfterCompletedError =>
      'You can rate once the trade is marked as completed.';

  @override
  String get p2pRatingSubmitTryAgainError =>
      'We couldn’t submit your rating. Please try again.';

  @override
  String get p2pRatingSaveTryAgainSoonError =>
      'We’re having trouble saving your rating right now. Please try again shortly.';

  @override
  String get p2pTradeNotFoundOrNotParticipantError =>
      'We couldn’t find this trade or you’re not a participant.';

  @override
  String get p2pOpenDisputeAfterPaidError =>
      'You can only open a dispute after marking this trade as paid.';

  @override
  String get p2pTradeAlreadyInDisputeError =>
      'This trade already has an open dispute.';

  @override
  String get p2pOpenDisputeForTradeFailedError =>
      'We couldn’t open a dispute for this trade. Please try again.';

  @override
  String get p2pOpenDisputeTryAgainSoonError =>
      'We’re having trouble opening a dispute right now. Please try again shortly.';

  @override
  String get p2pOpenDisputeTryAgainError =>
      'We couldn’t open a dispute right now. Please try again.';

  @override
  String get p2pNoPermissionPublishAdError =>
      'You don’t have permission to publish this ad.';

  @override
  String get p2pSelectedPaymentMethodUnavailableRefreshError =>
      'One of the selected payment methods is no longer available. Refresh and try again.';

  @override
  String get p2pAdNoLongerAvailableRefreshError =>
      'This ad is no longer available. Refresh and try again.';

  @override
  String get p2pAddAtLeastOnePaymentMethodError =>
      'Add at least one payment method.';

  @override
  String get p2pPaymentMethodsNotNeededBuyAdsError =>
      'Payment methods aren’t needed for buy ads.';

  @override
  String get p2pRemoveDuplicatePaymentMethodsError =>
      'Remove duplicate payment methods before submitting.';

  @override
  String get p2pPaymentProviderInactiveChooseAnotherError =>
      'One of the payment providers is inactive right now. Please choose another option.';

  @override
  String get p2pPaymentMethodCurrencyMatchAdError =>
      'Payment method currency must match your ad currency.';

  @override
  String get p2pSelectedPaymentMethodsAnotherAccountError =>
      'Selected payment methods belong to another account.';

  @override
  String get p2pSelectedPaymentMethodsInvalidError =>
      'Selected payment methods are invalid for this ad.';

  @override
  String get p2pSellTotalExceedsBalanceError =>
      'Your sell total exceeds your available balance.';

  @override
  String p2pInsufficientBalancePublishAdError(Object adType) {
    return 'You don’t have enough balance to publish this $adType ad.';
  }

  @override
  String get p2pUseWholeNumbersAmountsError =>
      'Use whole numbers when entering amounts.';

  @override
  String get p2pReviewAmountsLimitsError =>
      'Please review your amounts and limits.';

  @override
  String get p2pTotalAmountAtLeastMinOrderError =>
      'Total amount must be at least your minimum order.';

  @override
  String get p2pMaxOrderAtLeastMinOrderError =>
      'Max order must be greater than or equal to the minimum order.';

  @override
  String get p2pEnterValidPriceRateError => 'Enter a valid price rate.';

  @override
  String get p2pInstructionsTooLongError =>
      'Instructions are too long (max 500 characters).';

  @override
  String get p2pRequestTimedOutError => 'Request timed out. Please try again.';

  @override
  String get p2pCreateAdFailedCheckInputError =>
      'Failed to create ad. Check your input and try again.';

  @override
  String get p2pDisplayNameLengthError =>
      'Your display name must be between 3 and 50 characters.';

  @override
  String get p2pUsernameFormatLengthError =>
      'Your username can only contain letters, numbers, or underscores, and must be 3–30 characters long.';

  @override
  String get p2pBioTooLongError =>
      'Your bio is too long. Please keep it under 500 characters.';

  @override
  String get p2pSelectValidLanguageError => 'Please select a valid language.';

  @override
  String get p2pSelectSupportedCurrencyError =>
      'Please select a supported currency.';

  @override
  String get p2pDisplayNameUsernameTakenError =>
      'That display name or username is already taken. Please choose another one.';

  @override
  String get p2pProfileSaveTryAgainSoonError =>
      'We’re having trouble saving your profile right now. Please try again shortly.';

  @override
  String get p2pSessionExpiredSignInTryAgainError =>
      'Your session has expired. Please sign in and try again.';

  @override
  String get p2pCannotTradeOwnAdError => 'You can’t trade on your own ad.';

  @override
  String get p2pAmountWithinAdLimitsError =>
      'Enter an amount within the ad’s limits.';

  @override
  String get p2pSellerInsufficientAvailableError =>
      'The seller doesn’t have enough available for that amount.';

  @override
  String get p2pSelectPaymentMethodOnAdError =>
      'Select a payment method offered on this ad.';

  @override
  String get p2pBuyerNoSupportedPaymentMethodsError =>
      'Buyer has not shared any supported payment methods yet.';

  @override
  String get p2pReserveFundsTryAgainError =>
      'We couldn’t reserve funds right now. Please try again.';

  @override
  String get p2pStartTradeReviewInputError =>
      'We couldn’t start this trade. Please review your input and try again.';

  @override
  String get p2pStartTradeTryAgainError =>
      'We couldn’t start this trade. Please try again.';

  @override
  String get p2pPleaseWaitLabel => 'Please wait...';

  @override
  String get p2pHowMuchUsdBuy => 'How much USD do you want to buy?';

  @override
  String get p2pHowMuchUsdSell => 'How much USD do you want to sell?';

  @override
  String get p2pStatusDescriptionActiveTrade => 'Active trade.';

  @override
  String get p2pStatusDescriptionBuyerMarkedPaid =>
      'Buyer marked the trade as paid. Review the proof before releasing the funds.';

  @override
  String get p2pStatusDescriptionReleasedBySeller =>
      'You released this trade. Funds are on the way to the buyer.';

  @override
  String get p2pStatusDescriptionCompleted => 'Trade completed successfully.';

  @override
  String get p2pStatusDescriptionCancelled => 'This trade was cancelled.';

  @override
  String get p2pStatusDescriptionUnderReview => 'This trade is under review.';

  @override
  String get p2pStatusDescriptionExpiredBeforeConfirm =>
      'This trade expired before the buyer confirmed payment.';

  @override
  String get p2pStatusDescriptionPaymentSent =>
      'Payment sent. The seller has been notified. You’ll receive funds once they release the funds.';

  @override
  String get p2pStatusDescriptionSellerConfirmedReleasing =>
      'Seller confirmed payment. We’re releasing your funds shortly.';

  @override
  String get p2pStatusDescriptionCompletedWalletUpdated =>
      'Trade completed successfully. Funds should now reflect in your wallet.';

  @override
  String get p2pStatusDescriptionCancelledSupportHelp =>
      'This trade was cancelled. Reach out to support if you need help.';

  @override
  String get p2pStatusDescriptionUnderReviewTeamContact =>
      'This trade is under review. Our team will contact you if more details are needed.';

  @override
  String get p2pFilterAll => 'All';

  @override
  String get p2pFilterPending => 'Pending';

  @override
  String get p2pFilterActive => 'Active';

  @override
  String get p2pFilterInactive => 'Inactive';

  @override
  String get p2pFilterCompleted => 'Completed';

  @override
  String get p2pFilterRejected => 'Rejected';

  @override
  String get p2pFilterPaid => 'Paid';

  @override
  String get p2pFilterReleased => 'Released';

  @override
  String get p2pFilterCancelled => 'Cancelled';

  @override
  String get p2pFilterDisputed => 'Disputed';

  @override
  String get p2pFilterExpired => 'Expired';

  @override
  String get transactionsRangeLast30Days => 'Last 30 days';

  @override
  String get transactionsRangeLast7Days => 'Last 7 days';

  @override
  String get transactionsRangeLast90Days => 'Last 90 days';

  @override
  String transactionsRangeLastNDays(Object days) {
    return 'Last $days days';
  }

  @override
  String get cryptoNetworkPolygonMatic => 'Polygon (MATIC)';

  @override
  String get cryptoNetworkEthereumErc20 => 'Ethereum (ERC-20)';

  @override
  String get cryptoNetworkBscBep20 => 'BNB Smart Chain (BEP-20)';

  @override
  String get cryptoNetworkTronTrc20 => 'Tron (TRC-20)';

  @override
  String get cryptoNetworkHintLowFeesFast => 'Low fees • Fast';

  @override
  String get cryptoNetworkHintHighFeesSecure => 'High fees • Secure';

  @override
  String get cryptoNetworkHintVeryLowFeesFast => 'Very low fees • Fast';

  @override
  String get cryptoNetworkShortPolygon => 'Polygon';

  @override
  String get cryptoNetworkShortEthereum => 'Ethereum';

  @override
  String get cryptoNetworkShortBsc => 'BSC';

  @override
  String get cryptoNetworkShortTron => 'Tron';

  @override
  String get cryptoNetworkHintVeryLowFeesFastConfirmations =>
      'Very low fees • Fast confirmations';

  @override
  String get cryptoNetworkHintLowFeesFastConfirmations =>
      'Low fees • Fast confirmations';

  @override
  String get cryptoNetworkHintLowFeesBroadSupport => 'Low fees • Broad support';

  @override
  String get cryptoNetworkHintHighFeesMostCompatible =>
      'High fees • Most compatible';

  @override
  String get notProvidedLabel => 'Not provided';

  @override
  String get withdrawTrc20LengthError =>
      'TRC-20 addresses must be exactly 34 characters long.';

  @override
  String get withdrawTrc20StartWithTError =>
      'TRC-20 addresses must start with the letter T.';

  @override
  String get withdrawTrc20Base58Error =>
      'TRC-20 addresses use Base58 characters only.';

  @override
  String get withdrawNetworkAddressStartsWith0xError =>
      'This network requires addresses that start with 0x.';

  @override
  String get withdrawAddressLength42Error =>
      'This address must be exactly 42 characters long.';

  @override
  String get withdrawHexCharactersOnlyError =>
      'Use hexadecimal characters only (0-9, a-f).';

  @override
  String get sendMoneyRecipientRequiredError =>
      'Please select a recipient first.';

  @override
  String get sendMoneyInvalidTransferDetailsError =>
      'Invalid transfer details.';

  @override
  String sendMoneyTransferToDescription(Object recipientName) {
    return 'Transfer to $recipientName';
  }

  @override
  String get forgotPinCodeSentIfAccountExists =>
      'If an account exists, we sent a verification code to your email';

  @override
  String get resetPinCodeRequiredError => 'Verification code is required';

  @override
  String get resetPinCodeMustBeSixDigitsError => 'Code must be 6 digits';

  @override
  String get resetPinConfirmRequiredError => 'Please confirm your PIN';

  @override
  String get resetPinMismatchError => 'PINs do not match';

  @override
  String get verifyEmailFailedToSendCodeError => 'Failed to send code';

  @override
  String get verifyEmailInvalidOrExpiredCodeError => 'Invalid or expired code';

  @override
  String get verifyEmailUserNotFoundError => 'User not found';

  @override
  String get verifyEmailServerErrorTryAgain => 'Server error. Try again';

  @override
  String get verifyEmailUnexpectedError => 'Unexpected error occurred';

  @override
  String get verifyEmailFailedToResendCodeError => 'Failed to resend code';

  @override
  String get quickAuthSessionExpiredError =>
      'Session expired. Please log in again.';

  @override
  String get quickAuthNoInternetError =>
      'No internet connection. Please check your network and try again.';

  @override
  String get quickAuthAuthenticationFailedError =>
      'Authentication failed. Please log in again.';

  @override
  String get quickAuthBiometricPromptReason => 'Unlock Opei with biometric';

  @override
  String get quickAuthBiometricFailedError => 'Biometric authentication failed';

  @override
  String get quickAuthLoggedOutCreateNewPinInfo =>
      'Logged out. Please sign in to create a new PIN.';

  @override
  String get quickAuthInvalidPinOneAttemptRemaining =>
      'Invalid PIN. 1 attempt remaining.';

  @override
  String quickAuthInvalidPinAttemptsRemaining(Object attempts) {
    return 'Invalid PIN. $attempts attempts remaining.';
  }

  @override
  String get quickAuthTooManyPinAttemptsError =>
      'Too many incorrect PIN attempts. Please log in again to set a new PIN.';

  @override
  String get quickAuthSetupNoActiveUserError =>
      'No active user context available for quick auth setup';

  @override
  String get quickAuthSetupPinSavedSuccess => 'PIN setup complete';

  @override
  String get quickAuthSetupPinSaveFailedError =>
      'Failed to save PIN. Please try again.';

  @override
  String get quickAuthSetupBiometricUnavailableError =>
      'Biometric authentication is not available on this device';

  @override
  String get quickAuthSetupBiometricPromptReason =>
      'Set up biometric authentication for quick access';

  @override
  String get quickAuthSetupBiometricEnabledSuccess =>
      'Biometric authentication enabled';

  @override
  String get quickAuthSetupBiometricEnableFailedError =>
      'Failed to enable biometric authentication';

  @override
  String get quickAuthSetupConfirmPinTitle => 'Confirm PIN';

  @override
  String get quickAuthSetupCreatePinTitle => 'Create PIN';

  @override
  String get quickAuthSetupConfirmPinSubtitle =>
      'Enter your PIN again to confirm';

  @override
  String get quickAuthSetupCreatePinSubtitle =>
      'Choose a 6-digit PIN to sign in faster';

  @override
  String get kycSessionExpiredError => 'Session expired. Please log in again.';

  @override
  String get kycVerificationAlreadyCompleteError =>
      'Verification already complete!';

  @override
  String get kycVerificationUnderReviewError =>
      'Your verification is under review. Please check back later.';

  @override
  String get kycAddressRequiredBeforeVerificationError =>
      'Please complete your address information first.';

  @override
  String get kycAccountSuspendedError =>
      'Account suspended. Please contact support.';

  @override
  String get kycAccountNotFoundError =>
      'Account not found. Please log in again.';

  @override
  String get kycServiceUnavailableError =>
      'Service temporarily unavailable. Please try again later.';

  @override
  String get cardsTransactionsSessionExpiredError =>
      'Your session has expired. Please log in again.';

  @override
  String get cardsCardNotFoundError => 'We couldn\'t find this card.';

  @override
  String get cardsTransactionsLoadTryAgainSoonError =>
      'We\'re having trouble loading your transactions. Please try again soon.';

  @override
  String get expressSetupSelectCurrencyTitle => 'Select currency';

  @override
  String get expressSetupPaymentMethodTitle => 'Payment method';

  @override
  String get expressSetupEnterAmountTitle => 'Enter amount';

  @override
  String get expressSetupCurrencyHint =>
      'Choose the local currency you will be paying in.';

  @override
  String get expressSetupReviewDepositCta => 'Review deposit';

  @override
  String get expressPreviewQuoteUnavailableTitle => 'Couldn\'t get a quote';

  @override
  String get expressOrderAcceptedToast =>
      'Order accepted. Find it under \"My queue\".';

  @override
  String get expressSectionActive => 'ACTIVE';

  @override
  String get expressSectionHistory => 'HISTORY';

  @override
  String get mobileMoneyDescriptionMinLengthError =>
      'Enter a clear description (at least 3 characters).';

  @override
  String get mobileMoneyDescriptionMaxLengthError =>
      'Description is too long (max 120 characters).';

  @override
  String get mobileMoneyMissingReviewOrSessionError =>
      'Missing review or session. Please try again.';

  @override
  String get mobileMoneyAddValidDescriptionError =>
      'Please go back and add a valid description.';

  @override
  String get mobileMoneyDescriptionTooLong120Error =>
      'Description is too long. Use 120 characters or less.';

  @override
  String get trustFooterBankGradeEncryption => 'Bank-grade encryption';

  @override
  String get p2pUploadAtLeastOneProofError =>
      'Upload at least one proof first.';

  @override
  String p2pSkippedLargeImagesCount(Object count) {
    return 'Skipped $count images over 5 MB';
  }

  @override
  String p2pSkippedUnreadableFilesCount(Object count) {
    return 'Skipped $count unreadable files';
  }

  @override
  String get p2pSelectUpToFiveTagsError => 'You can select up to 5 tags.';

  @override
  String get p2pEnterValidAmountToContinueError =>
      'Enter a valid amount to continue.';

  @override
  String p2pEnterAtLeastAmountError(Object amount) {
    return 'Enter at least $amount.';
  }

  @override
  String p2pEnterNoMoreThanAmountError(Object amount) {
    return 'Enter no more than $amount.';
  }

  @override
  String p2pOnlyAmountLeftInAdError(Object amount) {
    return 'Only $amount left in this ad.';
  }

  @override
  String get p2pAdCannotAcceptPaymentsRightNowError =>
      'This ad can’t accept payments right now.';

  @override
  String get p2pSelectedImageReadFailedError =>
      'One of the selected images could not be read. Please re-upload.';

  @override
  String get transactionTypeLabel => 'Type';

  @override
  String get transactionTransactionTypeLabel => 'Transaction type';

  @override
  String get transactionDirectionLabel => 'Direction';

  @override
  String get transactionIncomingValue => 'Incoming';

  @override
  String get transactionOutgoingValue => 'Outgoing';

  @override
  String get transactionMethodLabel => 'Method';

  @override
  String get transactionFromLabel => 'From';

  @override
  String get transactionToLabel => 'To';

  @override
  String get transactionDateTimeLabel => 'Date & time';

  @override
  String get transactionStatusCompleted => 'Completed';

  @override
  String get transactionStatusFailed => 'Failed';

  @override
  String get transactionStatusDeclined => 'Declined';

  @override
  String get tokenTetherName => 'Tether';

  @override
  String get tokenUsdCoinName => 'USD Coin';

  @override
  String get mobileMoneyCountryGhana => 'Ghana';

  @override
  String get mobileMoneyCountryKenya => 'Kenya';

  @override
  String get mobileMoneyCountryUganda => 'Uganda';

  @override
  String get mobileMoneyCountryRwanda => 'Rwanda';

  @override
  String get mobileMoneyCountrySenegal => 'Senegal';

  @override
  String get mobileMoneyCountryCoteDIvoire => 'Côte d\'Ivoire';

  @override
  String get mobileMoneyCountryCameroon => 'Cameroon';

  @override
  String get mobileMoneyCountryDrCongo => 'DR Congo';

  @override
  String get mobileMoneyCountryGabon => 'Gabon';

  @override
  String get mobileMoneyCountryGambia => 'Gambia';

  @override
  String get mobileMoneyCountryZambia => 'Zambia';
}
