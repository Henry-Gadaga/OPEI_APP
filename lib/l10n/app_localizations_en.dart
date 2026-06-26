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
  String get addressAptSuiteLabel => 'Apt / Suite';

  @override
  String get addressZipCodeLabel => 'ZIP code';

  @override
  String get addressCityLabel => 'City';

  @override
  String get addressStateLabel => 'State';

  @override
  String get addressBvnLabel => 'BVN';

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
  String get p2pSubmitRatingCta => 'Submit Rating';

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
}
