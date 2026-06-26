import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Opei - USD Financial Tools'**
  String get appTitle;

  /// No description provided for @languageChooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageChooseTitle;

  /// No description provided for @languageChooseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your preferred language.\nYou can change it anytime in Profile.'**
  String get languageChooseSubtitle;

  /// No description provided for @languageEnglishTitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishTitle;

  /// No description provided for @languageEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishSubtitle;

  /// No description provided for @languagePortugueseTitle.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortugueseTitle;

  /// No description provided for @languagePortugueseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortugueseSubtitle;

  /// No description provided for @continueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCta;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get welcomeCreateAccount;

  /// No description provided for @welcomeAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get welcomeAlreadyHaveAccount;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @welcomeLegalPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get welcomeLegalPrefix;

  /// No description provided for @welcomeLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get welcomeLegalTerms;

  /// No description provided for @welcomeLegalAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get welcomeLegalAnd;

  /// No description provided for @welcomeLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get welcomeLegalPrivacy;

  /// No description provided for @loginHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginHeaderTitle;

  /// No description provided for @loginHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your Opei account securely.'**
  String get loginHeaderSubtitle;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your account'**
  String get loginWelcomeSubtitle;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailAddressHint;

  /// No description provided for @emailRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequiredError;

  /// No description provided for @emailInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get emailInvalidError;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit PIN'**
  String get pinLabel;

  /// No description provided for @forgotPinCta.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPinCta;

  /// No description provided for @forgotPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPinTitle;

  /// No description provided for @forgotPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset it in two quick steps.'**
  String get forgotPinSubtitle;

  /// No description provided for @forgotPinEmailCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email a code'**
  String get forgotPinEmailCodeTitle;

  /// No description provided for @forgotPinEmailCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email associated with your account and we\'ll send a 6-digit code.'**
  String get forgotPinEmailCodeSubtitle;

  /// No description provided for @forgotPinSendCodeCta.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotPinSendCodeCta;

  /// No description provided for @forgotPinRememberedCta.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get forgotPinRememberedCta;

  /// No description provided for @pinHint.
  ///
  /// In en, this message translates to:
  /// **'••••••'**
  String get pinHint;

  /// No description provided for @pinRequiredError.
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get pinRequiredError;

  /// No description provided for @pinInvalidError.
  ///
  /// In en, this message translates to:
  /// **'PIN must be exactly 6 digits'**
  String get pinInvalidError;

  /// No description provided for @loginSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignInCta;

  /// No description provided for @loginUseFaceId.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID'**
  String get loginUseFaceId;

  /// No description provided for @loginUseFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint'**
  String get loginUseFingerprint;

  /// No description provided for @orSeparator.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orSeparator;

  /// No description provided for @createNewAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Create new account'**
  String get createNewAccountCta;

  /// No description provided for @signupSubtitleEmail.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with your email.'**
  String get signupSubtitleEmail;

  /// No description provided for @signupSubtitlePhone.
  ///
  /// In en, this message translates to:
  /// **'Now your phone number.'**
  String get signupSubtitlePhone;

  /// No description provided for @signupSubtitlePin.
  ///
  /// In en, this message translates to:
  /// **'Choose a 6-digit PIN.'**
  String get signupSubtitlePin;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupTitle;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequiredError;

  /// No description provided for @phoneNumberExactDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly {digits} digits'**
  String phoneNumberExactDigitsError(Object digits);

  /// No description provided for @phoneNumberMinDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least {digits} digits'**
  String phoneNumberMinDigitsError(Object digits);

  /// No description provided for @phoneNumberMaxDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Phone number can be at most {digits} digits'**
  String phoneNumberMaxDigitsError(Object digits);

  /// No description provided for @legalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalTitle;

  /// No description provided for @legalBackToHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get legalBackToHomeCta;

  /// No description provided for @legalLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: 3 January 2025'**
  String get legalLastUpdated;

  /// No description provided for @legalDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get legalDocumentsTitle;

  /// No description provided for @termsAndConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditionsTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @legalCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Opei Technologies LLC'**
  String get legalCompanyName;

  /// No description provided for @legalSupportEmail.
  ///
  /// In en, this message translates to:
  /// **'Support Email: info@opeillc.com'**
  String get legalSupportEmail;

  /// No description provided for @legalSupportEmailShort.
  ///
  /// In en, this message translates to:
  /// **'Email: info@opeillc.com'**
  String get legalSupportEmailShort;

  /// No description provided for @legalCompanyAddress.
  ///
  /// In en, this message translates to:
  /// **'500 Westover Dr, 31775\nSanford, NC 27330\nUnited States'**
  String get legalCompanyAddress;

  /// No description provided for @legalCompanyPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone: +1 (681) 547-8620'**
  String get legalCompanyPhone;

  /// No description provided for @legalCopyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Opei Technologies LLC.'**
  String get legalCopyrightNotice;

  /// No description provided for @termsDocumentBody.
  ///
  /// In en, this message translates to:
  /// **'These Terms and Conditions govern your access to and use of Opei services.\n\nBy creating an account or using Opei, you agree to these Terms.\n\nOpei is a financial technology platform and relies on third-party providers for payments, cards, identity verification, and related services.\n\nYou must provide accurate information, keep your account credentials secure, and use the platform lawfully.\n\nTransactions may be irreversible. You are responsible for recipient details, amounts, and confirmation steps.\n\nFor P2P transactions, users transact directly with each other. Opei may review disputes at its discretion.\n\nVirtual card and wallet services are subject to third-party availability, rules, and processing outcomes.\n\nFees may apply and may change over time. Third-party fees can also apply.\n\nOpei may suspend, restrict, or terminate accounts for compliance, fraud prevention, risk, or legal reasons.\n\nServices are provided \"as is\" and \"as available\". To the extent permitted by law, liability is limited.\n\nThese Terms may be updated. Continued use of Opei means acceptance of updated Terms.'**
  String get termsDocumentBody;

  /// No description provided for @privacyPolicyDocumentBody.
  ///
  /// In en, this message translates to:
  /// **'This Privacy Policy explains how Opei collects, uses, and protects personal information.\n\nBy using Opei, you acknowledge and accept this Privacy Policy.\n\nWe may collect data you provide (such as name, email, phone, address, and verification details) and technical usage data.\n\nWe use personal information to operate services, verify identity, process transactions, improve product quality, and comply with legal obligations.\n\nWe may share data with trusted service providers and authorities when required by law.\n\nYour information may be processed in countries outside your residence, including the United States.\n\nWe retain data for as long as needed for service operation, compliance, fraud prevention, and dispute resolution.\n\nWe apply administrative, technical, and organizational safeguards, but no system can guarantee absolute security.\n\nDepending on jurisdiction, you may have rights such as access, correction, deletion requests, and objection to processing.\n\nWe may update this Policy over time. Continued use of Opei means acceptance of updated Policy terms.'**
  String get privacyPolicyDocumentBody;

  /// No description provided for @selectCountryCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select country code'**
  String get selectCountryCodeTitle;

  /// No description provided for @searchCountryCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Search country or code'**
  String get searchCountryCodeHint;

  /// No description provided for @signupPinHelper.
  ///
  /// In en, this message translates to:
  /// **'Keep this safe - it authorises all your payments.'**
  String get signupPinHelper;

  /// No description provided for @signupCreateAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signupCreateAccountCta;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @resetPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPinTitle;

  /// No description provided for @resetPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code and choose a new PIN.'**
  String get resetPinSubtitle;

  /// No description provided for @resetPinCodeAndNewPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Code & new PIN'**
  String get resetPinCodeAndNewPinTitle;

  /// No description provided for @resetPinCodePrefix.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to '**
  String get resetPinCodePrefix;

  /// No description provided for @resetPinCodeSuffix.
  ///
  /// In en, this message translates to:
  /// **' and choose your new PIN.'**
  String get resetPinCodeSuffix;

  /// No description provided for @resetPinVerificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get resetPinVerificationCodeLabel;

  /// No description provided for @resetPinVerificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get resetPinVerificationCodeHint;

  /// No description provided for @resetPinNewPinLabel.
  ///
  /// In en, this message translates to:
  /// **'New 6-digit PIN'**
  String get resetPinNewPinLabel;

  /// No description provided for @resetPinConfirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get resetPinConfirmPinLabel;

  /// No description provided for @resetPinHelperText.
  ///
  /// In en, this message translates to:
  /// **'You\'ll use this to sign in and authorise payments.'**
  String get resetPinHelperText;

  /// No description provided for @resetPinCta.
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get resetPinCta;

  /// No description provided for @resetPinDidntGetCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get a code?'**
  String get resetPinDidntGetCode;

  /// No description provided for @resetPinRequestNewCta.
  ///
  /// In en, this message translates to:
  /// **'Request new'**
  String get resetPinRequestNewCta;

  /// No description provided for @resetPinUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get resetPinUpdatedTitle;

  /// No description provided for @resetPinUpdatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your new 6-digit PIN is set. Sign in to continue.'**
  String get resetPinUpdatedSubtitle;

  /// No description provided for @resetPinGoToSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get resetPinGoToSignInCta;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 4  •  Enter the 6-digit code we sent.'**
  String get verifyEmailSubtitle;

  /// No description provided for @verifyEmailInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get verifyEmailInboxTitle;

  /// No description provided for @verifyEmailSentToPrefix.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to '**
  String get verifyEmailSentToPrefix;

  /// No description provided for @verifyEmailWrongEmailCta.
  ///
  /// In en, this message translates to:
  /// **'Wrong email? Start over'**
  String get verifyEmailWrongEmailCta;

  /// No description provided for @verifyEmailSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get verifyEmailSigningOut;

  /// No description provided for @verifyEmailVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifyEmailVerifying;

  /// No description provided for @verifyEmailDidntGetCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code? '**
  String get verifyEmailDidntGetCode;

  /// No description provided for @verifyEmailResendCta.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get verifyEmailResendCta;

  /// No description provided for @verifyEmailResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {timerText}'**
  String verifyEmailResendIn(Object timerText);

  /// No description provided for @verifyEmailCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent'**
  String get verifyEmailCodeSent;

  /// No description provided for @verifyEmailNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Email not found. Please sign up again.'**
  String get verifyEmailNotFoundError;

  /// No description provided for @topupSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Top up card'**
  String get topupSheetTitle;

  /// No description provided for @topupAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'TOP UP AMOUNT'**
  String get topupAmountLabel;

  /// No description provided for @topupPreviewCta.
  ///
  /// In en, this message translates to:
  /// **'Preview top-up'**
  String get topupPreviewCta;

  /// No description provided for @loadingPreview.
  ///
  /// In en, this message translates to:
  /// **'Loading preview...'**
  String get loadingPreview;

  /// No description provided for @paymentBreakdown.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT BREAKDOWN'**
  String get paymentBreakdown;

  /// No description provided for @topupAmountRow.
  ///
  /// In en, this message translates to:
  /// **'Top-up amount'**
  String get topupAmountRow;

  /// No description provided for @feeRow.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get feeRow;

  /// No description provided for @totalToPayRow.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get totalToPayRow;

  /// No description provided for @afterThisPayment.
  ///
  /// In en, this message translates to:
  /// **'AFTER THIS PAYMENT'**
  String get afterThisPayment;

  /// No description provided for @walletBalanceRow.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get walletBalanceRow;

  /// No description provided for @confirmTopupCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm top-up'**
  String get confirmTopupCta;

  /// No description provided for @editAmountCta.
  ///
  /// In en, this message translates to:
  /// **'Edit amount'**
  String get editAmountCta;

  /// No description provided for @youAreToppingUpLabel.
  ///
  /// In en, this message translates to:
  /// **'YOU\'RE TOPPING UP'**
  String get youAreToppingUpLabel;

  /// No description provided for @youAreWithdrawingLabel.
  ///
  /// In en, this message translates to:
  /// **'YOU\'RE WITHDRAWING'**
  String get youAreWithdrawingLabel;

  /// No description provided for @topupCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Top-up complete'**
  String get topupCompleteTitle;

  /// No description provided for @topupCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your card balance will update shortly.'**
  String get topupCompleteSubtitle;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get referenceLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @totalPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get totalPaidLabel;

  /// No description provided for @doneCta.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneCta;

  /// No description provided for @topupFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Top-up failed'**
  String get topupFailedTitle;

  /// No description provided for @topupFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete top-up. Please try again.'**
  String get topupFailedSubtitle;

  /// No description provided for @tryAgainCta.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainCta;

  /// No description provided for @closeCta.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeCta;

  /// No description provided for @withdrawSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw from card'**
  String get withdrawSheetTitle;

  /// No description provided for @withdrawAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAWAL AMOUNT'**
  String get withdrawAmountLabel;

  /// No description provided for @withdrawPreviewCta.
  ///
  /// In en, this message translates to:
  /// **'Preview withdrawal'**
  String get withdrawPreviewCta;

  /// No description provided for @withdrawAmountRow.
  ///
  /// In en, this message translates to:
  /// **'Withdraw amount'**
  String get withdrawAmountRow;

  /// No description provided for @youWillReceiveRow.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive'**
  String get youWillReceiveRow;

  /// No description provided for @afterThisWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'AFTER THIS WITHDRAWAL'**
  String get afterThisWithdrawal;

  /// No description provided for @cardBalanceNowRow.
  ///
  /// In en, this message translates to:
  /// **'Card balance now'**
  String get cardBalanceNowRow;

  /// No description provided for @cardBalanceAfterRow.
  ///
  /// In en, this message translates to:
  /// **'Card balance after'**
  String get cardBalanceAfterRow;

  /// No description provided for @confirmWithdrawalCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm withdrawal'**
  String get confirmWithdrawalCta;

  /// No description provided for @withdrawalCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal complete'**
  String get withdrawalCompleteTitle;

  /// No description provided for @withdrawalCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Funds will arrive in your wallet shortly.'**
  String get withdrawalCompleteSubtitle;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @withdrawalFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal failed'**
  String get withdrawalFailedTitle;

  /// No description provided for @withdrawalFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the withdrawal. Please try again.'**
  String get withdrawalFailedSubtitle;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSectionAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get profileSectionAccountInfo;

  /// No description provided for @profileSectionPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profileSectionPersonalInfo;

  /// No description provided for @profileSectionAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileSectionAddress;

  /// No description provided for @profileSectionVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get profileSectionVerification;

  /// No description provided for @profileSectionRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get profileSectionRewards;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @profileSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get profileSectionLegal;

  /// No description provided for @profileSectionActions.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get profileSectionActions;

  /// No description provided for @profileSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get profileSectionSecurity;

  /// No description provided for @profileEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmailLabel;

  /// No description provided for @profilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profilePhoneLabel;

  /// No description provided for @profileVerificationStageLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Stage'**
  String get profileVerificationStageLabel;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullNameLabel;

  /// No description provided for @profileDobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profileDobLabel;

  /// No description provided for @profileGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGenderLabel;

  /// No description provided for @profileNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get profileNationalityLabel;

  /// No description provided for @profileIdTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'ID Type'**
  String get profileIdTypeLabel;

  /// No description provided for @profileIdNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get profileIdNumberLabel;

  /// No description provided for @profileCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profileCountryLabel;

  /// No description provided for @profileStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get profileStateLabel;

  /// No description provided for @profileCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profileCityLabel;

  /// No description provided for @profileAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profileAddressLabel;

  /// No description provided for @profileZipCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get profileZipCodeLabel;

  /// No description provided for @profileUpdateAddressCta.
  ///
  /// In en, this message translates to:
  /// **'Update Address'**
  String get profileUpdateAddressCta;

  /// No description provided for @profileAddAddressCta.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get profileAddAddressCta;

  /// No description provided for @profileNoAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No address added yet'**
  String get profileNoAddressSubtitle;

  /// No description provided for @profileIdentityVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Verified'**
  String get profileIdentityVerifiedTitle;

  /// No description provided for @profileIdentityVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been successfully verified'**
  String get profileIdentityVerifiedSubtitle;

  /// No description provided for @profileReferralsLabel.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get profileReferralsLabel;

  /// No description provided for @profileReferralsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your link and track earnings'**
  String get profileReferralsSubtitle;

  /// No description provided for @profileLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageLabel;

  /// No description provided for @profileTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTermsLabel;

  /// No description provided for @profilePrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacyLabel;

  /// No description provided for @profileLogoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogoutLabel;

  /// No description provided for @profileUnableLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get profileUnableLoadTitle;

  /// No description provided for @retryCta.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryCta;

  /// No description provided for @profileKycPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get profileKycPromptTitle;

  /// No description provided for @profileKycPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to unlock all features'**
  String get profileKycPromptSubtitle;

  /// No description provided for @naValue.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get naValue;

  /// No description provided for @languageUpdatedPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Language updated to Portuguese.'**
  String get languageUpdatedPortuguese;

  /// No description provided for @languageUpdatedEnglish.
  ///
  /// In en, this message translates to:
  /// **'Language updated to English.'**
  String get languageUpdatedEnglish;

  /// No description provided for @languageUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update language. Please try again.'**
  String get languageUpdateFailed;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageTitle;

  /// No description provided for @selectLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your app language preference.'**
  String get selectLanguageSubtitle;

  /// No description provided for @languageUseEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use English throughout the app'**
  String get languageUseEnglishSubtitle;

  /// No description provided for @languageUsePortugueseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Portuguese throughout the app'**
  String get languageUsePortugueseSubtitle;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutTitle;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again next time'**
  String get logoutSubtitle;

  /// No description provided for @cancelCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelCta;

  /// No description provided for @quickAuthPinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN Authentication'**
  String get quickAuthPinLabel;

  /// No description provided for @loadingText.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// No description provided for @enabledText.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledText;

  /// No description provided for @disabledText.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledText;

  /// No description provided for @faceIdPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set up Face ID for quick sign-in'**
  String get faceIdPrompt;

  /// No description provided for @fingerprintPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set up fingerprint for quick sign-in'**
  String get fingerprintPrompt;

  /// No description provided for @faceIdDisabled.
  ///
  /// In en, this message translates to:
  /// **'Face ID sign-in disabled.'**
  String get faceIdDisabled;

  /// No description provided for @fingerprintDisabled.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint sign-in disabled.'**
  String get fingerprintDisabled;

  /// No description provided for @biometricUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update biometric settings. Please try again.'**
  String get biometricUpdateFailed;

  /// No description provided for @faceIdSignInLabel.
  ///
  /// In en, this message translates to:
  /// **'Face ID Sign-in'**
  String get faceIdSignInLabel;

  /// No description provided for @fingerprintSignInLabel.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Sign-in'**
  String get fingerprintSignInLabel;

  /// No description provided for @biometricEnabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enabled - sign in with a glance'**
  String get biometricEnabledSubtitle;

  /// No description provided for @faceIdDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID instead of typing your PIN'**
  String get faceIdDisabledSubtitle;

  /// No description provided for @fingerprintDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint instead of typing your PIN'**
  String get fingerprintDisabledSubtitle;

  /// No description provided for @dashboardGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get dashboardGreetingMorning;

  /// No description provided for @dashboardGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get dashboardGreetingAfternoon;

  /// No description provided for @dashboardGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get dashboardGreetingEvening;

  /// No description provided for @dashboardNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get dashboardNavHome;

  /// No description provided for @dashboardNavCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get dashboardNavCards;

  /// No description provided for @dashboardNavActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get dashboardNavActivity;

  /// No description provided for @dashboardNavAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get dashboardNavAgent;

  /// No description provided for @dashboardNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get dashboardNavProfile;

  /// No description provided for @dashboardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get dashboardRecentActivity;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardNoTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get dashboardNoTransactionsTitle;

  /// No description provided for @dashboardNoTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your money moves will appear here.'**
  String get dashboardNoTransactionsSubtitle;

  /// No description provided for @dashboardActivityLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load activity'**
  String get dashboardActivityLoadFailedTitle;

  /// No description provided for @dashboardUsdWallet.
  ///
  /// In en, this message translates to:
  /// **'USD Wallet'**
  String get dashboardUsdWallet;

  /// No description provided for @dashboardReservedHeld.
  ///
  /// In en, this message translates to:
  /// **'{reserved} held'**
  String dashboardReservedHeld(Object reserved);

  /// No description provided for @dashboardActionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dashboardActionAdd;

  /// No description provided for @dashboardActionSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get dashboardActionSend;

  /// No description provided for @dashboardActionWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get dashboardActionWithdraw;

  /// No description provided for @dashboardActionCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get dashboardActionCards;

  /// No description provided for @transactionsNoActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get transactionsNoActivityTitle;

  /// No description provided for @transactionsNoActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any moves yet.\nNew activity will appear here instantly.'**
  String get transactionsNoActivitySubtitle;

  /// No description provided for @transactionsAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get transactionsAllCaughtUp;

  /// No description provided for @transactionsSingle.
  ///
  /// In en, this message translates to:
  /// **'transaction'**
  String get transactionsSingle;

  /// No description provided for @transactionsPlural.
  ///
  /// In en, this message translates to:
  /// **'transactions'**
  String get transactionsPlural;

  /// No description provided for @transactionsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} {unit}'**
  String transactionsCountLabel(Object count, Object unit);

  /// No description provided for @transactionsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every move on your account, in one place.'**
  String get transactionsHeaderSubtitle;

  /// No description provided for @transactionsHeaderTimeline.
  ///
  /// In en, this message translates to:
  /// **'{countLabel} · all on one timeline'**
  String transactionsHeaderTimeline(Object countLabel);

  /// No description provided for @transactionsMoneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get transactionsMoneyIn;

  /// No description provided for @transactionsMoneyOut.
  ///
  /// In en, this message translates to:
  /// **'Money out'**
  String get transactionsMoneyOut;

  /// No description provided for @depositAddMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get depositAddMoneyTitle;

  /// No description provided for @depositAddMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to add funds'**
  String get depositAddMoneySubtitle;

  /// No description provided for @depositExpressP2PTitle.
  ///
  /// In en, this message translates to:
  /// **'Express P2P'**
  String get depositExpressP2PTitle;

  /// No description provided for @depositExpressP2PSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay local currency, get USD fast'**
  String get depositExpressP2PSubtitle;

  /// No description provided for @depositP2PExchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'P2P Exchange'**
  String get depositP2PExchangeTitle;

  /// No description provided for @depositP2PExchangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer, Mobile Payments and more'**
  String get depositP2PExchangeSubtitle;

  /// No description provided for @depositStablecoinTitle.
  ///
  /// In en, this message translates to:
  /// **'USD Stablecoin'**
  String get depositStablecoinTitle;

  /// No description provided for @depositStablecoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive USDT or USDC to your Opei wallet'**
  String get depositStablecoinSubtitle;

  /// No description provided for @depositSelectMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get depositSelectMethodTitle;

  /// No description provided for @depositChooseMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the method you want to deposit with'**
  String get depositChooseMethodSubtitle;

  /// No description provided for @depositSelectNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Network'**
  String get depositSelectNetworkTitle;

  /// No description provided for @depositChooseNetworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the network for your {currency} deposit'**
  String depositChooseNetworkSubtitle(Object currency);

  /// No description provided for @depositFetchAddressFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch deposit address'**
  String get depositFetchAddressFailed;

  /// No description provided for @depositAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit Address'**
  String get depositAddressTitle;

  /// No description provided for @depositScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to deposit'**
  String get depositScanTitle;

  /// No description provided for @depositSendOnNetwork.
  ///
  /// In en, this message translates to:
  /// **'Send {currency} on {network}'**
  String depositSendOnNetwork(Object currency, Object network);

  /// No description provided for @depositQrUnavailable.
  ///
  /// In en, this message translates to:
  /// **'QR unavailable'**
  String get depositQrUnavailable;

  /// No description provided for @depositAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get depositAddressCopied;

  /// No description provided for @depositCopyCta.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get depositCopyCta;

  /// No description provided for @depositImportantTitle.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get depositImportantTitle;

  /// No description provided for @depositInfoOnlySend.
  ///
  /// In en, this message translates to:
  /// **'Only send {currency} on {network} network'**
  String depositInfoOnlySend(Object currency, Object network);

  /// No description provided for @depositInfoWrongAssetWarning.
  ///
  /// In en, this message translates to:
  /// **'Other assets or networks will cause permanent loss'**
  String get depositInfoWrongAssetWarning;

  /// No description provided for @depositInfoBalanceUpdates.
  ///
  /// In en, this message translates to:
  /// **'Balance updates after network confirmations'**
  String get depositInfoBalanceUpdates;

  /// No description provided for @sendMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Money'**
  String get sendMoneyTitle;

  /// No description provided for @sendMoneyRecipientEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient email'**
  String get sendMoneyRecipientEmailLabel;

  /// No description provided for @sendMoneyEnterEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get sendMoneyEnterEmailError;

  /// No description provided for @sendMoneyValidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get sendMoneyValidEmailError;

  /// No description provided for @sendMoneySendingToLabel.
  ///
  /// In en, this message translates to:
  /// **'Sending to'**
  String get sendMoneySendingToLabel;

  /// No description provided for @sendMoneyEnterAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get sendMoneyEnterAmountError;

  /// No description provided for @sendMoneyValidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get sendMoneyValidAmountError;

  /// No description provided for @sendMoneyNoPreview.
  ///
  /// In en, this message translates to:
  /// **'No preview available'**
  String get sendMoneyNoPreview;

  /// No description provided for @sendMoneyRecipientSection.
  ///
  /// In en, this message translates to:
  /// **'RECIPIENT'**
  String get sendMoneyRecipientSection;

  /// No description provided for @sendMoneyTransferAmountRow.
  ///
  /// In en, this message translates to:
  /// **'Transfer amount'**
  String get sendMoneyTransferAmountRow;

  /// No description provided for @sendMoneyTotalToChargeRow.
  ///
  /// In en, this message translates to:
  /// **'Total to charge'**
  String get sendMoneyTotalToChargeRow;

  /// No description provided for @sendMoneySendNowCta.
  ///
  /// In en, this message translates to:
  /// **'Send now'**
  String get sendMoneySendNowCta;

  /// No description provided for @sendMoneyTransferCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer complete'**
  String get sendMoneyTransferCompleteTitle;

  /// No description provided for @sendMoneyTransferCompleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You sent {amount} to {recipientName}'**
  String sendMoneyTransferCompleteSubtitle(Object amount, Object recipientName);

  /// No description provided for @sendMoneyAmountSentRow.
  ///
  /// In en, this message translates to:
  /// **'Amount sent'**
  String get sendMoneyAmountSentRow;

  /// No description provided for @sendMoneyNewBalanceRow.
  ///
  /// In en, this message translates to:
  /// **'Your new balance'**
  String get sendMoneyNewBalanceRow;

  /// No description provided for @sendMoneyTransferFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed'**
  String get sendMoneyTransferFailedTitle;

  /// No description provided for @sendMoneyTransferFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The transfer could not be completed. Please try again.'**
  String get sendMoneyTransferFailedSubtitle;

  /// No description provided for @onboardingCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel setup?'**
  String get onboardingCancelTitle;

  /// No description provided for @onboardingCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out and returned to home. You can continue onboarding after logging in again.'**
  String get onboardingCancelMessage;

  /// No description provided for @onboardingKeepGoingCta.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get onboardingKeepGoingCta;

  /// No description provided for @onboardingCancelSetupCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel setup'**
  String get onboardingCancelSetupCta;

  /// No description provided for @referralEnterValidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid referral code'**
  String get referralEnterValidCodeError;

  /// No description provided for @referralTooLateVerifiedError.
  ///
  /// In en, this message translates to:
  /// **'Too late - already verified'**
  String get referralTooLateVerifiedError;

  /// No description provided for @referralAppliedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Referral applied successfully.'**
  String get referralAppliedSuccess;

  /// No description provided for @referralTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later'**
  String get referralTryAgainLater;

  /// No description provided for @referralInvalidCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid code - check and try again'**
  String get referralInvalidCodeError;

  /// No description provided for @referralSelfCodeError.
  ///
  /// In en, this message translates to:
  /// **'You can\'t use your own code'**
  String get referralSelfCodeError;

  /// No description provided for @referralAlreadyHasReferrerError.
  ///
  /// In en, this message translates to:
  /// **'You already have a referrer'**
  String get referralAlreadyHasReferrerError;

  /// No description provided for @referralApplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply referral'**
  String get referralApplyTitle;

  /// No description provided for @referralGotCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Got a referral code?'**
  String get referralGotCodeTitle;

  /// No description provided for @referralOptionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional step. You can only apply a referral before verification.'**
  String get referralOptionalSubtitle;

  /// No description provided for @referralApplyCta.
  ///
  /// In en, this message translates to:
  /// **'Apply referral'**
  String get referralApplyCta;

  /// No description provided for @referralSkipForNowCta.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get referralSkipForNowCta;

  /// No description provided for @referralLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not load referral details. Try again.'**
  String get referralLoadFailedMessage;

  /// No description provided for @referralCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get referralCodeCopied;

  /// No description provided for @referralShareCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your code with friends. They enter it during signup.'**
  String get referralShareCodeSubtitle;

  /// No description provided for @referralStatsLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR STATS'**
  String get referralStatsLabel;

  /// No description provided for @referralInvitedLabel.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get referralInvitedLabel;

  /// No description provided for @referralSuccessfulLabel.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get referralSuccessfulLabel;

  /// No description provided for @referralTotalEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get referralTotalEarnedLabel;

  /// No description provided for @referralHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referralHeaderTitle;

  /// No description provided for @referralHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite friends and earn rewards.'**
  String get referralHeaderSubtitle;

  /// No description provided for @referralYourCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR CODE'**
  String get referralYourCodeLabel;

  /// No description provided for @referralCopiedCta.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get referralCopiedCta;

  /// No description provided for @referralCouldNotLoadTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load referral details'**
  String get referralCouldNotLoadTitle;

  /// No description provided for @addressWhereDoYouLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get addressWhereDoYouLiveTitle;

  /// No description provided for @addressWhereDoYouLiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required to verify your account. Stays completely private.'**
  String get addressWhereDoYouLiveSubtitle;

  /// No description provided for @addressLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Address line'**
  String get addressLineLabel;

  /// No description provided for @addressStreetHintExample.
  ///
  /// In en, this message translates to:
  /// **'123 Main Street'**
  String get addressStreetHintExample;

  /// No description provided for @addressAptSuiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Apt / Suite'**
  String get addressAptSuiteLabel;

  /// No description provided for @addressAptHintExample.
  ///
  /// In en, this message translates to:
  /// **'Apt 4B'**
  String get addressAptHintExample;

  /// No description provided for @addressZipCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'ZIP code'**
  String get addressZipCodeLabel;

  /// No description provided for @addressCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get addressCityLabel;

  /// No description provided for @addressCityHintExample.
  ///
  /// In en, this message translates to:
  /// **'New York'**
  String get addressCityHintExample;

  /// No description provided for @addressStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get addressStateLabel;

  /// No description provided for @addressStateHintExample.
  ///
  /// In en, this message translates to:
  /// **'NY'**
  String get addressStateHintExample;

  /// No description provided for @addressBvnLabel.
  ///
  /// In en, this message translates to:
  /// **'BVN'**
  String get addressBvnLabel;

  /// No description provided for @addressBvnHintExample.
  ///
  /// In en, this message translates to:
  /// **'11-digit Bank Verification Number'**
  String get addressBvnHintExample;

  /// No description provided for @mobileMoneyReceiversTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money receivers'**
  String get mobileMoneyReceiversTitle;

  /// No description provided for @mobileMoneyAddNewReceiverCta.
  ///
  /// In en, this message translates to:
  /// **'Add new receiver'**
  String get mobileMoneyAddNewReceiverCta;

  /// No description provided for @mobileMoneyUnnamedReceiver.
  ///
  /// In en, this message translates to:
  /// **'Unnamed receiver'**
  String get mobileMoneyUnnamedReceiver;

  /// No description provided for @mobileMoneyNoReceiversTitle.
  ///
  /// In en, this message translates to:
  /// **'No receivers yet'**
  String get mobileMoneyNoReceiversTitle;

  /// No description provided for @mobileMoneyNoReceiversSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first receiver to start sending mobile money.'**
  String get mobileMoneyNoReceiversSubtitle;

  /// No description provided for @mobileMoneyLoadReceiversFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load receivers'**
  String get mobileMoneyLoadReceiversFailed;

  /// No description provided for @mobileMoneyChooseNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Please choose a network.'**
  String get mobileMoneyChooseNetworkError;

  /// No description provided for @mobileMoneyReceiverAdded.
  ///
  /// In en, this message translates to:
  /// **'Receiver added.'**
  String get mobileMoneyReceiverAdded;

  /// No description provided for @mobileMoneyNewReceiverTitle.
  ///
  /// In en, this message translates to:
  /// **'New receiver'**
  String get mobileMoneyNewReceiverTitle;

  /// No description provided for @mobileMoneyLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoneyLabel;

  /// No description provided for @mobileMoneyReceiverNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Receiver name'**
  String get mobileMoneyReceiverNameLabel;

  /// No description provided for @mobileMoneyReceiverFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get mobileMoneyReceiverFullNameHint;

  /// No description provided for @mobileMoneyReceiverFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the receiver\'s full name.'**
  String get mobileMoneyReceiverFullNameRequired;

  /// No description provided for @mobileMoneyReceiverFirstLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Include first and last name.'**
  String get mobileMoneyReceiverFirstLastNameRequired;

  /// No description provided for @mobileMoneyDigitsHint.
  ///
  /// In en, this message translates to:
  /// **'{digits} digits'**
  String mobileMoneyDigitsHint(Object digits);

  /// No description provided for @mobileMoneyPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the phone number.'**
  String get mobileMoneyPhoneRequired;

  /// No description provided for @mobileMoneyPhoneExactDigitsForCountry.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be exactly {digits} digits for {countryName}.'**
  String mobileMoneyPhoneExactDigitsForCountry(
    Object digits,
    Object countryName,
  );

  /// No description provided for @mobileMoneyPhoneLeadingZeroError.
  ///
  /// In en, this message translates to:
  /// **'Don\'t include the leading 0 — the country code is added for you.'**
  String get mobileMoneyPhoneLeadingZeroError;

  /// No description provided for @mobileMoneyLocalNumberHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the local number without the leading 0. We\'ll send it as {dialCode}.'**
  String mobileMoneyLocalNumberHelper(Object dialCode);

  /// No description provided for @mobileMoneySaveReceiverCta.
  ///
  /// In en, this message translates to:
  /// **'Save receiver'**
  String get mobileMoneySaveReceiverCta;

  /// No description provided for @requiredLabel.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get requiredLabel;

  /// No description provided for @okLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okLabel;

  /// No description provided for @mobileMoneyNoNetworksForCountry.
  ///
  /// In en, this message translates to:
  /// **'No networks available for this country.'**
  String get mobileMoneyNoNetworksForCountry;

  /// No description provided for @usBankAchIndividualsOnlyError.
  ///
  /// In en, this message translates to:
  /// **'ACH transfers are only available for individuals. Switch to Wire for businesses.'**
  String get usBankAchIndividualsOnlyError;

  /// No description provided for @usBankReceiverAdded.
  ///
  /// In en, this message translates to:
  /// **'Receiver added.'**
  String get usBankReceiverAdded;

  /// No description provided for @usBankNewReceiverTitle.
  ///
  /// In en, this message translates to:
  /// **'New receiver'**
  String get usBankNewReceiverTitle;

  /// No description provided for @usBankHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'United States · Bank Transfer'**
  String get usBankHeaderSubtitle;

  /// No description provided for @usBankWireOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Wire'**
  String get usBankWireOptionLabel;

  /// No description provided for @usBankIndividualOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get usBankIndividualOptionLabel;

  /// No description provided for @usBankBusinessOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get usBankBusinessOptionLabel;

  /// No description provided for @usBankAchIndividualsOnlyInfo.
  ///
  /// In en, this message translates to:
  /// **'ACH is only available for individuals. Switch to Wire to send to a business.'**
  String get usBankAchIndividualsOnlyInfo;

  /// No description provided for @usBankCheckingOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get usBankCheckingOptionLabel;

  /// No description provided for @usBankSavingsOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get usBankSavingsOptionLabel;

  /// No description provided for @usBankAccountDigitsHelper.
  ///
  /// In en, this message translates to:
  /// **'4 – 17 digits'**
  String get usBankAccountDigitsHelper;

  /// No description provided for @usBankAccountDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Must be 4 – 17 digits.'**
  String get usBankAccountDigitsError;

  /// No description provided for @usBankRoutingDigitsHelper.
  ///
  /// In en, this message translates to:
  /// **'Exactly 9 digits'**
  String get usBankRoutingDigitsHelper;

  /// No description provided for @usBankRoutingHint.
  ///
  /// In en, this message translates to:
  /// **'9 digits'**
  String get usBankRoutingHint;

  /// No description provided for @usBankRoutingDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Must be exactly 9 digits.'**
  String get usBankRoutingDigitsError;

  /// No description provided for @usBankBankNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chase Bank'**
  String get usBankBankNameHint;

  /// No description provided for @usBankBankNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the bank name.'**
  String get usBankBankNameRequired;

  /// No description provided for @usBankBankAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 270 Park Avenue'**
  String get usBankBankAddressHint;

  /// No description provided for @usBankBankAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the bank address.'**
  String get usBankBankAddressRequired;

  /// No description provided for @fieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Required.'**
  String get fieldRequiredError;

  /// No description provided for @usBankBusinessNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Saul Atta LLC'**
  String get usBankBusinessNameHint;

  /// No description provided for @usBankFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get usBankFullNameHint;

  /// No description provided for @usBankBeneficiaryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the beneficiary name.'**
  String get usBankBeneficiaryNameRequired;

  /// No description provided for @usBankBeneficiaryAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 123 Tech Avenue, Suite 400'**
  String get usBankBeneficiaryAddressHint;

  /// No description provided for @usBankAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an address.'**
  String get usBankAddressRequired;

  /// No description provided for @usBankBeneficiaryCityHint.
  ///
  /// In en, this message translates to:
  /// **'Austin'**
  String get usBankBeneficiaryCityHint;

  /// No description provided for @usBankBeneficiaryStateHint.
  ///
  /// In en, this message translates to:
  /// **'Texas'**
  String get usBankBeneficiaryStateHint;

  /// No description provided for @cardsLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your cards. Please try again.'**
  String get cardsLoadFailedMessage;

  /// No description provided for @cardsNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this card.'**
  String get cardsNotFoundError;

  /// No description provided for @cardsTerminateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Terminate this card?'**
  String get cardsTerminateConfirmTitle;

  /// No description provided for @cardsTerminateConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This card will be permanently removed. You won’t be able to use or view {cardLabel} again.'**
  String cardsTerminateConfirmSubtitle(Object cardLabel);

  /// No description provided for @cardsTerminateMoveFundsWarning.
  ///
  /// In en, this message translates to:
  /// **'Make sure you’ve moved any remaining funds before confirming.'**
  String get cardsTerminateMoveFundsWarning;

  /// No description provided for @genericIssueTitle.
  ///
  /// In en, this message translates to:
  /// **'We ran into an issue'**
  String get genericIssueTitle;

  /// No description provided for @loadingSecurelyLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading securely...'**
  String get loadingSecurelyLabel;

  /// No description provided for @cardsCopySampleAddressCta.
  ///
  /// In en, this message translates to:
  /// **'Copy sample address'**
  String get cardsCopySampleAddressCta;

  /// No description provided for @cardsCopyAddressCta.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get cardsCopyAddressCta;

  /// No description provided for @cardsAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Address'**
  String get cardsAddressTitle;

  /// No description provided for @cardsSampleAddressHelper.
  ///
  /// In en, this message translates to:
  /// **'Sample data shown for layout. Real card addresses will appear here once provided by the gateway.'**
  String get cardsSampleAddressHelper;

  /// No description provided for @cardsEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Opei Visa Card'**
  String get cardsEmptyStateTitle;

  /// No description provided for @cardsEmptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay anywhere Visa is accepted —\nsubscriptions, travel, and shopping.'**
  String get cardsEmptyStateSubtitle;

  /// No description provided for @cardsCreateCardCta.
  ///
  /// In en, this message translates to:
  /// **'Create card'**
  String get cardsCreateCardCta;

  /// No description provided for @cardsHolderLabel.
  ///
  /// In en, this message translates to:
  /// **'Card holder'**
  String get cardsHolderLabel;

  /// No description provided for @cardsYourNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get cardsYourNamePlaceholder;

  /// No description provided for @addressBvnHelper.
  ///
  /// In en, this message translates to:
  /// **'Required for Nigerian residents.'**
  String get addressBvnHelper;

  /// No description provided for @addressHomeAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Home address'**
  String get addressHomeAddressTitle;

  /// No description provided for @addressOnboardingStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 4  •  Your residential details.'**
  String get addressOnboardingStepSubtitle;

  /// No description provided for @addressUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your residential details.'**
  String get addressUpdateSubtitle;

  /// No description provided for @addressSelectCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get addressSelectCountryHint;

  /// No description provided for @addressSelectCountryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get addressSelectCountryTitle;

  /// No description provided for @addressSearchCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get addressSearchCountryHint;

  /// No description provided for @addressUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get addressUpdatedTitle;

  /// No description provided for @addressUpdatedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your residential details have been saved.'**
  String get addressUpdatedSubtitle;

  /// No description provided for @kycIdentityVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get kycIdentityVerificationTitle;

  /// No description provided for @kycCheckingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking your verification status...'**
  String get kycCheckingStatus;

  /// No description provided for @kycApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC approved'**
  String get kycApprovedTitle;

  /// No description provided for @kycApprovedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re fully verified. Continue to your dashboard.'**
  String get kycApprovedSubtitle;

  /// No description provided for @kycUnderReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get kycUnderReviewTitle;

  /// No description provided for @kycUnderReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you within 24 hours once the review finishes.'**
  String get kycUnderReviewSubtitle;

  /// No description provided for @kycDeclinedTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC declined'**
  String get kycDeclinedTitle;

  /// No description provided for @kycDeclinedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email for the reason and next steps, or contact support if you need help.'**
  String get kycDeclinedSubtitle;

  /// No description provided for @kycRetryVerificationCta.
  ///
  /// In en, this message translates to:
  /// **'Retry verification'**
  String get kycRetryVerificationCta;

  /// No description provided for @kycUnableFetchStatus.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch your status. Please try again.'**
  String get kycUnableFetchStatus;

  /// No description provided for @kycVerifyIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your\nidentity'**
  String get kycVerifyIdentityTitle;

  /// No description provided for @kycVerifyIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'One last step — a quick ID check and selfie. Takes about 2 minutes.'**
  String get kycVerifyIdentitySubtitle;

  /// No description provided for @kycChecklistGovernmentIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Government-issued ID'**
  String get kycChecklistGovernmentIdTitle;

  /// No description provided for @kycChecklistGovernmentIdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Passport, driver\'s licence or national ID'**
  String get kycChecklistGovernmentIdSubtitle;

  /// No description provided for @kycChecklistSelfieTitle.
  ///
  /// In en, this message translates to:
  /// **'A quick selfie'**
  String get kycChecklistSelfieTitle;

  /// No description provided for @kycChecklistSelfieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Matched against your ID photo'**
  String get kycChecklistSelfieSubtitle;

  /// No description provided for @kycChecklistTwoMinutesTitle.
  ///
  /// In en, this message translates to:
  /// **'About 2 minutes'**
  String get kycChecklistTwoMinutesTitle;

  /// No description provided for @kycChecklistTwoMinutesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Most checks complete instantly'**
  String get kycChecklistTwoMinutesSubtitle;

  /// No description provided for @kycDataPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and never shared. We verify with a trusted partner.'**
  String get kycDataPrivacyNote;

  /// No description provided for @kycStartVerificationCta.
  ///
  /// In en, this message translates to:
  /// **'Start verification'**
  String get kycStartVerificationCta;

  /// No description provided for @kycPermissionInProgressError.
  ///
  /// In en, this message translates to:
  /// **'A permission request is already in progress. Please wait a moment and try again.'**
  String get kycPermissionInProgressError;

  /// No description provided for @kycPermissionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Camera and microphone access are required to continue.'**
  String get kycPermissionRequiredError;

  /// No description provided for @kycAllowAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get kycAllowAccessTitle;

  /// No description provided for @kycAllowAccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Camera, microphone and media permissions are needed to capture your verification selfie. Please enable them in Settings to continue.'**
  String get kycAllowAccessMessage;

  /// No description provided for @kycNotNowCta.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get kycNotNowCta;

  /// No description provided for @kycOpenSettingsCta.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get kycOpenSettingsCta;

  /// No description provided for @kycPreparingVerification.
  ///
  /// In en, this message translates to:
  /// **'Preparing verification…'**
  String get kycPreparingVerification;

  /// No description provided for @kycCouldNotOpenVerificationTab.
  ///
  /// In en, this message translates to:
  /// **'Could not open verification tab. Copying link…'**
  String get kycCouldNotOpenVerificationTab;

  /// No description provided for @kycAlreadyVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Already verified'**
  String get kycAlreadyVerifiedTitle;

  /// No description provided for @kycGoToDashboardCta.
  ///
  /// In en, this message translates to:
  /// **'Go to dashboard'**
  String get kycGoToDashboardCta;

  /// No description provided for @kycAddressRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Address required'**
  String get kycAddressRequiredTitle;

  /// No description provided for @kycCompleteAddressCta.
  ///
  /// In en, this message translates to:
  /// **'Complete address'**
  String get kycCompleteAddressCta;

  /// No description provided for @kycAccountInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Account inactive'**
  String get kycAccountInactiveTitle;

  /// No description provided for @kycSignInAgainTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get kycSignInAgainTitle;

  /// No description provided for @kycGoToSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get kycGoToSignInCta;

  /// No description provided for @kycSomethingWentWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get kycSomethingWentWrongTitle;

  /// No description provided for @kycAllSetTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set!'**
  String get kycAllSetTitle;

  /// No description provided for @kycAllSetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified. Welcome to Opei.'**
  String get kycAllSetSubtitle;

  /// No description provided for @kycContinueToDashboardCta.
  ///
  /// In en, this message translates to:
  /// **'Continue to dashboard'**
  String get kycContinueToDashboardCta;

  /// No description provided for @callCta.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callCta;

  /// No description provided for @couldNotOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer.'**
  String get couldNotOpenDialer;

  /// No description provided for @buyerNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Buyer number copied'**
  String get buyerNumberCopied;

  /// No description provided for @addImageCta.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImageCta;

  /// No description provided for @copiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedLabel;

  /// No description provided for @cardsTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Card Transactions'**
  String get cardsTransactionsTitle;

  /// No description provided for @cardsVirtualReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your virtual card is ready!'**
  String get cardsVirtualReadyMessage;

  /// No description provided for @cardsVirtualCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Virtual Card'**
  String get cardsVirtualCardLabel;

  /// No description provided for @cardsKeepCardCta.
  ///
  /// In en, this message translates to:
  /// **'Keep card'**
  String get cardsKeepCardCta;

  /// No description provided for @cardsTerminateCta.
  ///
  /// In en, this message translates to:
  /// **'Terminate'**
  String get cardsTerminateCta;

  /// No description provided for @cardsCreateVirtualCardCta.
  ///
  /// In en, this message translates to:
  /// **'Create Virtual Card'**
  String get cardsCreateVirtualCardCta;

  /// No description provided for @cardsTopUpAction.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get cardsTopUpAction;

  /// No description provided for @cardsWithdrawAction.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get cardsWithdrawAction;

  /// No description provided for @cardsTransactionsAction.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get cardsTransactionsAction;

  /// No description provided for @cardsFreezeAction.
  ///
  /// In en, this message translates to:
  /// **'Freeze Card'**
  String get cardsFreezeAction;

  /// No description provided for @cardsUnfreezeAction.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze Card'**
  String get cardsUnfreezeAction;

  /// No description provided for @cardsValueCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String cardsValueCopied(Object label);

  /// No description provided for @editCta.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editCta;

  /// No description provided for @deactivateCta.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivateCta;

  /// No description provided for @backCta.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backCta;

  /// No description provided for @goBackCta.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBackCta;

  /// No description provided for @iUnderstandCta.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstandCta;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @providerLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get providerLabel;

  /// No description provided for @frenchLabel.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get frenchLabel;

  /// No description provided for @p2pTradeCancelledSnack.
  ///
  /// In en, this message translates to:
  /// **'Trade cancelled.'**
  String get p2pTradeCancelledSnack;

  /// No description provided for @p2pAdSubmittedReviewSnack.
  ///
  /// In en, this message translates to:
  /// **'Ad submitted for review.'**
  String get p2pAdSubmittedReviewSnack;

  /// No description provided for @p2pClearFiltersCta.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get p2pClearFiltersCta;

  /// No description provided for @p2pApplyFiltersCta.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get p2pApplyFiltersCta;

  /// No description provided for @p2pThanksForRatingSnack.
  ///
  /// In en, this message translates to:
  /// **'Thanks for rating!'**
  String get p2pThanksForRatingSnack;

  /// No description provided for @p2pDisputeSubmittedSnack.
  ///
  /// In en, this message translates to:
  /// **'Dispute submitted. Support has been notified.'**
  String get p2pDisputeSubmittedSnack;

  /// No description provided for @p2pImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get p2pImageUnavailable;

  /// No description provided for @p2pSubmitDisputeCta.
  ///
  /// In en, this message translates to:
  /// **'Submit dispute'**
  String get p2pSubmitDisputeCta;

  /// No description provided for @p2pCreateAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Create P2P Ad'**
  String get p2pCreateAdTitle;

  /// No description provided for @p2pChooseAdType.
  ///
  /// In en, this message translates to:
  /// **'Choose ad type'**
  String get p2pChooseAdType;

  /// No description provided for @p2pAddPaymentMethodCta.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get p2pAddPaymentMethodCta;

  /// No description provided for @p2pSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get p2pSelectCurrency;

  /// No description provided for @p2pPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred language'**
  String get p2pPreferredLanguage;

  /// No description provided for @p2pPreferredCurrency.
  ///
  /// In en, this message translates to:
  /// **'Preferred currency'**
  String get p2pPreferredCurrency;

  /// No description provided for @p2pChoosePayoutCurrencySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the currency you want to get paid in'**
  String get p2pChoosePayoutCurrencySubtitle;

  /// No description provided for @p2pPayoutCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Payout currency'**
  String get p2pPayoutCurrencyLabel;

  /// No description provided for @p2pSelectOrAddPaymentMethodsForCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select or add payment methods for {currency}'**
  String p2pSelectOrAddPaymentMethodsForCurrency(Object currency);

  /// No description provided for @p2pCreateBuyAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Create BUY ad'**
  String get p2pCreateBuyAdTitle;

  /// No description provided for @p2pCreateBuyAdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the amount, limits and price you’re willing to pay.'**
  String get p2pCreateBuyAdSubtitle;

  /// No description provided for @sendReceiverFallback.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get sendReceiverFallback;

  /// No description provided for @sendReceiverBadge.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get sendReceiverBadge;

  /// No description provided for @sendAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get sendAmountTitle;

  /// No description provided for @sendAmountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How much will they receive in {currencyCode}?'**
  String sendAmountSubtitle(Object currencyCode);

  /// No description provided for @sendAmountAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount in {currencyCode} above 0 to continue.'**
  String sendAmountAmountError(Object currencyCode);

  /// No description provided for @sendAmountDescriptionMinError.
  ///
  /// In en, this message translates to:
  /// **'Enter a clear description (at least 3 characters).'**
  String get sendAmountDescriptionMinError;

  /// No description provided for @sendAmountDescriptionMaxError.
  ///
  /// In en, this message translates to:
  /// **'Description is too long (max 120 characters).'**
  String get sendAmountDescriptionMaxError;

  /// No description provided for @sendAmountCostHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see the USD cost and exchange rate before confirming.'**
  String get sendAmountCostHint;

  /// No description provided for @sendDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get sendDescriptionLabel;

  /// No description provided for @sendDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'What is this payment for?'**
  String get sendDescriptionHint;

  /// No description provided for @sendPreviewQuoteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Quote unavailable. Please go back and try again.'**
  String get sendPreviewQuoteUnavailable;

  /// No description provided for @sendPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review transfer'**
  String get sendPreviewTitle;

  /// No description provided for @sendPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check the details before confirming.'**
  String get sendPreviewSubtitle;

  /// No description provided for @sendPreviewBalanceShortfall.
  ///
  /// In en, this message translates to:
  /// **'Your balance is \${shortfall} short. Top up to continue.'**
  String sendPreviewBalanceShortfall(Object shortfall);

  /// No description provided for @sendPreviewReservingFunds.
  ///
  /// In en, this message translates to:
  /// **'Reserving funds…'**
  String get sendPreviewReservingFunds;

  /// No description provided for @sendPreviewSendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Sending payment…'**
  String get sendPreviewSendingPayment;

  /// No description provided for @sendPreviewConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm & send'**
  String get sendPreviewConfirmCta;

  /// No description provided for @sendPreviewYouPayLabel.
  ///
  /// In en, this message translates to:
  /// **'YOU PAY'**
  String get sendPreviewYouPayLabel;

  /// No description provided for @sendPreviewTheyReceiveLabel.
  ///
  /// In en, this message translates to:
  /// **'THEY RECEIVE'**
  String get sendPreviewTheyReceiveLabel;

  /// No description provided for @sendPreviewRecipientBadge.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get sendPreviewRecipientBadge;

  /// No description provided for @sendPreviewSendAmountRow.
  ///
  /// In en, this message translates to:
  /// **'Send amount'**
  String get sendPreviewSendAmountRow;

  /// No description provided for @sendPreviewTransferFeeRow.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee'**
  String get sendPreviewTransferFeeRow;

  /// No description provided for @sendPreviewTotalChargedRow.
  ///
  /// In en, this message translates to:
  /// **'Total charged'**
  String get sendPreviewTotalChargedRow;

  /// No description provided for @sendPreviewWalletAfterRow.
  ///
  /// In en, this message translates to:
  /// **'Wallet after'**
  String get sendPreviewWalletAfterRow;

  /// No description provided for @sendPreviewNoteRow.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get sendPreviewNoteRow;

  /// No description provided for @sendPreviewQuoteExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Quote expires at {time}'**
  String sendPreviewQuoteExpiresAt(Object time);

  /// No description provided for @sendResultMoneySentTitle.
  ///
  /// In en, this message translates to:
  /// **'Money sent'**
  String get sendResultMoneySentTitle;

  /// No description provided for @sendResultMoneySentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your payment to {receiverName} has been delivered.'**
  String sendResultMoneySentSubtitle(Object receiverName);

  /// No description provided for @sendResultCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get sendResultCompletedStatus;

  /// No description provided for @sendResultPaymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get sendResultPaymentFailedTitle;

  /// No description provided for @sendResultPaymentFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The provider couldn\'t process this payment. No funds were taken.'**
  String get sendResultPaymentFailedSubtitle;

  /// No description provided for @sendResultFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get sendResultFailedStatus;

  /// No description provided for @sendResultSendingInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Sending in progress'**
  String get sendResultSendingInProgressTitle;

  /// No description provided for @sendResultSendingInProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your payment is on its way to {receiverName}. We\'ll notify you once it\'s confirmed.'**
  String sendResultSendingInProgressSubtitle(Object receiverName);

  /// No description provided for @sendResultProcessingStatus.
  ///
  /// In en, this message translates to:
  /// **'PROCESSING'**
  String get sendResultProcessingStatus;

  /// No description provided for @sendResultStatusUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Status unknown'**
  String get sendResultStatusUnknownTitle;

  /// No description provided for @sendResultStatusUnknownSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check Activity in a few moments to see the outcome.'**
  String get sendResultStatusUnknownSubtitle;

  /// No description provided for @sendResultUnknownStatus.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get sendResultUnknownStatus;

  /// No description provided for @sendResultReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'RECEIVED'**
  String get sendResultReceivedLabel;

  /// No description provided for @sendResultDateRow.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sendResultDateRow;

  /// No description provided for @quickAuthEnterPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get quickAuthEnterPinTitle;

  /// No description provided for @quickAuthNoPinTitle.
  ///
  /// In en, this message translates to:
  /// **'No PIN set up'**
  String get quickAuthNoPinTitle;

  /// No description provided for @quickAuthEnterPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your 6-digit PIN to sign in'**
  String get quickAuthEnterPinSubtitle;

  /// No description provided for @quickAuthNoPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up a PIN in your account settings'**
  String get quickAuthNoPinSubtitle;

  /// No description provided for @quickAuthVerifyingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get quickAuthVerifyingTitle;

  /// No description provided for @quickAuthVerifyingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One moment please'**
  String get quickAuthVerifyingSubtitle;

  /// No description provided for @quickAuthFaceIdBanner.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID for faster sign-in'**
  String get quickAuthFaceIdBanner;

  /// No description provided for @quickAuthFingerprintBanner.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint for faster sign-in'**
  String get quickAuthFingerprintBanner;

  /// No description provided for @quickAuthEnableCta.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get quickAuthEnableCta;

  /// No description provided for @quickAuthDismissTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get quickAuthDismissTooltip;

  /// No description provided for @quickAuthUsePasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Use password'**
  String get quickAuthUsePasswordCta;

  /// No description provided for @p2pBuyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get p2pBuyerLabel;

  /// No description provided for @p2pSellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get p2pSellerLabel;

  /// No description provided for @p2pSelectStarRatingError.
  ///
  /// In en, this message translates to:
  /// **'Please select a star rating.'**
  String get p2pSelectStarRatingError;

  /// No description provided for @p2pFailedSubmitRatingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit rating. Please try again.'**
  String get p2pFailedSubmitRatingError;

  /// No description provided for @p2pRateCounterpartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate {counterparty}'**
  String p2pRateCounterpartyTitle(Object counterparty);

  /// No description provided for @p2pHowWasExperienceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get p2pHowWasExperienceSubtitle;

  /// No description provided for @p2pWhatWentWellLabel.
  ///
  /// In en, this message translates to:
  /// **'What went well?'**
  String get p2pWhatWentWellLabel;

  /// No description provided for @p2pCommentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get p2pCommentsLabel;

  /// No description provided for @p2pShareExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get p2pShareExperienceHint;

  /// No description provided for @p2pSubmitRatingCta.
  ///
  /// In en, this message translates to:
  /// **'Submit rating'**
  String get p2pSubmitRatingCta;

  /// No description provided for @refreshCta.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshCta;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @accountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumberLabel;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountNameLabel;

  /// No description provided for @detailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsLabel;

  /// No description provided for @networkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get networkLabel;

  /// No description provided for @paymentMethodsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get paymentMethodsLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodLabel;

  /// No description provided for @exchangeRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get exchangeRateLabel;

  /// No description provided for @withdrawChooseMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a withdrawal method'**
  String get withdrawChooseMethodSubtitle;

  /// No description provided for @withdrawMobileMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get withdrawMobileMoneyTitle;

  /// No description provided for @withdrawMobileMoneySubtitle.
  ///
  /// In en, this message translates to:
  /// **'M-Pesa, Airtel Money and more'**
  String get withdrawMobileMoneySubtitle;

  /// No description provided for @withdrawBankTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get withdrawBankTransferTitle;

  /// No description provided for @withdrawBankTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send to bank account'**
  String get withdrawBankTransferSubtitle;

  /// No description provided for @withdrawP2PExchangeTitle.
  ///
  /// In en, this message translates to:
  /// **'P2P Exchange'**
  String get withdrawP2PExchangeTitle;

  /// No description provided for @withdrawP2PExchangeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sell to buyers and get paid directly'**
  String get withdrawP2PExchangeSubtitle;

  /// No description provided for @withdrawStablecoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send USDT or USDC to your crypto wallet'**
  String get withdrawStablecoinSubtitle;

  /// No description provided for @withdrawEnterAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get withdrawEnterAmountError;

  /// No description provided for @withdrawEnterDestinationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a destination address'**
  String get withdrawEnterDestinationError;

  /// No description provided for @withdrawEnterValidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than zero'**
  String get withdrawEnterValidAmountError;

  /// No description provided for @withdrawDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the details for your {currency} withdrawal on {network}.'**
  String withdrawDetailsSubtitle(Object currency, Object network);

  /// No description provided for @withdrawAmountHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount you want to send'**
  String get withdrawAmountHelper;

  /// No description provided for @withdrawAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get withdrawAmountPlaceholder;

  /// No description provided for @withdrawDestinationAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination address'**
  String get withdrawDestinationAddressLabel;

  /// No description provided for @withdrawDestinationAddressHelper.
  ///
  /// In en, this message translates to:
  /// **'Paste the wallet address that will receive the funds'**
  String get withdrawDestinationAddressHelper;

  /// No description provided for @withdrawDestinationAddressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Wallet address'**
  String get withdrawDestinationAddressPlaceholder;

  /// No description provided for @withdrawMemoOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo (optional)'**
  String get withdrawMemoOptionalLabel;

  /// No description provided for @withdrawMemoHelper.
  ///
  /// In en, this message translates to:
  /// **'Add a note for your own records'**
  String get withdrawMemoHelper;

  /// No description provided for @withdrawMemoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Memo or description'**
  String get withdrawMemoPlaceholder;

  /// No description provided for @withdrawInfoDoubleCheck.
  ///
  /// In en, this message translates to:
  /// **'Double-check the network and address before submitting.'**
  String get withdrawInfoDoubleCheck;

  /// No description provided for @withdrawInfoStatusUpdates.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you when the transfer status updates.'**
  String get withdrawInfoStatusUpdates;

  /// No description provided for @withdrawReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review withdrawal'**
  String get withdrawReviewTitle;

  /// No description provided for @withdrawReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm these details before we send your {currency}.'**
  String withdrawReviewSubtitle(Object currency);

  /// No description provided for @withdrawAssetLabel.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get withdrawAssetLabel;

  /// No description provided for @withdrawNetworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get withdrawNetworkLabel;

  /// No description provided for @withdrawDestinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get withdrawDestinationLabel;

  /// No description provided for @withdrawConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get withdrawConfirmCta;

  /// No description provided for @withdrawSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal submitted'**
  String get withdrawSubmittedTitle;

  /// No description provided for @withdrawSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal sent'**
  String get withdrawSentTitle;

  /// No description provided for @withdrawSentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We are processing your {asset} transfer on {network} network. You will receive an update as soon as confirmations land.'**
  String withdrawSentSubtitle(Object asset, Object network);

  /// No description provided for @withdrawRequestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get withdrawRequestedLabel;

  /// No description provided for @cardsCardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardsCardNumberLabel;

  /// No description provided for @cardsExpiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get cardsExpiresLabel;

  /// No description provided for @cardsExpiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get cardsExpiryDateLabel;

  /// No description provided for @cardsCvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cardsCvvLabel;

  /// No description provided for @copyLabelWithValue.
  ///
  /// In en, this message translates to:
  /// **'Copy {value}'**
  String copyLabelWithValue(Object value);

  /// No description provided for @cardsUseCaseSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get cardsUseCaseSubscriptionsTitle;

  /// No description provided for @cardsUseCaseSubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Netflix, Spotify, and more'**
  String get cardsUseCaseSubscriptionsSubtitle;

  /// No description provided for @cardsUseCaseOnlineShoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Online Shopping'**
  String get cardsUseCaseOnlineShoppingTitle;

  /// No description provided for @cardsUseCaseOnlineShoppingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase from any store'**
  String get cardsUseCaseOnlineShoppingSubtitle;

  /// No description provided for @cardsUseCaseTravelTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel & Tickets'**
  String get cardsUseCaseTravelTitle;

  /// No description provided for @cardsUseCaseTravelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Book flights and hotels'**
  String get cardsUseCaseTravelSubtitle;

  /// No description provided for @cardsUseCaseGamingTitle.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get cardsUseCaseGamingTitle;

  /// No description provided for @cardsUseCaseGamingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases and games'**
  String get cardsUseCaseGamingSubtitle;

  /// No description provided for @cardsUseCaseInternationalTitle.
  ///
  /// In en, this message translates to:
  /// **'International Store Payments'**
  String get cardsUseCaseInternationalTitle;

  /// No description provided for @cardsUseCaseInternationalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shop from anywhere'**
  String get cardsUseCaseInternationalSubtitle;

  /// No description provided for @cardsUseCaseSecureTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure Online Purchases'**
  String get cardsUseCaseSecureTitle;

  /// No description provided for @cardsUseCaseSecureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protected transactions'**
  String get cardsUseCaseSecureSubtitle;

  /// No description provided for @cardsSettingUpCardLoading.
  ///
  /// In en, this message translates to:
  /// **'Setting up your card...'**
  String get cardsSettingUpCardLoading;

  /// No description provided for @cardsReadyToCreate.
  ///
  /// In en, this message translates to:
  /// **'Your virtual card is ready to create.'**
  String get cardsReadyToCreate;

  /// No description provided for @cardsTopupToCreate.
  ///
  /// In en, this message translates to:
  /// **'Top up your wallet to continue card creation.'**
  String get cardsTopupToCreate;

  /// No description provided for @cardsPaymentSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT SUMMARY'**
  String get cardsPaymentSummaryLabel;

  /// No description provided for @cardsTopupRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'TOP UP REQUIRED'**
  String get cardsTopupRequiredLabel;

  /// No description provided for @cardsCreateMyCardCta.
  ///
  /// In en, this message translates to:
  /// **'Create my card'**
  String get cardsCreateMyCardCta;

  /// No description provided for @cardsAddFundsCta.
  ///
  /// In en, this message translates to:
  /// **'Add funds'**
  String get cardsAddFundsCta;

  /// No description provided for @cardsCreationFeeRow.
  ///
  /// In en, this message translates to:
  /// **'Creation fee'**
  String get cardsCreationFeeRow;

  /// No description provided for @cardsActivationFeeRow.
  ///
  /// In en, this message translates to:
  /// **'Activation fee'**
  String get cardsActivationFeeRow;

  /// No description provided for @cardsOnYourCardRow.
  ///
  /// In en, this message translates to:
  /// **'On your card'**
  String get cardsOnYourCardRow;

  /// No description provided for @cardsAmountNeededRow.
  ///
  /// In en, this message translates to:
  /// **'Amount needed'**
  String get cardsAmountNeededRow;

  /// No description provided for @cardsCreatingCardLoading.
  ///
  /// In en, this message translates to:
  /// **'Creating your card...'**
  String get cardsCreatingCardLoading;

  /// No description provided for @expressStatusFindingAgent.
  ///
  /// In en, this message translates to:
  /// **'Finding agent'**
  String get expressStatusFindingAgent;

  /// No description provided for @expressStatusPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get expressStatusPayNow;

  /// No description provided for @expressStatusVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying'**
  String get expressStatusVerifying;

  /// No description provided for @expressStatusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get expressStatusUnderReview;

  /// No description provided for @expressStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get expressStatusCompleted;

  /// No description provided for @expressStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expressStatusExpired;

  /// No description provided for @expressStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get expressStatusCancelled;

  /// No description provided for @expressStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get expressStatusProcessing;

  /// No description provided for @expressStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get expressStatusAvailable;

  /// No description provided for @expressStatusWaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting payment'**
  String get expressStatusWaitingPayment;

  /// No description provided for @expressStatusConfirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get expressStatusConfirmPayment;

  /// No description provided for @expressCustomerPaysRow.
  ///
  /// In en, this message translates to:
  /// **'Customer pays'**
  String get expressCustomerPaysRow;

  /// No description provided for @expressYouReleaseRow.
  ///
  /// In en, this message translates to:
  /// **'You release'**
  String get expressYouReleaseRow;

  /// No description provided for @expressYouReceiveRow.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get expressYouReceiveRow;

  /// No description provided for @expressYouPayRow.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get expressYouPayRow;

  /// No description provided for @agentContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent contact'**
  String get agentContactTitle;

  /// No description provided for @needToFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need to follow up?'**
  String get needToFollowUpTitle;

  /// No description provided for @disputeExplainIssueHint.
  ///
  /// In en, this message translates to:
  /// **'Explain the issue...'**
  String get disputeExplainIssueHint;

  /// No description provided for @addNoteOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addNoteOptionalHint;

  /// No description provided for @transactionsEarlierGroup.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get transactionsEarlierGroup;

  /// No description provided for @transactionsTodayGroup.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get transactionsTodayGroup;

  /// No description provided for @transactionsYesterdayGroup.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get transactionsYesterdayGroup;

  /// No description provided for @transactionsFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get transactionsFailedStatus;

  /// No description provided for @transactionsCancelledStatus.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get transactionsCancelledStatus;

  /// No description provided for @transactionsReversedStatus.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get transactionsReversedStatus;

  /// No description provided for @transactionsRefundedStatus.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get transactionsRefundedStatus;

  /// No description provided for @usBankTransferSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer setup'**
  String get usBankTransferSetupTitle;

  /// No description provided for @usBankTransferTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer type'**
  String get usBankTransferTypeLabel;

  /// No description provided for @usBankBeneficiaryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary type'**
  String get usBankBeneficiaryTypeLabel;

  /// No description provided for @usBankAccountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get usBankAccountTypeLabel;

  /// No description provided for @usBankAccountNumbersTitle.
  ///
  /// In en, this message translates to:
  /// **'Account numbers'**
  String get usBankAccountNumbersTitle;

  /// No description provided for @usBankRoutingNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Routing number'**
  String get usBankRoutingNumberLabel;

  /// No description provided for @usBankBankInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank information'**
  String get usBankBankInformationTitle;

  /// No description provided for @usBankBankNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank name'**
  String get usBankBankNameLabel;

  /// No description provided for @usBankBankAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank address'**
  String get usBankBankAddressLabel;

  /// No description provided for @usBankRemittancePurposeTitle.
  ///
  /// In en, this message translates to:
  /// **'Remittance purpose'**
  String get usBankRemittancePurposeTitle;

  /// No description provided for @usBankBeneficiaryDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary details'**
  String get usBankBeneficiaryDetailsTitle;

  /// No description provided for @usBankBusinessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get usBankBusinessNameLabel;

  /// No description provided for @usBankFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get usBankFullNameLabel;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Paste code or https://opei.app/r/CODE'**
  String get referralCodeHint;

  /// No description provided for @sendMoneyAmountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get sendMoneyAmountHint;

  /// No description provided for @allLabel.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLabel;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @tradesLabel.
  ///
  /// In en, this message translates to:
  /// **'Trades'**
  String get tradesLabel;

  /// No description provided for @sinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Since'**
  String get sinceLabel;

  /// No description provided for @rateLabel.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rateLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabel;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// No description provided for @additionalDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetailsLabel;

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingLabel;

  /// No description provided for @totalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmountLabel;

  /// No description provided for @minOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Min order'**
  String get minOrderLabel;

  /// No description provided for @maxOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Max order'**
  String get maxOrderLabel;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minLabel;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @memberSinceLabel.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSinceLabel;

  /// No description provided for @notAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailableLabel;

  /// No description provided for @verifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedLabel;

  /// No description provided for @addedLabel.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get addedLabel;

  /// No description provided for @addCta.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addCta;

  /// No description provided for @somethingWentWrongTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrongTitle;

  /// No description provided for @p2pBuyLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get p2pBuyLabel;

  /// No description provided for @p2pSellLabel.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get p2pSellLabel;

  /// No description provided for @p2pSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'P2P'**
  String get p2pSectionTitle;

  /// No description provided for @p2pCouldNotLoadAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your ads'**
  String get p2pCouldNotLoadAdsTitle;

  /// No description provided for @p2pCouldNotLoadOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your orders'**
  String get p2pCouldNotLoadOrdersTitle;

  /// No description provided for @p2pOrdersTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get p2pOrdersTabLabel;

  /// No description provided for @p2pMyAdsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'My Ads'**
  String get p2pMyAdsTabLabel;

  /// No description provided for @p2pAmountFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount filters'**
  String get p2pAmountFiltersTitle;

  /// No description provided for @p2pLoadingProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get p2pLoadingProfileLabel;

  /// No description provided for @p2pRefreshSessionCta.
  ///
  /// In en, this message translates to:
  /// **'Refresh session'**
  String get p2pRefreshSessionCta;

  /// No description provided for @p2pSetUpProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your P2P profile'**
  String get p2pSetUpProfileTitle;

  /// No description provided for @p2pSetUpProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let buyers and sellers know who they’re dealing with. A verified profile speeds up trust checks and trade approvals.'**
  String get p2pSetUpProfileSubtitle;

  /// No description provided for @p2pProfileHighlightNameBio.
  ///
  /// In en, this message translates to:
  /// **'Share a friendly name and short bio'**
  String get p2pProfileHighlightNameBio;

  /// No description provided for @p2pProfileHighlightLimits.
  ///
  /// In en, this message translates to:
  /// **'Unlock higher limits with verified details'**
  String get p2pProfileHighlightLimits;

  /// No description provided for @p2pCreateProfileCta.
  ///
  /// In en, this message translates to:
  /// **'Create profile'**
  String get p2pCreateProfileCta;

  /// No description provided for @p2pProfileDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile details'**
  String get p2pProfileDetailsTitle;

  /// No description provided for @p2pAccountToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account tools'**
  String get p2pAccountToolsTitle;

  /// No description provided for @p2pManageAcceptedAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage the accounts you accept for trades. Each method is tied to a single currency.'**
  String get p2pManageAcceptedAccountsSubtitle;

  /// No description provided for @p2pNoPaymentMethodsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No payment methods yet'**
  String get p2pNoPaymentMethodsYetTitle;

  /// No description provided for @p2pNoPaymentMethodsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first method to make it easier for buyers to pay you.'**
  String get p2pNoPaymentMethodsYetSubtitle;

  /// No description provided for @p2pNoOrdersInViewTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders in this view'**
  String get p2pNoOrdersInViewTitle;

  /// No description provided for @p2pNoOrdersInViewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Once you start trading, your activity will show here.'**
  String get p2pNoOrdersInViewSubtitle;

  /// No description provided for @p2pMinimumAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount'**
  String get p2pMinimumAmountLabel;

  /// No description provided for @p2pMaximumAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount'**
  String get p2pMaximumAmountLabel;

  /// No description provided for @p2pManagePayoutAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage payout accounts'**
  String get p2pManagePayoutAccountsSubtitle;

  /// No description provided for @p2pSearchCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Search currency'**
  String get p2pSearchCurrencyHint;

  /// No description provided for @p2pPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get p2pPaidLabel;

  /// No description provided for @p2pReleasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get p2pReleasedLabel;

  /// No description provided for @p2pCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get p2pCompletedLabel;

  /// No description provided for @p2pReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get p2pReasonLabel;

  /// No description provided for @p2pOrderIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get p2pOrderIdLabel;

  /// No description provided for @p2pShareShortNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Share a short note (<=500 chars)'**
  String get p2pShareShortNoteHint;

  /// No description provided for @p2pPrepareProofUploadsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t prepare proof uploads. Please try again.'**
  String get p2pPrepareProofUploadsError;

  /// No description provided for @p2pDisputeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Seller never released after I sent funds'**
  String get p2pDisputeReasonHint;

  /// No description provided for @p2pSellUsdTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell USD'**
  String get p2pSellUsdTitle;

  /// No description provided for @p2pSellUsdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive fiat or mobile money.'**
  String get p2pSellUsdSubtitle;

  /// No description provided for @p2pBuyUsdTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy USD'**
  String get p2pBuyUsdTitle;

  /// No description provided for @p2pBuyUsdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Specify how you will pay sellers.'**
  String get p2pBuyUsdSubtitle;

  /// No description provided for @p2pTotalAmountUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Total amount (USD)'**
  String get p2pTotalAmountUsdLabel;

  /// No description provided for @p2pPriceUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (USD)'**
  String get p2pPriceUsdLabel;

  /// No description provided for @p2pMinOrderUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Min order (USD)'**
  String get p2pMinOrderUsdLabel;

  /// No description provided for @p2pMaxOrderUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Max order (USD)'**
  String get p2pMaxOrderUsdLabel;

  /// No description provided for @p2pInstructionsOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions (optional)'**
  String get p2pInstructionsOptionalLabel;

  /// No description provided for @p2pInstructionsProofHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Proof of transfer required'**
  String get p2pInstructionsProofHint;

  /// No description provided for @p2pDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get p2pDisplayNameLabel;

  /// No description provided for @p2pDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Johnex'**
  String get p2pDisplayNameHint;

  /// No description provided for @p2pUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get p2pUsernameLabel;

  /// No description provided for @p2pUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'john_fx'**
  String get p2pUsernameHint;

  /// No description provided for @p2pBioLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get p2pBioLabel;

  /// No description provided for @p2pBioHint.
  ///
  /// In en, this message translates to:
  /// **'10 years trading USD/ZMW'**
  String get p2pBioHint;

  /// No description provided for @p2pPriceRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (rate)'**
  String get p2pPriceRateLabel;

  /// No description provided for @p2pInstructionsAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Available 08:00-21:00'**
  String get p2pInstructionsAvailableHint;

  /// No description provided for @p2pInstructionsNeedProofHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Need proof of transfer'**
  String get p2pInstructionsNeedProofHint;

  /// No description provided for @p2pNameOnAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Name on account'**
  String get p2pNameOnAccountHint;

  /// No description provided for @p2pAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get p2pAccountNumberHint;

  /// No description provided for @p2pExtraDetailsOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Extra details (optional)'**
  String get p2pExtraDetailsOptionalLabel;

  /// No description provided for @p2pBranchReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Branch, reference'**
  String get p2pBranchReferenceHint;

  /// No description provided for @p2pChooseHowYouPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you’ll pay'**
  String get p2pChooseHowYouPayTitle;

  /// No description provided for @p2pSelectSellerPaymentMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select one of the seller’s payment methods for {currency}.'**
  String p2pSelectSellerPaymentMethodSubtitle(Object currency);

  /// No description provided for @p2pSelectPayoutRailTitle.
  ///
  /// In en, this message translates to:
  /// **'Select payout rail'**
  String get p2pSelectPayoutRailTitle;

  /// No description provided for @p2pChooseBuyerPaymentMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the payment method the buyer should use for {currency}.'**
  String p2pChooseBuyerPaymentMethodSubtitle(Object currency);

  /// No description provided for @p2pMinimumOrderLabel.
  ///
  /// In en, this message translates to:
  /// **'Minimum order'**
  String get p2pMinimumOrderLabel;

  /// No description provided for @p2pBuyerPaysViaLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer pays via'**
  String get p2pBuyerPaysViaLabel;

  /// No description provided for @p2pPaymentCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment currency'**
  String get p2pPaymentCurrencyLabel;

  /// No description provided for @p2pDisputeOpenedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Dispute opened. Support will review it shortly.'**
  String get p2pDisputeOpenedSuccess;

  /// No description provided for @p2pBackToOrdersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to orders'**
  String get p2pBackToOrdersTooltip;

  /// No description provided for @p2pSellerReviewsProofLabel.
  ///
  /// In en, this message translates to:
  /// **'Seller reviews your payment proof.'**
  String get p2pSellerReviewsProofLabel;

  /// No description provided for @p2pUploadFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Upload failed with status {status}'**
  String p2pUploadFailedStatus(Object status);

  /// No description provided for @p2pFailedUploadProof.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload proof {index}. Please try again.'**
  String p2pFailedUploadProof(Object index);

  /// No description provided for @p2pSellerDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add any details the seller should know'**
  String get p2pSellerDetailsHint;

  /// No description provided for @cardsAfterCreationRow.
  ///
  /// In en, this message translates to:
  /// **'After creation'**
  String get cardsAfterCreationRow;

  /// No description provided for @cardsAddToContinueLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to continue'**
  String get cardsAddToContinueLabel;

  /// No description provided for @cardsOnItsWayTitle.
  ///
  /// In en, this message translates to:
  /// **'Card on its way!'**
  String get cardsOnItsWayTitle;

  /// No description provided for @cardsOnItsWayMessage.
  ///
  /// In en, this message translates to:
  /// **'Your virtual card is being set up.\nIt will be active in a moment.'**
  String get cardsOnItsWayMessage;

  /// No description provided for @cardsLoadDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load card details'**
  String get cardsLoadDetailsError;

  /// No description provided for @cardsTransactionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No card transactions yet'**
  String get cardsTransactionsEmptyTitle;

  /// No description provided for @cardsTransactionsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When you start using this card, your transaction history will appear here.'**
  String get cardsTransactionsEmptyMessage;

  /// No description provided for @cardsTransactionBalanceRow.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance}'**
  String cardsTransactionBalanceRow(Object balance);

  /// No description provided for @withdrawMobileMoneyCountriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money supported countries'**
  String get withdrawMobileMoneyCountriesSubtitle;

  /// No description provided for @withdrawChooseNetworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the network for your {currency} withdrawal'**
  String withdrawChooseNetworkSubtitle(Object currency);

  /// No description provided for @withdrawCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {currency}'**
  String withdrawCurrencyTitle(Object currency);

  /// No description provided for @withdrawCurrencyWithdrawalLabel.
  ///
  /// In en, this message translates to:
  /// **'{currency} withdrawal'**
  String withdrawCurrencyWithdrawalLabel(Object currency);

  /// No description provided for @expressP2PHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay local currency · get USD fast'**
  String get expressP2PHubSubtitle;

  /// No description provided for @expressStartNewDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Start new deposit'**
  String get expressStartNewDepositTitle;

  /// No description provided for @expressStartNewDepositSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose amount and payment method'**
  String get expressStartNewDepositSubtitle;

  /// No description provided for @expressNoDepositsTitle.
  ///
  /// In en, this message translates to:
  /// **'No deposits yet'**
  String get expressNoDepositsTitle;

  /// No description provided for @expressNoDepositsMessage.
  ///
  /// In en, this message translates to:
  /// **'Start a deposit to add USD to your wallet by paying a local agent.'**
  String get expressNoDepositsMessage;

  /// No description provided for @expressLoadDepositsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your deposits'**
  String get expressLoadDepositsError;

  /// No description provided for @expressPickSendMethodHint.
  ///
  /// In en, this message translates to:
  /// **'Pick how you will send {currency} to the agent.'**
  String expressPickSendMethodHint(Object currency);

  /// No description provided for @expressLoadingMethods.
  ///
  /// In en, this message translates to:
  /// **'Loading methods…'**
  String get expressLoadingMethods;

  /// No description provided for @expressNoMethodsForCurrency.
  ///
  /// In en, this message translates to:
  /// **'No payment methods available for this currency yet.'**
  String get expressNoMethodsForCurrency;

  /// No description provided for @expressAmountToReceiveLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT TO RECEIVE'**
  String get expressAmountToReceiveLabel;

  /// No description provided for @expressReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get expressReviewTitle;

  /// No description provided for @expressRateLocksHint.
  ///
  /// In en, this message translates to:
  /// **'Rate locks on confirm. An agent will be matched to collect your local payment.'**
  String get expressRateLocksHint;

  /// No description provided for @expressConfirmOrderCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get expressConfirmOrderCta;

  /// No description provided for @expressDepositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get expressDepositTitle;

  /// No description provided for @expressOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found.'**
  String get expressOrderNotFound;

  /// No description provided for @expressCancelOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get expressCancelOrderTitle;

  /// No description provided for @expressCancelOrderPaidRisk.
  ///
  /// In en, this message translates to:
  /// **'If you already sent money to the agent and cancel now, that payment may be lost and cannot be recovered in-app. Cancel only if you have NOT paid yet.'**
  String get expressCancelOrderPaidRisk;

  /// No description provided for @expressCancelOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'This will cancel the order and stop the current express deposit flow.'**
  String get expressCancelOrderMessage;

  /// No description provided for @expressKeepOrderCta.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get expressKeepOrderCta;

  /// No description provided for @expressYesCancelCta.
  ///
  /// In en, this message translates to:
  /// **'Yes, cancel'**
  String get expressYesCancelCta;

  /// No description provided for @expressOrderPlacedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get expressOrderPlacedTitle;

  /// No description provided for @expressOrderPlacedMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re looking for an agent for you now. Once matched, you\'ll be notified and can continue payment.'**
  String get expressOrderPlacedMessage;

  /// No description provided for @expressCancelOrderCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get expressCancelOrderCta;

  /// No description provided for @expressViewMyOrdersCta.
  ///
  /// In en, this message translates to:
  /// **'View my orders'**
  String get expressViewMyOrdersCta;

  /// No description provided for @expressPayYourAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay your agent'**
  String get expressPayYourAgentTitle;

  /// No description provided for @expressSendExactlyMessage.
  ///
  /// In en, this message translates to:
  /// **'Send exactly {amount} to the account below, then upload your proof.'**
  String expressSendExactlyMessage(Object amount);

  /// No description provided for @expressPayOutsideHint.
  ///
  /// In en, this message translates to:
  /// **'Pay outside the app, then upload a screenshot or receipt as proof of payment.'**
  String get expressPayOutsideHint;

  /// No description provided for @expressPaymentSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment submitted'**
  String get expressPaymentSubmittedTitle;

  /// No description provided for @expressPaymentSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your proof has been sent. Please wait while the agent confirms payment. Once approved, USD will be added to your wallet.'**
  String get expressPaymentSubmittedMessage;

  /// No description provided for @expressOpenDisputeCta.
  ///
  /// In en, this message translates to:
  /// **'Open dispute'**
  String get expressOpenDisputeCta;

  /// No description provided for @expressDisputeOpenedTitle.
  ///
  /// In en, this message translates to:
  /// **'Dispute opened'**
  String get expressDisputeOpenedTitle;

  /// No description provided for @expressDisputeUnderReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Under review by admin. We will notify you when this is resolved.'**
  String get expressDisputeUnderReviewMessage;

  /// No description provided for @expressAmountAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'{amount} added'**
  String expressAmountAddedTitle(Object amount);

  /// No description provided for @expressDepositCompleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Your deposit is complete and the funds are now in your Opei wallet.'**
  String get expressDepositCompleteMessage;

  /// No description provided for @expressDisputeSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened. You can add proof screenshots (optional).'**
  String get expressDisputeSheetSubtitle;

  /// No description provided for @expressUploadProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload payment proof'**
  String get expressUploadProofTitle;

  /// No description provided for @expressUploadProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a screenshot or receipt of your payment (up to 3 images).'**
  String get expressUploadProofSubtitle;

  /// No description provided for @expressSubmitPaymentCta.
  ///
  /// In en, this message translates to:
  /// **'Submit payment'**
  String get expressSubmitPaymentCta;

  /// No description provided for @expressAcceptOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept this order?'**
  String get expressAcceptOrderTitle;

  /// No description provided for @expressAcceptOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'{amount} will be reserved from your wallet for this order. Only accept when you are ready to complete this trade to avoid potential financial loss.'**
  String expressAcceptOrderMessage(Object amount);

  /// No description provided for @expressAcceptCta.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get expressAcceptCta;

  /// No description provided for @expressAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Express Agent'**
  String get expressAgentTitle;

  /// No description provided for @expressAgentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accept and complete deposits'**
  String get expressAgentSubtitle;

  /// No description provided for @expressAgentInactiveViewOnly.
  ///
  /// In en, this message translates to:
  /// **'Your agent account is inactive. You can view orders but cannot accept or confirm.'**
  String get expressAgentInactiveViewOnly;

  /// No description provided for @expressAcceptOrderCta.
  ///
  /// In en, this message translates to:
  /// **'Accept order'**
  String get expressAcceptOrderCta;

  /// No description provided for @expressConfirmReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment received?'**
  String get expressConfirmReceivedTitle;

  /// No description provided for @expressConfirmReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Only continue if the money is in your account. This will release USD to the buyer and cannot be undone. A wrong confirmation may cause financial loss.'**
  String get expressConfirmReceivedMessage;

  /// No description provided for @expressNotYetCta.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get expressNotYetCta;

  /// No description provided for @expressYesReleaseCta.
  ///
  /// In en, this message translates to:
  /// **'Yes, release'**
  String get expressYesReleaseCta;

  /// No description provided for @expressOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get expressOrderTitle;

  /// No description provided for @expressUnderReviewByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Under review by admin.'**
  String get expressUnderReviewByAdmin;

  /// No description provided for @expressPaymentProofLabel.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT PROOF'**
  String get expressPaymentProofLabel;

  /// No description provided for @expressAgentInactiveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Your agent account is inactive. You cannot confirm orders.'**
  String get expressAgentInactiveConfirm;

  /// No description provided for @expressConfirmReceivedCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment received'**
  String get expressConfirmReceivedCta;

  /// No description provided for @expressImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image {number}'**
  String expressImageLabel(Object number);

  /// No description provided for @expressCouldNotOpenImage.
  ///
  /// In en, this message translates to:
  /// **'Could not open this image.'**
  String get expressCouldNotOpenImage;

  /// No description provided for @expressBuyerContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer contact'**
  String get expressBuyerContactLabel;

  /// No description provided for @expressBuyerContactUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Buyer contact unavailable'**
  String get expressBuyerContactUnavailable;

  /// No description provided for @expressTabAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available ({count})'**
  String expressTabAvailable(Object count);

  /// No description provided for @expressTabQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue ({count})'**
  String expressTabQueue(Object count);

  /// No description provided for @expressTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get expressTabHistory;

  /// No description provided for @expressNoAvailableOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders available right now.'**
  String get expressNoAvailableOrders;

  /// No description provided for @expressNoQueueOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders in your queue.'**
  String get expressNoQueueOrders;

  /// No description provided for @expressNoCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'No completed orders yet.'**
  String get expressNoCompletedOrders;

  /// No description provided for @savedReceiversLabel.
  ///
  /// In en, this message translates to:
  /// **'SAVED RECEIVERS'**
  String get savedReceiversLabel;

  /// No description provided for @addNewReceiverTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new receiver'**
  String get addNewReceiverTitle;

  /// No description provided for @couldNotLoadReceivers.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load receivers'**
  String get couldNotLoadReceivers;

  /// No description provided for @mobileMoneyReceiversSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money · Receivers'**
  String get mobileMoneyReceiversSubtitle;

  /// No description provided for @mobileMoneyAddReceiverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a number to send money quickly'**
  String get mobileMoneyAddReceiverSubtitle;

  /// No description provided for @mobileMoneyNoReceiversHint.
  ///
  /// In en, this message translates to:
  /// **'Save a phone number above to send mobile\nmoney quickly next time.'**
  String get mobileMoneyNoReceiversHint;

  /// No description provided for @usBankReceiversSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer · Receivers'**
  String get usBankReceiversSubtitle;

  /// No description provided for @usBankAddReceiverSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a US bank account to send quickly'**
  String get usBankAddReceiverSubtitle;

  /// No description provided for @usBankNoReceiversTitle.
  ///
  /// In en, this message translates to:
  /// **'No receivers yet'**
  String get usBankNoReceiversTitle;

  /// No description provided for @usBankNoReceiversHint.
  ///
  /// In en, this message translates to:
  /// **'Save a US bank account above to send\ndollars to the US quickly next time.'**
  String get usBankNoReceiversHint;

  /// No description provided for @stepIndicator.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepIndicator(Object current, Object total);

  /// No description provided for @recipientGetsLabel.
  ///
  /// In en, this message translates to:
  /// **'RECIPIENT GETS'**
  String get recipientGetsLabel;

  /// No description provided for @bankTransferCountriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer supported countries'**
  String get bankTransferCountriesSubtitle;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get savingLabel;

  /// No description provided for @transactionNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get transactionNoteLabel;

  /// No description provided for @depositNetworksCount.
  ///
  /// In en, this message translates to:
  /// **'{name} • {count} networks'**
  String depositNetworksCount(Object name, Object count);

  /// No description provided for @remPurposeFamilySupport.
  ///
  /// In en, this message translates to:
  /// **'Family support'**
  String get remPurposeFamilySupport;

  /// No description provided for @remPurposeEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get remPurposeEducation;

  /// No description provided for @remPurposeGiftAndDonation.
  ///
  /// In en, this message translates to:
  /// **'Gift & donation'**
  String get remPurposeGiftAndDonation;

  /// No description provided for @remPurposeMedicalTreatment.
  ///
  /// In en, this message translates to:
  /// **'Medical treatment'**
  String get remPurposeMedicalTreatment;

  /// No description provided for @remPurposeMaintenanceExpenses.
  ///
  /// In en, this message translates to:
  /// **'Maintenance / living expenses'**
  String get remPurposeMaintenanceExpenses;

  /// No description provided for @remPurposeTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get remPurposeTravel;

  /// No description provided for @remPurposeSmallValueRemittance.
  ///
  /// In en, this message translates to:
  /// **'Small-value remittance'**
  String get remPurposeSmallValueRemittance;

  /// No description provided for @remPurposeLiberalizedRemittance.
  ///
  /// In en, this message translates to:
  /// **'Liberalized remittance'**
  String get remPurposeLiberalizedRemittance;

  /// No description provided for @remPurposePersonalTransfer.
  ///
  /// In en, this message translates to:
  /// **'Personal transfer'**
  String get remPurposePersonalTransfer;

  /// No description provided for @remPurposeSalaryPayment.
  ///
  /// In en, this message translates to:
  /// **'Salary payment'**
  String get remPurposeSalaryPayment;

  /// No description provided for @remPurposeLoanPayment.
  ///
  /// In en, this message translates to:
  /// **'Loan payment'**
  String get remPurposeLoanPayment;

  /// No description provided for @remPurposeTaxPayment.
  ///
  /// In en, this message translates to:
  /// **'Tax payment'**
  String get remPurposeTaxPayment;

  /// No description provided for @remPurposeUtilityBills.
  ///
  /// In en, this message translates to:
  /// **'Utility bills'**
  String get remPurposeUtilityBills;

  /// No description provided for @remPurposePropertyPurchase.
  ///
  /// In en, this message translates to:
  /// **'Property purchase'**
  String get remPurposePropertyPurchase;

  /// No description provided for @remPurposePropertyRental.
  ///
  /// In en, this message translates to:
  /// **'Property rental'**
  String get remPurposePropertyRental;

  /// No description provided for @remPurposeConstructionExpenses.
  ///
  /// In en, this message translates to:
  /// **'Construction expenses'**
  String get remPurposeConstructionExpenses;

  /// No description provided for @remPurposeHotelAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Hotel accommodation'**
  String get remPurposeHotelAccommodation;

  /// No description provided for @remPurposeTransportationFees.
  ///
  /// In en, this message translates to:
  /// **'Transportation fees'**
  String get remPurposeTransportationFees;

  /// No description provided for @remPurposeDeliveryFees.
  ///
  /// In en, this message translates to:
  /// **'Delivery fees'**
  String get remPurposeDeliveryFees;

  /// No description provided for @remPurposeOfficeExpenses.
  ///
  /// In en, this message translates to:
  /// **'Office expenses'**
  String get remPurposeOfficeExpenses;

  /// No description provided for @remPurposeAdvertisingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Advertising expenses'**
  String get remPurposeAdvertisingExpenses;

  /// No description provided for @remPurposeAdvisoryFees.
  ///
  /// In en, this message translates to:
  /// **'Advisory fees'**
  String get remPurposeAdvisoryFees;

  /// No description provided for @remPurposeServiceCharges.
  ///
  /// In en, this message translates to:
  /// **'Service charges'**
  String get remPurposeServiceCharges;

  /// No description provided for @remPurposeBusinessInsurance.
  ///
  /// In en, this message translates to:
  /// **'Business insurance'**
  String get remPurposeBusinessInsurance;

  /// No description provided for @remPurposeInsuranceClaims.
  ///
  /// In en, this message translates to:
  /// **'Insurance claims'**
  String get remPurposeInsuranceClaims;

  /// No description provided for @remPurposeExportedGoods.
  ///
  /// In en, this message translates to:
  /// **'Exported goods'**
  String get remPurposeExportedGoods;

  /// No description provided for @remPurposeSharesInvestment.
  ///
  /// In en, this message translates to:
  /// **'Shares investment'**
  String get remPurposeSharesInvestment;

  /// No description provided for @remPurposeFundInvestment.
  ///
  /// In en, this message translates to:
  /// **'Fund investment'**
  String get remPurposeFundInvestment;

  /// No description provided for @remPurposeRoyaltyFees.
  ///
  /// In en, this message translates to:
  /// **'Royalty fees'**
  String get remPurposeRoyaltyFees;

  /// No description provided for @remPurposeComputerServices.
  ///
  /// In en, this message translates to:
  /// **'Computer services'**
  String get remPurposeComputerServices;

  /// No description provided for @remPurposeRewardPayment.
  ///
  /// In en, this message translates to:
  /// **'Reward payment'**
  String get remPurposeRewardPayment;

  /// No description provided for @remPurposeInfluencerPayment.
  ///
  /// In en, this message translates to:
  /// **'Influencer payment'**
  String get remPurposeInfluencerPayment;

  /// No description provided for @remPurposeOtherFees.
  ///
  /// In en, this message translates to:
  /// **'Other fees'**
  String get remPurposeOtherFees;

  /// No description provided for @remPurposeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get remPurposeOther;

  /// No description provided for @errTimeoutConnection.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please check your connection and try again.'**
  String get errTimeoutConnection;

  /// No description provided for @errUnableToConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Please check your internet connection.'**
  String get errUnableToConnect;

  /// No description provided for @errSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errSessionExpired;

  /// No description provided for @errNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get errNoPermission;

  /// No description provided for @errLookupAccountNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not find an account with that email address.'**
  String get errLookupAccountNotFound;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errInvalidEmail;

  /// No description provided for @errEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address to continue.'**
  String get errEnterEmail;

  /// No description provided for @errServerSideShortly.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Please try again shortly.'**
  String get errServerSideShortly;

  /// No description provided for @errLookupRecipientFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to find recipient. Please check the email and try again.'**
  String get errLookupRecipientFailed;

  /// No description provided for @errSameWallet.
  ///
  /// In en, this message translates to:
  /// **'You can\'t send money to your own wallet.'**
  String get errSameWallet;

  /// No description provided for @errAmountAboveZero.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0.00 to continue.'**
  String get errAmountAboveZero;

  /// No description provided for @errBalanceTooLow.
  ///
  /// In en, this message translates to:
  /// **'Your balance is too low for this transfer.'**
  String get errBalanceTooLow;

  /// No description provided for @errFeeExceedsAmount.
  ///
  /// In en, this message translates to:
  /// **'The fee is more than the amount you\'re sending.'**
  String get errFeeExceedsAmount;

  /// No description provided for @errSenderWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find your wallet. Please refresh and try again.'**
  String get errSenderWalletNotFound;

  /// No description provided for @errRecipientWalletNotFound.
  ///
  /// In en, this message translates to:
  /// **'This user\'s wallet couldn\'t be found. Please check the email and try again.'**
  String get errRecipientWalletNotFound;

  /// No description provided for @errEnterValidInfo.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid information to continue.'**
  String get errEnterValidInfo;

  /// No description provided for @errPreviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to calculate transfer details. Please try again.'**
  String get errPreviewFailed;

  /// No description provided for @errAmountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'The amount must be greater than zero.'**
  String get errAmountGreaterThanZero;

  /// No description provided for @errCheckDetails.
  ///
  /// In en, this message translates to:
  /// **'Please check your details and try again.'**
  String get errCheckDetails;

  /// No description provided for @errRecipientNoWallet.
  ///
  /// In en, this message translates to:
  /// **'This user doesn\'t seem to have a wallet on Opei.'**
  String get errRecipientNoWallet;

  /// No description provided for @errTransferAlreadyProcessed.
  ///
  /// In en, this message translates to:
  /// **'This transfer has already been processed.'**
  String get errTransferAlreadyProcessed;

  /// No description provided for @errTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete the transfer. Please try again.'**
  String get errTransferFailed;

  /// No description provided for @errInvalidRequestCheckDetails.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your details and try again.'**
  String get errInvalidRequestCheckDetails;

  /// No description provided for @errServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service is temporarily unavailable. Please try again shortly.'**
  String get errServiceUnavailable;

  /// No description provided for @errGenericRetry.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGenericRetry;

  /// No description provided for @errReceiverNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receiver not found. They may have been removed.'**
  String get errReceiverNotFound;

  /// No description provided for @errQuoteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This quote is no longer available. Please try again.'**
  String get errQuoteUnavailable;

  /// No description provided for @errRecordNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that record. Please try again.'**
  String get errRecordNotFound;

  /// No description provided for @errPayoutAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'This payout was already submitted.'**
  String get errPayoutAlreadySubmitted;

  /// No description provided for @errMobileMoneyUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Mobile money provider is unreachable right now. Please try again shortly.'**
  String get errMobileMoneyUnreachable;

  /// No description provided for @errBalanceTooLowSend.
  ///
  /// In en, this message translates to:
  /// **'Your balance is too low to send this amount.'**
  String get errBalanceTooLowSend;

  /// No description provided for @errQuoteExpired.
  ///
  /// In en, this message translates to:
  /// **'This quote expired. Please request a new one.'**
  String get errQuoteExpired;

  /// No description provided for @errRateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate is unavailable right now. Please try again.'**
  String get errRateUnavailable;

  /// No description provided for @errEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get errEnterValidAmount;

  /// No description provided for @errBankRejectedAccount.
  ///
  /// In en, this message translates to:
  /// **'Your bank rejected this account. Double-check the routing and account numbers, then try again.'**
  String get errBankRejectedAccount;

  /// No description provided for @errBankNetworkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bank network is unavailable right now. Please try again shortly.'**
  String get errBankNetworkUnavailable;

  /// No description provided for @errBankServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bank service is temporarily unavailable. Please try again shortly.'**
  String get errBankServiceUnavailable;

  /// No description provided for @errRoutingDigits.
  ///
  /// In en, this message translates to:
  /// **'Routing number must be exactly 9 digits.'**
  String get errRoutingDigits;

  /// No description provided for @errAccountNumberDigits.
  ///
  /// In en, this message translates to:
  /// **'Account number must be between 4 and 17 digits.'**
  String get errAccountNumberDigits;

  /// No description provided for @errAchIndividualOnly.
  ///
  /// In en, this message translates to:
  /// **'ACH transfers are only available for individual beneficiaries. Choose Wire for businesses.'**
  String get errAchIndividualOnly;

  /// No description provided for @errTransferTypeWireAch.
  ///
  /// In en, this message translates to:
  /// **'Transfer type must be Wire or ACH.'**
  String get errTransferTypeWireAch;

  /// No description provided for @errAccountTypeCheckingSavings.
  ///
  /// In en, this message translates to:
  /// **'Account type must be Checking or Savings.'**
  String get errAccountTypeCheckingSavings;

  /// No description provided for @errBeneficiaryTypeIndBus.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary type must be Individual or Business.'**
  String get errBeneficiaryTypeIndBus;

  /// No description provided for @errCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Country must be a valid 2-letter code (e.g. US).'**
  String get errCountryCode;

  /// No description provided for @errPostCode.
  ///
  /// In en, this message translates to:
  /// **'Please check the post code.'**
  String get errPostCode;

  /// No description provided for @errCheckBankDetails.
  ///
  /// In en, this message translates to:
  /// **'Please check the bank details and try again.'**
  String get errCheckBankDetails;

  /// No description provided for @errBankRejectedAccountShort.
  ///
  /// In en, this message translates to:
  /// **'Your bank rejected this account. Double-check the details and try again.'**
  String get errBankRejectedAccountShort;

  /// No description provided for @errNoReceivers.
  ///
  /// In en, this message translates to:
  /// **'No receivers found yet.'**
  String get errNoReceivers;

  /// No description provided for @errPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'That phone number doesn\'t look right. Please check and try again.'**
  String get errPhoneInvalid;

  /// No description provided for @errNetworkUnsupported.
  ///
  /// In en, this message translates to:
  /// **'That network isn\'t supported for this country.'**
  String get errNetworkUnsupported;

  /// No description provided for @errReceiverFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the receiver\'s full name (first and last).'**
  String get errReceiverFullName;

  /// No description provided for @errCheckReceiverDetails.
  ///
  /// In en, this message translates to:
  /// **'Please check the receiver details and try again.'**
  String get errCheckReceiverDetails;

  /// No description provided for @errProviderCantVerify.
  ///
  /// In en, this message translates to:
  /// **'The mobile money provider couldn\'t verify this number. Please double-check it.'**
  String get errProviderCantVerify;

  /// No description provided for @errNotEnoughBalance.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough balance to complete this.'**
  String get errNotEnoughBalance;

  /// No description provided for @errCheckInformation.
  ///
  /// In en, this message translates to:
  /// **'Please check your information and try again.'**
  String get errCheckInformation;

  /// No description provided for @errServerOurEnd.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again in a moment.'**
  String get errServerOurEnd;

  /// No description provided for @errUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'We received an unexpected response. Please try again.'**
  String get errUnexpectedResponse;

  /// No description provided for @errTimeoutRetry.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errTimeoutRetry;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get idLabel;

  /// No description provided for @submittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submittedLabel;

  /// No description provided for @instructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsLabel;

  /// No description provided for @submittingLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitting'**
  String get submittingLabel;

  /// No description provided for @p2pCancelTradeCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel trade'**
  String get p2pCancelTradeCta;

  /// No description provided for @p2pConfirmReleaseCta.
  ///
  /// In en, this message translates to:
  /// **'Confirm release'**
  String get p2pConfirmReleaseCta;

  /// No description provided for @p2pSendThisAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Send this amount'**
  String get p2pSendThisAmountTitle;

  /// No description provided for @p2pTransferAmountBeforePaid.
  ///
  /// In en, this message translates to:
  /// **'Transfer {amount} to the seller before marking payment as sent.'**
  String p2pTransferAmountBeforePaid(Object amount);

  /// No description provided for @p2pProofsSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Proofs submitted'**
  String get p2pProofsSubmittedTitle;

  /// No description provided for @p2pPaymentMarkedPaidWaitingSeller.
  ///
  /// In en, this message translates to:
  /// **'Payment marked as paid. Waiting for seller confirmation.'**
  String get p2pPaymentMarkedPaidWaitingSeller;

  /// No description provided for @p2pDisputeOpenedSupportReviewSoon.
  ///
  /// In en, this message translates to:
  /// **'Dispute opened. Our support team will review it shortly.'**
  String get p2pDisputeOpenedSupportReviewSoon;

  /// No description provided for @p2pDisputeOpenedLabel.
  ///
  /// In en, this message translates to:
  /// **'Dispute opened'**
  String get p2pDisputeOpenedLabel;

  /// No description provided for @p2pRaiseDisputeCta.
  ///
  /// In en, this message translates to:
  /// **'Raise dispute'**
  String get p2pRaiseDisputeCta;

  /// No description provided for @p2pYouRatedCounterparty.
  ///
  /// In en, this message translates to:
  /// **'You rated this {counterparty}'**
  String p2pYouRatedCounterparty(Object counterparty);

  /// No description provided for @p2pFeedbackHelpsSafetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps keep trades safe and respectful.'**
  String get p2pFeedbackHelpsSafetySubtitle;

  /// No description provided for @p2pOptionalCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional comment'**
  String get p2pOptionalCommentLabel;

  /// No description provided for @p2pTagsOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get p2pTagsOptionalLabel;

  /// No description provided for @p2pReadyToConfirmPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to confirm payment?'**
  String get p2pReadyToConfirmPaymentTitle;

  /// No description provided for @p2pUploadClearProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload clear payment proof so the seller can release the funds.'**
  String get p2pUploadClearProofSubtitle;

  /// No description provided for @p2pIvePaidCta.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Paid'**
  String get p2pIvePaidCta;

  /// No description provided for @p2pBuyerMarkedPaidTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer marked payment as sent'**
  String get p2pBuyerMarkedPaidTitle;

  /// No description provided for @p2pConfirmFundsThenReleaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the funds have arrived in your account, then release the funds to complete the trade.'**
  String get p2pConfirmFundsThenReleaseSubtitle;

  /// No description provided for @p2pDoNotReleaseBeforeReceiving.
  ///
  /// In en, this message translates to:
  /// **'Do not release funds before receiving payment.'**
  String get p2pDoNotReleaseBeforeReceiving;

  /// No description provided for @p2pReleaseLossWarning.
  ///
  /// In en, this message translates to:
  /// **'Releasing funds without confirmed payment may cause irreversible loss. Opei is not responsible for losses resulting from releasing funds before payment is received.'**
  String get p2pReleaseLossWarning;

  /// No description provided for @p2pShortReasonMinChars.
  ///
  /// In en, this message translates to:
  /// **'Give a short reason (at least 6 characters).'**
  String get p2pShortReasonMinChars;

  /// No description provided for @p2pTellUsWhatWentWrongSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong so our support team can review it quickly.'**
  String get p2pTellUsWhatWentWrongSubtitle;

  /// No description provided for @p2pNoAdsYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No ads just yet'**
  String get p2pNoAdsYetTitle;

  /// No description provided for @p2pNoAdsYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Launch your first buy or sell ad to start trading directly with other users.'**
  String get p2pNoAdsYetSubtitle;

  /// No description provided for @p2pSellingUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Selling USD'**
  String get p2pSellingUsdLabel;

  /// No description provided for @p2pBuyingUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Buying USD'**
  String get p2pBuyingUsdLabel;

  /// No description provided for @p2pDeactivateAdConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This ad will no longer be visible to traders. You can reactivate it later if needed.'**
  String get p2pDeactivateAdConfirmSubtitle;

  /// No description provided for @p2pSelectAtLeastOnePaymentMethodError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one payment method.'**
  String get p2pSelectAtLeastOnePaymentMethodError;

  /// No description provided for @p2pEnterValidAmountsLimitsPriceError.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid amounts, limits and price.'**
  String get p2pEnterValidAmountsLimitsPriceError;

  /// No description provided for @p2pCreateSellAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Create SELL ad'**
  String get p2pCreateSellAdTitle;

  /// No description provided for @p2pStepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String p2pStepOfTotal(Object step, Object total);

  /// No description provided for @p2pTellOthersRecognizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell others how to recognize you. You can edit this later.'**
  String get p2pTellOthersRecognizeSubtitle;

  /// No description provided for @p2pChooseMethodsToPaySellers.
  ///
  /// In en, this message translates to:
  /// **'Choose the payment methods you\'ll use to pay sellers. Only the rail name appears on your ad.'**
  String get p2pChooseMethodsToPaySellers;

  /// No description provided for @p2pSelectHowBuyersPayYou.
  ///
  /// In en, this message translates to:
  /// **'Select how buyers can pay you in {currency}. We\'ll share the details after a trade opens.'**
  String p2pSelectHowBuyersPayYou(Object currency);

  /// No description provided for @p2pNoMethodsYetForCurrency.
  ///
  /// In en, this message translates to:
  /// **'No {currency} methods yet. Add one to continue.'**
  String p2pNoMethodsYetForCurrency(Object currency);

  /// No description provided for @p2pSetAmountLimitsPriceInstructions.
  ///
  /// In en, this message translates to:
  /// **'Set the amount, limits, price, and instructions (optional).'**
  String get p2pSetAmountLimitsPriceInstructions;

  /// No description provided for @p2pAttachUpToFiveMethodsError.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to five payment methods.'**
  String get p2pAttachUpToFiveMethodsError;

  /// No description provided for @p2pMaxFiveMethodsPerAd.
  ///
  /// In en, this message translates to:
  /// **'Maximum of five payment methods per ad.'**
  String get p2pMaxFiveMethodsPerAd;

  /// No description provided for @p2pAttachUpToFiveMethodsPerAd.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to five payment methods per ad.'**
  String get p2pAttachUpToFiveMethodsPerAd;

  /// No description provided for @p2pSaveProfileCta.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get p2pSaveProfileCta;

  /// No description provided for @p2pSetUpProfileToContinue.
  ///
  /// In en, this message translates to:
  /// **'Set up your P2P profile to continue.'**
  String get p2pSetUpProfileToContinue;

  /// No description provided for @p2pPleaseSignInAgainError.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get p2pPleaseSignInAgainError;

  /// No description provided for @p2pPaymentProviderInactiveError.
  ///
  /// In en, this message translates to:
  /// **'Payment provider is currently inactive.'**
  String get p2pPaymentProviderInactiveError;

  /// No description provided for @p2pPaymentMethodNoLongerExistsError.
  ///
  /// In en, this message translates to:
  /// **'Payment method no longer exists.'**
  String get p2pPaymentMethodNoLongerExistsError;

  /// No description provided for @p2pPaymentMethodAttachedToActiveAdError.
  ///
  /// In en, this message translates to:
  /// **'This payment method is attached to an active ad and can\'t be edited.'**
  String get p2pPaymentMethodAttachedToActiveAdError;

  /// No description provided for @p2pPaymentMethodInOngoingTradeError.
  ///
  /// In en, this message translates to:
  /// **'This payment method is being used in an ongoing trade.'**
  String get p2pPaymentMethodInOngoingTradeError;

  /// No description provided for @p2pPaymentProviderNotAvailableError.
  ///
  /// In en, this message translates to:
  /// **'Payment provider is not available.'**
  String get p2pPaymentProviderNotAvailableError;

  /// No description provided for @p2pAccountNumberExistsError.
  ///
  /// In en, this message translates to:
  /// **'Account number already exists for this user.'**
  String get p2pAccountNumberExistsError;

  /// No description provided for @p2pMaxPaymentMethodsReachedError.
  ///
  /// In en, this message translates to:
  /// **'Maximum payment methods reached for this currency.'**
  String get p2pMaxPaymentMethodsReachedError;

  /// No description provided for @p2pCheckDetailsTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'Please check your details and try again.'**
  String get p2pCheckDetailsTryAgainError;

  /// No description provided for @p2pCouldNotSaveMethodError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save this method. Please try again.'**
  String get p2pCouldNotSaveMethodError;

  /// No description provided for @p2pSelectPaymentProviderError.
  ///
  /// In en, this message translates to:
  /// **'Select a payment provider.'**
  String get p2pSelectPaymentProviderError;

  /// No description provided for @p2pNoChangesDetectedError.
  ///
  /// In en, this message translates to:
  /// **'No changes detected.'**
  String get p2pNoChangesDetectedError;

  /// No description provided for @p2pSelectProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Select provider'**
  String get p2pSelectProviderTitle;

  /// No description provided for @p2pEditPaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit payment method'**
  String get p2pEditPaymentMethodTitle;

  /// No description provided for @p2pAddPaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get p2pAddPaymentMethodTitle;

  /// No description provided for @p2pUpdatePaymentMethodDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the details for this payment method.'**
  String get p2pUpdatePaymentMethodDetailsSubtitle;

  /// No description provided for @p2pChooseProviderAddAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a provider and add your account details.'**
  String get p2pChooseProviderAddAccountSubtitle;

  /// No description provided for @p2pNoProvidersAvailableLabel.
  ///
  /// In en, this message translates to:
  /// **'No providers available'**
  String get p2pNoProvidersAvailableLabel;

  /// No description provided for @p2pUpdateMethodCta.
  ///
  /// In en, this message translates to:
  /// **'Update method'**
  String get p2pUpdateMethodCta;

  /// No description provided for @p2pSaveMethodCta.
  ///
  /// In en, this message translates to:
  /// **'Save method'**
  String get p2pSaveMethodCta;

  /// No description provided for @p2pSubmitForReviewCta.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get p2pSubmitForReviewCta;

  /// No description provided for @p2pCouldNotLoadPaymentOptionsError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load payment options. Please try again.'**
  String get p2pCouldNotLoadPaymentOptionsError;

  /// No description provided for @p2pTradesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} trades'**
  String p2pTradesCount(Object count);

  /// No description provided for @p2pPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get p2pPriceLabel;

  /// No description provided for @p2pAvailableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available {amount}'**
  String p2pAvailableAmount(Object amount);

  /// No description provided for @p2pTradeCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trade created'**
  String get p2pTradeCreatedTitle;

  /// No description provided for @p2pYouWillReceiveLabel.
  ///
  /// In en, this message translates to:
  /// **'You will receive'**
  String get p2pYouWillReceiveLabel;

  /// No description provided for @p2pAdInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ad instructions'**
  String get p2pAdInstructionsLabel;

  /// No description provided for @p2pNotifyWhenBuyerMarksPaid.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you once the buyer marks payment as sent. Go to Orders to review proof and release the funds.'**
  String get p2pNotifyWhenBuyerMarksPaid;

  /// No description provided for @p2pSendPaymentUsingDetails.
  ///
  /// In en, this message translates to:
  /// **'Send payment using the details below.'**
  String get p2pSendPaymentUsingDetails;

  /// No description provided for @p2pPayWithin30MinutesWarning.
  ///
  /// In en, this message translates to:
  /// **'Pay within 30 minutes and confirm, or this trade will be cancelled.'**
  String get p2pPayWithin30MinutesWarning;

  /// No description provided for @p2pSellerPaymentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Payment Details'**
  String get p2pSellerPaymentDetailsTitle;

  /// No description provided for @p2pSellerSharesFinalDetailsInChat.
  ///
  /// In en, this message translates to:
  /// **'Seller will share the final account details in chat.'**
  String get p2pSellerSharesFinalDetailsInChat;

  /// No description provided for @p2pYouSendLabel.
  ///
  /// In en, this message translates to:
  /// **'You send'**
  String get p2pYouSendLabel;

  /// No description provided for @p2pSellerInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Instructions'**
  String get p2pSellerInstructionsTitle;

  /// No description provided for @p2pWaitingForSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the seller'**
  String get p2pWaitingForSellerTitle;

  /// No description provided for @p2pWaitingForSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve notified the other party. Once they confirm payment, your USD will be released to your wallet. We\'ll let you know immediately.'**
  String get p2pWaitingForSellerSubtitle;

  /// No description provided for @p2pAddingYourProofLabel.
  ///
  /// In en, this message translates to:
  /// **'Adding your proof...'**
  String get p2pAddingYourProofLabel;

  /// No description provided for @p2pSubmittedProofsTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitted proofs'**
  String get p2pSubmittedProofsTitle;

  /// No description provided for @p2pVisibleToSellerSupport.
  ///
  /// In en, this message translates to:
  /// **'Visible to the seller and support team.'**
  String get p2pVisibleToSellerSupport;

  /// No description provided for @p2pProofOfPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Proof of payment'**
  String get p2pProofOfPaymentTitle;

  /// No description provided for @p2pSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected}/{total} selected'**
  String p2pSelectedCount(Object selected, Object total);

  /// No description provided for @p2pProofSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Proof submitted'**
  String get p2pProofSubmittedTitle;

  /// No description provided for @p2pProofSubmittedSellerNotified.
  ///
  /// In en, this message translates to:
  /// **'We\'ve notified the seller. They\'ll review your proof and release the funds once they confirm payment.'**
  String get p2pProofSubmittedSellerNotified;

  /// No description provided for @p2pWhatHappensNextTitle.
  ///
  /// In en, this message translates to:
  /// **'What happens next?'**
  String get p2pWhatHappensNextTitle;

  /// No description provided for @p2pOnceConfirmedFundsReleased.
  ///
  /// In en, this message translates to:
  /// **'Once confirmed, the funds are released automatically.'**
  String get p2pOnceConfirmedFundsReleased;

  /// No description provided for @p2pReceiveNotificationEveryUpdate.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive a notification for every update.'**
  String get p2pReceiveNotificationEveryUpdate;

  /// No description provided for @p2pCancelThisTradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this trade?'**
  String get p2pCancelThisTradeTitle;

  /// No description provided for @p2pDoNotCancelAfterSending.
  ///
  /// In en, this message translates to:
  /// **'Do not cancel after sending money.'**
  String get p2pDoNotCancelAfterSending;

  /// No description provided for @p2pCancelAfterPaymentLossWarning.
  ///
  /// In en, this message translates to:
  /// **'Canceling after payment may cause irreversible loss. Opei is not responsible for losses resulting from user cancellation after payment.'**
  String get p2pCancelAfterPaymentLossWarning;

  /// No description provided for @p2pUploadProofTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Proof'**
  String get p2pUploadProofTitle;

  /// No description provided for @p2pUploadProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload 1-3 clear images showing your payment confirmation'**
  String get p2pUploadProofSubtitle;

  /// No description provided for @p2pUpTo3ImagesMax5Mb.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 images - Max 5 MB each'**
  String get p2pUpTo3ImagesMax5Mb;

  /// No description provided for @p2pNoteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get p2pNoteOptionalLabel;

  /// No description provided for @p2pSubmitProofCta.
  ///
  /// In en, this message translates to:
  /// **'Submit Proof'**
  String get p2pSubmitProofCta;

  /// No description provided for @p2pSideBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get p2pSideBuy;

  /// No description provided for @p2pSideSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get p2pSideSell;

  /// No description provided for @p2pUnknownMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown method'**
  String get p2pUnknownMethodLabel;

  /// No description provided for @p2pUnknownTraderLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown trader'**
  String get p2pUnknownTraderLabel;

  /// No description provided for @p2pNoPaymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'No payment method'**
  String get p2pNoPaymentMethodLabel;

  /// No description provided for @p2pMethodsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} methods'**
  String p2pMethodsCount(Object count);

  /// No description provided for @p2pTradeStatusPendingPayment.
  ///
  /// In en, this message translates to:
  /// **'Pending payment'**
  String get p2pTradeStatusPendingPayment;

  /// No description provided for @p2pTradeStatusPendingRelease.
  ///
  /// In en, this message translates to:
  /// **'Pending release'**
  String get p2pTradeStatusPendingRelease;

  /// No description provided for @p2pTradeStatusReleaseConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Release confirmed'**
  String get p2pTradeStatusReleaseConfirmed;

  /// No description provided for @p2pAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get p2pAccountLabel;

  /// No description provided for @cardTransactionFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Card transaction'**
  String get cardTransactionFallbackTitle;

  /// No description provided for @cardTransactionDebitLabel.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get cardTransactionDebitLabel;

  /// No description provided for @cardTransactionCreditLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get cardTransactionCreditLabel;

  /// No description provided for @walletUsdDepositLabel.
  ///
  /// In en, this message translates to:
  /// **'USD Deposit'**
  String get walletUsdDepositLabel;

  /// No description provided for @walletUsdWithdrawalLabel.
  ///
  /// In en, this message translates to:
  /// **'USD Withdrawal'**
  String get walletUsdWithdrawalLabel;

  /// No description provided for @walletBuyUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Buy USD'**
  String get walletBuyUsdLabel;

  /// No description provided for @walletSellUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'Sell USD'**
  String get walletSellUsdLabel;

  /// No description provided for @walletDepositWithdrawLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit / Withdraw'**
  String get walletDepositWithdrawLabel;

  /// No description provided for @walletMoneyReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Money received'**
  String get walletMoneyReceivedLabel;

  /// No description provided for @walletMoneySentLabel.
  ///
  /// In en, this message translates to:
  /// **'Money sent'**
  String get walletMoneySentLabel;

  /// No description provided for @walletFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get walletFallbackTitle;

  /// No description provided for @p2pTraderLabel.
  ///
  /// In en, this message translates to:
  /// **'Trader'**
  String get p2pTraderLabel;

  /// No description provided for @profileLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// No description provided for @profileLanguageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get profileLanguageFrench;

  /// No description provided for @profileLanguagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get profileLanguagePortuguese;

  /// No description provided for @profileLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get profileLanguageSpanish;

  /// No description provided for @profileLanguageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get profileLanguageSwahili;

  /// No description provided for @addressFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String addressFieldRequired(Object fieldName);

  /// No description provided for @addressMax60CharsError.
  ///
  /// In en, this message translates to:
  /// **'Maximum 60 characters allowed'**
  String get addressMax60CharsError;

  /// No description provided for @addressAllowedCharsError.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, spaces, and ,./-/ are allowed'**
  String get addressAllowedCharsError;

  /// No description provided for @addressFixErrorsBelow.
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors below'**
  String get addressFixErrorsBelow;

  /// No description provided for @addressUnableSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit address. Please try again.'**
  String get addressUnableSubmitError;

  /// No description provided for @addressCountryRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get addressCountryRequiredError;

  /// No description provided for @p2pMinAmountHigherThanMaxError.
  ///
  /// In en, this message translates to:
  /// **'The minimum amount can’t be higher than the maximum.'**
  String get p2pMinAmountHigherThanMaxError;

  /// No description provided for @p2pNoAdsAvailableNowInfo.
  ///
  /// In en, this message translates to:
  /// **'No ads available right now.'**
  String get p2pNoAdsAvailableNowInfo;

  /// No description provided for @p2pFiltersApplyFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t apply those filters. Please try again.'**
  String get p2pFiltersApplyFailedError;

  /// No description provided for @p2pNoAdsForStatusInfo.
  ///
  /// In en, this message translates to:
  /// **'No ads found for this status yet.'**
  String get p2pNoAdsForStatusInfo;

  /// No description provided for @p2pAdMovedToInactiveInfo.
  ///
  /// In en, this message translates to:
  /// **'Ad moved to inactive.'**
  String get p2pAdMovedToInactiveInfo;

  /// No description provided for @p2pAdUpdatedInfo.
  ///
  /// In en, this message translates to:
  /// **'Ad updated.'**
  String get p2pAdUpdatedInfo;

  /// No description provided for @p2pDeactivateOwnAdsError.
  ///
  /// In en, this message translates to:
  /// **'You can only deactivate your own ads.'**
  String get p2pDeactivateOwnAdsError;

  /// No description provided for @p2pAdNoLongerAvailableError.
  ///
  /// In en, this message translates to:
  /// **'This ad is no longer available.'**
  String get p2pAdNoLongerAvailableError;

  /// No description provided for @p2pDeactivateTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t deactivate this ad right now. Please try again.'**
  String get p2pDeactivateTryAgainError;

  /// No description provided for @p2pSessionVerifyProfileError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify your session. Please sign in again to view your profile.'**
  String get p2pSessionVerifyProfileError;

  /// No description provided for @p2pNoPermissionViewProfileError.
  ///
  /// In en, this message translates to:
  /// **'You don’t have permission to view this profile.'**
  String get p2pNoPermissionViewProfileError;

  /// No description provided for @p2pProfileLoadingTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble loading your profile right now. Please try again.'**
  String get p2pProfileLoadingTryAgainError;

  /// No description provided for @p2pProfileLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your profile right now. Please try again.'**
  String get p2pProfileLoadFailedError;

  /// No description provided for @p2pTradeIdentifyFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t identify this trade. Please try again.'**
  String get p2pTradeIdentifyFailedError;

  /// No description provided for @p2pNoOrdersForStatusInfo.
  ///
  /// In en, this message translates to:
  /// **'No orders in this status yet.'**
  String get p2pNoOrdersForStatusInfo;

  /// No description provided for @p2pFilterUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'That filter isn’t available. Please pick another status.'**
  String get p2pFilterUnavailableError;

  /// No description provided for @p2pOrdersLoadingTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble loading your orders right now. Please try again.'**
  String get p2pOrdersLoadingTryAgainError;

  /// No description provided for @p2pTradeNotFoundMaybeRemovedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this trade. It may have been removed.'**
  String get p2pTradeNotFoundMaybeRemovedError;

  /// No description provided for @p2pTradeCannotCancelAnymoreError.
  ///
  /// In en, this message translates to:
  /// **'This trade can’t be cancelled anymore.'**
  String get p2pTradeCannotCancelAnymoreError;

  /// No description provided for @p2pTradeAlreadyCancelledError.
  ///
  /// In en, this message translates to:
  /// **'This trade is already cancelled.'**
  String get p2pTradeAlreadyCancelledError;

  /// No description provided for @p2pTradeCancelFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t cancel this trade. Please try again.'**
  String get p2pTradeCancelFailedError;

  /// No description provided for @p2pTradeCancelTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t cancel this trade right now. Please try again.'**
  String get p2pTradeCancelTryAgainError;

  /// No description provided for @p2pOnlyBuyerCanCancelTradeError.
  ///
  /// In en, this message translates to:
  /// **'Only the buyer who opened this trade can cancel it.'**
  String get p2pOnlyBuyerCanCancelTradeError;

  /// No description provided for @p2pOnlySellerCanCancelTradeError.
  ///
  /// In en, this message translates to:
  /// **'Only the seller who listed this ad can cancel it.'**
  String get p2pOnlySellerCanCancelTradeError;

  /// No description provided for @cardsDetailsLoadUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble loading your card details. Please try again soon.'**
  String get cardsDetailsLoadUnavailableError;

  /// No description provided for @cardsLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Card locked'**
  String get cardsLockedMessage;

  /// No description provided for @cardsUnlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Card unlocked'**
  String get cardsUnlockedMessage;

  /// No description provided for @cardsTerminatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Card terminated'**
  String get cardsTerminatedMessage;

  /// No description provided for @cardsUpdateUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble updating your card. Please try again soon.'**
  String get cardsUpdateUnavailableError;

  /// No description provided for @cardsCloseUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble closing your card. Please try again soon.'**
  String get cardsCloseUnavailableError;

  /// No description provided for @cardsTopupInvalidPositiveAmountError.
  ///
  /// In en, this message translates to:
  /// **'The amount you entered isn’t valid. Please enter a positive amount.'**
  String get cardsTopupInvalidPositiveAmountError;

  /// No description provided for @cardsTopupReviewDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Please review the top-up details before continuing.'**
  String get cardsTopupReviewDetailsError;

  /// No description provided for @cardsTopupInsufficientBalanceError.
  ///
  /// In en, this message translates to:
  /// **'You don’t have enough balance to complete this top-up.'**
  String get cardsTopupInsufficientBalanceError;

  /// No description provided for @cardsTopupCardInactiveError.
  ///
  /// In en, this message translates to:
  /// **'This card is not active; unfreeze it before topping up.'**
  String get cardsTopupCardInactiveError;

  /// No description provided for @cardsTopupActivateProfileError.
  ///
  /// In en, this message translates to:
  /// **'You need to activate your card profile before you can continue.'**
  String get cardsTopupActivateProfileError;

  /// No description provided for @cardsTopupWalletLowBalanceError.
  ///
  /// In en, this message translates to:
  /// **'Your wallet balance is too low for this top-up.'**
  String get cardsTopupWalletLowBalanceError;

  /// No description provided for @cardsTopupAccountLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while loading your account. Please try again.'**
  String get cardsTopupAccountLoadFailedError;

  /// No description provided for @cardsTopupSessionInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Something isn’t right with your account session. Please sign in again.'**
  String get cardsTopupSessionInvalidError;

  /// No description provided for @cardsTopupCardNotFoundRefreshError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this card. Please refresh and try again.'**
  String get cardsTopupCardNotFoundRefreshError;

  /// No description provided for @cardsTopupCardNotReadyError.
  ///
  /// In en, this message translates to:
  /// **'Your card is being set up. Please try again in a moment.'**
  String get cardsTopupCardNotReadyError;

  /// No description provided for @cardsTopupCardNoLongerActiveError.
  ///
  /// In en, this message translates to:
  /// **'This card is no longer active.'**
  String get cardsTopupCardNoLongerActiveError;

  /// No description provided for @cardsTopupWalletNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find your wallet. Please contact support.'**
  String get cardsTopupWalletNotFoundError;

  /// No description provided for @cardsTopupWalletUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'The wallet service is temporarily unavailable. Please try again shortly.'**
  String get cardsTopupWalletUnavailableError;

  /// No description provided for @cardsTopupFinishSetupError.
  ///
  /// In en, this message translates to:
  /// **'You need to finish your card setup before topping up.'**
  String get cardsTopupFinishSetupError;

  /// No description provided for @cardsTopupCardNotReadyYetError.
  ///
  /// In en, this message translates to:
  /// **'Your card isn’t ready yet. Try again in a moment.'**
  String get cardsTopupCardNotReadyYetError;

  /// No description provided for @cardsTopupCardClosedError.
  ///
  /// In en, this message translates to:
  /// **'This card has been closed and can’t be topped up.'**
  String get cardsTopupCardClosedError;

  /// No description provided for @cardsTopupReserveBalanceLowError.
  ///
  /// In en, this message translates to:
  /// **'You don’t have enough available balance to reserve this amount.'**
  String get cardsTopupReserveBalanceLowError;

  /// No description provided for @cardsTopupCardNotFoundOnAccountError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this card on your account.'**
  String get cardsTopupCardNotFoundOnAccountError;

  /// No description provided for @cardsTopupProviderFailureError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t complete your card top-up right now. Please try again shortly.'**
  String get cardsTopupProviderFailureError;

  /// No description provided for @cardsTopupWalletUnavailableSoonError.
  ///
  /// In en, this message translates to:
  /// **'Wallet service is temporarily unavailable. Please try again soon.'**
  String get cardsTopupWalletUnavailableSoonError;

  /// No description provided for @cardsWithdrawAmountAboveZeroError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount above zero.'**
  String get cardsWithdrawAmountAboveZeroError;

  /// No description provided for @cardsWithdrawAmountNotAllowedError.
  ///
  /// In en, this message translates to:
  /// **'This amount can’t be withdrawn right now. Please adjust it and try again.'**
  String get cardsWithdrawAmountNotAllowedError;

  /// No description provided for @cardsWithdrawReviewDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Please review the withdrawal details before confirming.'**
  String get cardsWithdrawReviewDetailsError;

  /// No description provided for @cardsWithdrawCardBalanceLowError.
  ///
  /// In en, this message translates to:
  /// **'Your card balance is not enough for this withdrawal.'**
  String get cardsWithdrawCardBalanceLowError;

  /// No description provided for @cardsWithdrawAmountTooLowAfterFeesError.
  ///
  /// In en, this message translates to:
  /// **'The amount is too small once fees are applied. Try a slightly higher amount.'**
  String get cardsWithdrawAmountTooLowAfterFeesError;

  /// No description provided for @cardsWithdrawCardNotReadyError.
  ///
  /// In en, this message translates to:
  /// **'This card is still being set up. Please try again shortly.'**
  String get cardsWithdrawCardNotReadyError;

  /// No description provided for @cardsWithdrawCardClosedError.
  ///
  /// In en, this message translates to:
  /// **'This card has been closed and can’t be used for withdrawals.'**
  String get cardsWithdrawCardClosedError;

  /// No description provided for @cardsWithdrawMinimumBalanceRequiredError.
  ///
  /// In en, this message translates to:
  /// **'You must keep at least \$1 on the card.'**
  String get cardsWithdrawMinimumBalanceRequiredError;

  /// No description provided for @cardsWithdrawCardInactiveError.
  ///
  /// In en, this message translates to:
  /// **'This card is not active; unfreeze it before withdrawing.'**
  String get cardsWithdrawCardInactiveError;

  /// No description provided for @cardsWithdrawSessionVerifyError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify your account session. Please sign in again.'**
  String get cardsWithdrawSessionVerifyError;

  /// No description provided for @cardsWithdrawStartFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t start the withdrawal. Please try again.'**
  String get cardsWithdrawStartFailedError;

  /// No description provided for @cardsWithdrawProviderUnavailableMomentError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble reaching the card provider. Please try again in a moment.'**
  String get cardsWithdrawProviderUnavailableMomentError;

  /// No description provided for @cardsWithdrawValidAmountAboveZeroError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount above zero.'**
  String get cardsWithdrawValidAmountAboveZeroError;

  /// No description provided for @cardsWithdrawFinishSetupError.
  ///
  /// In en, this message translates to:
  /// **'Please finish your card setup before withdrawing.'**
  String get cardsWithdrawFinishSetupError;

  /// No description provided for @cardsWithdrawAmountTooLowAfterFeesHigherError.
  ///
  /// In en, this message translates to:
  /// **'The amount is too small once fees are applied. Try a higher amount.'**
  String get cardsWithdrawAmountTooLowAfterFeesHigherError;

  /// No description provided for @cardsWithdrawCompleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t complete the withdrawal. Please try again.'**
  String get cardsWithdrawCompleteFailedError;

  /// No description provided for @cardsWithdrawTooManyAttemptsError.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again in about {duration}.'**
  String cardsWithdrawTooManyAttemptsError(Object duration);

  /// No description provided for @cardsWithdrawRequestInProgressRetryError.
  ///
  /// In en, this message translates to:
  /// **'We’re processing another request. Give it a moment before retrying.'**
  String get cardsWithdrawRequestInProgressRetryError;

  /// No description provided for @cardsWithdrawRequestInProgressWaitError.
  ///
  /// In en, this message translates to:
  /// **'We’re processing another request. Please wait a moment and try again.'**
  String get cardsWithdrawRequestInProgressWaitError;

  /// No description provided for @cardsWithdrawProviderUnavailableShortlyError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble with the card provider right now. Please try again shortly.'**
  String get cardsWithdrawProviderUnavailableShortlyError;

  /// No description provided for @cardsCreationReadyContinueInfo.
  ///
  /// In en, this message translates to:
  /// **'Your card is ready. You can continue setting up your card.'**
  String get cardsCreationReadyContinueInfo;

  /// No description provided for @cardsCreationCompleteProfileError.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to continue.'**
  String get cardsCreationCompleteProfileError;

  /// No description provided for @cardsCreationSessionExpiredContinueError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again to continue.'**
  String get cardsCreationSessionExpiredContinueError;

  /// No description provided for @cardsCreationServiceUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Card service temporarily unavailable. Please try again shortly.'**
  String get cardsCreationServiceUnavailableError;

  /// No description provided for @cardsCreationAmountAboveZeroError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount above 0.00 to continue.'**
  String get cardsCreationAmountAboveZeroError;

  /// No description provided for @cardsCreationPreviewMissingError.
  ///
  /// In en, this message translates to:
  /// **'Preview details are missing. Please try again.'**
  String get cardsCreationPreviewMissingError;

  /// No description provided for @cardsCreationAddFundsError.
  ///
  /// In en, this message translates to:
  /// **'Add funds to your wallet before creating this card.'**
  String get cardsCreationAddFundsError;

  /// No description provided for @cardsCreationWillAppearSoonInfo.
  ///
  /// In en, this message translates to:
  /// **'Your card is created. It will appear in your cards list shortly.'**
  String get cardsCreationWillAppearSoonInfo;

  /// No description provided for @cardsCreationReadyAppearSoonInfo.
  ///
  /// In en, this message translates to:
  /// **'Your card is ready. It will appear in your cards list shortly.'**
  String get cardsCreationReadyAppearSoonInfo;

  /// No description provided for @cardsCreationRegisterProfileError.
  ///
  /// In en, this message translates to:
  /// **'You need to register your card profile before continuing.'**
  String get cardsCreationRegisterProfileError;

  /// No description provided for @cardsCreationBalanceLowError.
  ///
  /// In en, this message translates to:
  /// **'Your balance is too low to complete this action.'**
  String get cardsCreationBalanceLowError;

  /// No description provided for @cardsCreationServiceUnavailableSoonError.
  ///
  /// In en, this message translates to:
  /// **'Card services are temporarily unavailable. Please try again soon.'**
  String get cardsCreationServiceUnavailableSoonError;

  /// No description provided for @cardsCreationRegisterProfilePromptError.
  ///
  /// In en, this message translates to:
  /// **'Please register your card profile before continuing.'**
  String get cardsCreationRegisterProfilePromptError;

  /// No description provided for @cardsCreationRequestProcessingError.
  ///
  /// In en, this message translates to:
  /// **'This request is already being processed.'**
  String get cardsCreationRequestProcessingError;

  /// No description provided for @cardsPromoRegistrationIssueError.
  ///
  /// In en, this message translates to:
  /// **'Registration issue detected. Please close and try again.'**
  String get cardsPromoRegistrationIssueError;

  /// No description provided for @cardsPromoBalanceChangedError.
  ///
  /// In en, this message translates to:
  /// **'Your balance changed. Please close and try again after topping up.'**
  String get cardsPromoBalanceChangedError;

  /// No description provided for @cardsPromoUnavailableLaterError.
  ///
  /// In en, this message translates to:
  /// **'Virtual card is no longer available. Please try again later.'**
  String get cardsPromoUnavailableLaterError;

  /// No description provided for @cardsPromoWalletUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Wallet service is temporarily unavailable. Please try again shortly.'**
  String get cardsPromoWalletUnavailableError;

  /// No description provided for @expressOrderConfirmedFundsReleased.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed. Funds released to the customer.'**
  String get expressOrderConfirmedFundsReleased;

  /// No description provided for @expressDisputeOpenedUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Dispute opened. Under admin review.'**
  String get expressDisputeOpenedUnderReview;

  /// No description provided for @expressNotAllowedActionError.
  ///
  /// In en, this message translates to:
  /// **'You are not allowed to perform this action.'**
  String get expressNotAllowedActionError;

  /// No description provided for @expressOrderNoLongerExistsError.
  ///
  /// In en, this message translates to:
  /// **'Order no longer exists.'**
  String get expressOrderNoLongerExistsError;

  /// No description provided for @expressOrderUpdatedRefreshInfo.
  ///
  /// In en, this message translates to:
  /// **'Order updated by another action. Refreshing...'**
  String get expressOrderUpdatedRefreshInfo;

  /// No description provided for @expressCouldNotPickImages.
  ///
  /// In en, this message translates to:
  /// **'Could not pick images.'**
  String get expressCouldNotPickImages;

  /// No description provided for @expressDisputeMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Dispute message is required.'**
  String get expressDisputeMessageRequired;

  /// No description provided for @expressWaitingForCustomerProof.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the customer to pay and upload proof.'**
  String get expressWaitingForCustomerProof;

  /// No description provided for @expressNoProofUploadedYet.
  ///
  /// In en, this message translates to:
  /// **'No proof uploaded yet.'**
  String get expressNoProofUploadedYet;

  /// No description provided for @cardsRepoIncompleteProfileError.
  ///
  /// In en, this message translates to:
  /// **'Your profile is incomplete. Please finish KYC before creating a card.'**
  String get cardsRepoIncompleteProfileError;

  /// No description provided for @cardsRepoRegistrationUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Card registration is temporarily unavailable. Please try again shortly.'**
  String get cardsRepoRegistrationUnavailableError;

  /// No description provided for @cardsRepoVirtualCardUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Virtual card is not available right now. Please try again later.'**
  String get cardsRepoVirtualCardUnavailableError;

  /// No description provided for @cardsRepoServiceUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Card service is temporarily unavailable. Please try again shortly.'**
  String get cardsRepoServiceUnavailableError;

  /// No description provided for @loginInvalidCredentialsError.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or PIN. Please try again.'**
  String get loginInvalidCredentialsError;

  /// No description provided for @loginAccountInactiveError.
  ///
  /// In en, this message translates to:
  /// **'Your account is not active. Please contact support.'**
  String get loginAccountInactiveError;

  /// No description provided for @loginTooManyAttemptsError.
  ///
  /// In en, this message translates to:
  /// **'Too many login attempts. Please try again in a few minutes.'**
  String get loginTooManyAttemptsError;

  /// No description provided for @cardStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get cardStatusUnknown;

  /// No description provided for @expressOrderCancelledSnack.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled.'**
  String get expressOrderCancelledSnack;

  /// No description provided for @expressExpiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring...'**
  String get expressExpiring;

  /// No description provided for @expressExpiresInHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'Expires in {hours}h {minutes}m'**
  String expressExpiresInHoursMinutes(Object hours, Object minutes);

  /// No description provided for @expressExpiresInMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'Expires in {minutes}m {seconds}s'**
  String expressExpiresInMinutesSeconds(Object minutes, Object seconds);

  /// No description provided for @expressExpiresInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Expires in {seconds}s'**
  String expressExpiresInSeconds(Object seconds);

  /// No description provided for @expressIvePaidUploadProofCta.
  ///
  /// In en, this message translates to:
  /// **'I\'ve paid — upload proof'**
  String get expressIvePaidUploadProofCta;

  /// No description provided for @expressOrderExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Order expired'**
  String get expressOrderExpiredTitle;

  /// No description provided for @expressOrderCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get expressOrderCancelledTitle;

  /// No description provided for @expressNoAgentAcceptedOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'No agent accepted this order in time. You can start a new deposit.'**
  String get expressNoAgentAcceptedOrderMessage;

  /// No description provided for @expressOrderExpiredBeforeCompletionMessage.
  ///
  /// In en, this message translates to:
  /// **'This order expired before completion. You can start a new deposit.'**
  String get expressOrderExpiredBeforeCompletionMessage;

  /// No description provided for @expressOrderCancelledStartNewDepositMessage.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled. You can start a new deposit.'**
  String get expressOrderCancelledStartNewDepositMessage;

  /// No description provided for @expressAttachUpToImagesError.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to {maxImages} images.'**
  String expressAttachUpToImagesError(Object maxImages);

  /// No description provided for @expressCouldNotPickImagesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not pick images. Please try again.'**
  String get expressCouldNotPickImagesTryAgain;

  /// No description provided for @p2pSessionVerifyManageMethodsError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t verify your session. Please sign in again to manage payment methods.'**
  String get p2pSessionVerifyManageMethodsError;

  /// No description provided for @p2pPaymentMethodsLoadTryAgainSoonError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble loading your payment methods right now. Please try again shortly.'**
  String get p2pPaymentMethodsLoadTryAgainSoonError;

  /// No description provided for @p2pPaymentMethodsLoadFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load payment methods right now. Please try again.'**
  String get p2pPaymentMethodsLoadFailedError;

  /// No description provided for @p2pAlreadyConfirmedPaymentError.
  ///
  /// In en, this message translates to:
  /// **'You already confirmed payment for this trade.'**
  String get p2pAlreadyConfirmedPaymentError;

  /// No description provided for @p2pSubmitProofCheckTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t submit those proofs. Please check and try again.'**
  String get p2pSubmitProofCheckTryAgainError;

  /// No description provided for @p2pProofImagesTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'Those images are too large. Please upload photos under 5 MB each.'**
  String get p2pProofImagesTooLargeError;

  /// No description provided for @p2pProofServerIssueRetryError.
  ///
  /// In en, this message translates to:
  /// **'Server issue while submitting your proofs. Please try again in a moment.'**
  String get p2pProofServerIssueRetryError;

  /// No description provided for @p2pProofSubmitNowError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t submit your proofs right now.'**
  String get p2pProofSubmitNowError;

  /// No description provided for @p2pProofNetworkUploadRetryError.
  ///
  /// In en, this message translates to:
  /// **'Network issue while uploading. Check your connection and retry.'**
  String get p2pProofNetworkUploadRetryError;

  /// No description provided for @p2pProofUploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get p2pProofUploadFailedError;

  /// No description provided for @p2pProofSubmitFailedRetryError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while submitting your proofs. Please try again.'**
  String get p2pProofSubmitFailedRetryError;

  /// No description provided for @p2pOnlyAssignedSellerReleaseError.
  ///
  /// In en, this message translates to:
  /// **'Only the seller assigned to this trade can release the funds.'**
  String get p2pOnlyAssignedSellerReleaseError;

  /// No description provided for @p2pTradeNotFoundMaybeClosedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this trade. It may have been closed already.'**
  String get p2pTradeNotFoundMaybeClosedError;

  /// No description provided for @p2pTradeAlreadyReleasedError.
  ///
  /// In en, this message translates to:
  /// **'This trade has already been released.'**
  String get p2pTradeAlreadyReleasedError;

  /// No description provided for @p2pReleaseAfterBuyerMarksPaidError.
  ///
  /// In en, this message translates to:
  /// **'You can only release once the buyer marks payment as sent.'**
  String get p2pReleaseAfterBuyerMarksPaidError;

  /// No description provided for @p2pReleaseTradeFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t release this trade right now. Please try again.'**
  String get p2pReleaseTradeFailedError;

  /// No description provided for @p2pReleaseFundsTryAgainSoonError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble releasing funds right now. Please try again soon.'**
  String get p2pReleaseFundsTryAgainSoonError;

  /// No description provided for @p2pNotPartOfTradeRatingError.
  ///
  /// In en, this message translates to:
  /// **'You’re not part of this trade, so you can’t leave a rating.'**
  String get p2pNotPartOfTradeRatingError;

  /// No description provided for @p2pTradeNotFoundRemovedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this trade. It might have been removed.'**
  String get p2pTradeNotFoundRemovedError;

  /// No description provided for @p2pAlreadyRatedTradeError.
  ///
  /// In en, this message translates to:
  /// **'You already rated this trade.'**
  String get p2pAlreadyRatedTradeError;

  /// No description provided for @p2pCreateProfileBeforeRatingError.
  ///
  /// In en, this message translates to:
  /// **'Please create your profile before leaving a rating.'**
  String get p2pCreateProfileBeforeRatingError;

  /// No description provided for @p2pRateAfterCompletedError.
  ///
  /// In en, this message translates to:
  /// **'You can rate once the trade is marked as completed.'**
  String get p2pRateAfterCompletedError;

  /// No description provided for @p2pRatingSubmitTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t submit your rating. Please try again.'**
  String get p2pRatingSubmitTryAgainError;

  /// No description provided for @p2pRatingSaveTryAgainSoonError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble saving your rating right now. Please try again shortly.'**
  String get p2pRatingSaveTryAgainSoonError;

  /// No description provided for @p2pTradeNotFoundOrNotParticipantError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find this trade or you’re not a participant.'**
  String get p2pTradeNotFoundOrNotParticipantError;

  /// No description provided for @p2pOpenDisputeAfterPaidError.
  ///
  /// In en, this message translates to:
  /// **'You can only open a dispute after marking this trade as paid.'**
  String get p2pOpenDisputeAfterPaidError;

  /// No description provided for @p2pTradeAlreadyInDisputeError.
  ///
  /// In en, this message translates to:
  /// **'This trade already has an open dispute.'**
  String get p2pTradeAlreadyInDisputeError;

  /// No description provided for @p2pOpenDisputeForTradeFailedError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open a dispute for this trade. Please try again.'**
  String get p2pOpenDisputeForTradeFailedError;

  /// No description provided for @p2pOpenDisputeTryAgainSoonError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble opening a dispute right now. Please try again shortly.'**
  String get p2pOpenDisputeTryAgainSoonError;

  /// No description provided for @p2pOpenDisputeTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t open a dispute right now. Please try again.'**
  String get p2pOpenDisputeTryAgainError;

  /// No description provided for @p2pNoPermissionPublishAdError.
  ///
  /// In en, this message translates to:
  /// **'You don’t have permission to publish this ad.'**
  String get p2pNoPermissionPublishAdError;

  /// No description provided for @p2pSelectedPaymentMethodUnavailableRefreshError.
  ///
  /// In en, this message translates to:
  /// **'One of the selected payment methods is no longer available. Refresh and try again.'**
  String get p2pSelectedPaymentMethodUnavailableRefreshError;

  /// No description provided for @p2pAdNoLongerAvailableRefreshError.
  ///
  /// In en, this message translates to:
  /// **'This ad is no longer available. Refresh and try again.'**
  String get p2pAdNoLongerAvailableRefreshError;

  /// No description provided for @p2pAddAtLeastOnePaymentMethodError.
  ///
  /// In en, this message translates to:
  /// **'Add at least one payment method.'**
  String get p2pAddAtLeastOnePaymentMethodError;

  /// No description provided for @p2pPaymentMethodsNotNeededBuyAdsError.
  ///
  /// In en, this message translates to:
  /// **'Payment methods aren’t needed for buy ads.'**
  String get p2pPaymentMethodsNotNeededBuyAdsError;

  /// No description provided for @p2pRemoveDuplicatePaymentMethodsError.
  ///
  /// In en, this message translates to:
  /// **'Remove duplicate payment methods before submitting.'**
  String get p2pRemoveDuplicatePaymentMethodsError;

  /// No description provided for @p2pPaymentProviderInactiveChooseAnotherError.
  ///
  /// In en, this message translates to:
  /// **'One of the payment providers is inactive right now. Please choose another option.'**
  String get p2pPaymentProviderInactiveChooseAnotherError;

  /// No description provided for @p2pPaymentMethodCurrencyMatchAdError.
  ///
  /// In en, this message translates to:
  /// **'Payment method currency must match your ad currency.'**
  String get p2pPaymentMethodCurrencyMatchAdError;

  /// No description provided for @p2pSelectedPaymentMethodsAnotherAccountError.
  ///
  /// In en, this message translates to:
  /// **'Selected payment methods belong to another account.'**
  String get p2pSelectedPaymentMethodsAnotherAccountError;

  /// No description provided for @p2pSelectedPaymentMethodsInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Selected payment methods are invalid for this ad.'**
  String get p2pSelectedPaymentMethodsInvalidError;

  /// No description provided for @p2pSellTotalExceedsBalanceError.
  ///
  /// In en, this message translates to:
  /// **'Your sell total exceeds your available balance.'**
  String get p2pSellTotalExceedsBalanceError;

  /// No description provided for @p2pInsufficientBalancePublishAdError.
  ///
  /// In en, this message translates to:
  /// **'You don’t have enough balance to publish this {adType} ad.'**
  String p2pInsufficientBalancePublishAdError(Object adType);

  /// No description provided for @p2pUseWholeNumbersAmountsError.
  ///
  /// In en, this message translates to:
  /// **'Use whole numbers when entering amounts.'**
  String get p2pUseWholeNumbersAmountsError;

  /// No description provided for @p2pReviewAmountsLimitsError.
  ///
  /// In en, this message translates to:
  /// **'Please review your amounts and limits.'**
  String get p2pReviewAmountsLimitsError;

  /// No description provided for @p2pTotalAmountAtLeastMinOrderError.
  ///
  /// In en, this message translates to:
  /// **'Total amount must be at least your minimum order.'**
  String get p2pTotalAmountAtLeastMinOrderError;

  /// No description provided for @p2pMaxOrderAtLeastMinOrderError.
  ///
  /// In en, this message translates to:
  /// **'Max order must be greater than or equal to the minimum order.'**
  String get p2pMaxOrderAtLeastMinOrderError;

  /// No description provided for @p2pEnterValidPriceRateError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price rate.'**
  String get p2pEnterValidPriceRateError;

  /// No description provided for @p2pInstructionsTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Instructions are too long (max 500 characters).'**
  String get p2pInstructionsTooLongError;

  /// No description provided for @p2pRequestTimedOutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get p2pRequestTimedOutError;

  /// No description provided for @p2pCreateAdFailedCheckInputError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create ad. Check your input and try again.'**
  String get p2pCreateAdFailedCheckInputError;

  /// No description provided for @p2pDisplayNameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Your display name must be between 3 and 50 characters.'**
  String get p2pDisplayNameLengthError;

  /// No description provided for @p2pUsernameFormatLengthError.
  ///
  /// In en, this message translates to:
  /// **'Your username can only contain letters, numbers, or underscores, and must be 3–30 characters long.'**
  String get p2pUsernameFormatLengthError;

  /// No description provided for @p2pBioTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Your bio is too long. Please keep it under 500 characters.'**
  String get p2pBioTooLongError;

  /// No description provided for @p2pSelectValidLanguageError.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid language.'**
  String get p2pSelectValidLanguageError;

  /// No description provided for @p2pSelectSupportedCurrencyError.
  ///
  /// In en, this message translates to:
  /// **'Please select a supported currency.'**
  String get p2pSelectSupportedCurrencyError;

  /// No description provided for @p2pDisplayNameUsernameTakenError.
  ///
  /// In en, this message translates to:
  /// **'That display name or username is already taken. Please choose another one.'**
  String get p2pDisplayNameUsernameTakenError;

  /// No description provided for @p2pProfileSaveTryAgainSoonError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble saving your profile right now. Please try again shortly.'**
  String get p2pProfileSaveTryAgainSoonError;

  /// No description provided for @p2pSessionExpiredSignInTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in and try again.'**
  String get p2pSessionExpiredSignInTryAgainError;

  /// No description provided for @p2pCannotTradeOwnAdError.
  ///
  /// In en, this message translates to:
  /// **'You can’t trade on your own ad.'**
  String get p2pCannotTradeOwnAdError;

  /// No description provided for @p2pAmountWithinAdLimitsError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount within the ad’s limits.'**
  String get p2pAmountWithinAdLimitsError;

  /// No description provided for @p2pSellerInsufficientAvailableError.
  ///
  /// In en, this message translates to:
  /// **'The seller doesn’t have enough available for that amount.'**
  String get p2pSellerInsufficientAvailableError;

  /// No description provided for @p2pSelectPaymentMethodOnAdError.
  ///
  /// In en, this message translates to:
  /// **'Select a payment method offered on this ad.'**
  String get p2pSelectPaymentMethodOnAdError;

  /// No description provided for @p2pBuyerNoSupportedPaymentMethodsError.
  ///
  /// In en, this message translates to:
  /// **'Buyer has not shared any supported payment methods yet.'**
  String get p2pBuyerNoSupportedPaymentMethodsError;

  /// No description provided for @p2pReserveFundsTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t reserve funds right now. Please try again.'**
  String get p2pReserveFundsTryAgainError;

  /// No description provided for @p2pStartTradeReviewInputError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t start this trade. Please review your input and try again.'**
  String get p2pStartTradeReviewInputError;

  /// No description provided for @p2pStartTradeTryAgainError.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t start this trade. Please try again.'**
  String get p2pStartTradeTryAgainError;

  /// No description provided for @p2pPleaseWaitLabel.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get p2pPleaseWaitLabel;

  /// No description provided for @p2pHowMuchUsdBuy.
  ///
  /// In en, this message translates to:
  /// **'How much USD do you want to buy?'**
  String get p2pHowMuchUsdBuy;

  /// No description provided for @p2pHowMuchUsdSell.
  ///
  /// In en, this message translates to:
  /// **'How much USD do you want to sell?'**
  String get p2pHowMuchUsdSell;

  /// No description provided for @p2pStatusDescriptionActiveTrade.
  ///
  /// In en, this message translates to:
  /// **'Active trade.'**
  String get p2pStatusDescriptionActiveTrade;

  /// No description provided for @p2pStatusDescriptionBuyerMarkedPaid.
  ///
  /// In en, this message translates to:
  /// **'Buyer marked the trade as paid. Review the proof before releasing the funds.'**
  String get p2pStatusDescriptionBuyerMarkedPaid;

  /// No description provided for @p2pStatusDescriptionReleasedBySeller.
  ///
  /// In en, this message translates to:
  /// **'You released this trade. Funds are on the way to the buyer.'**
  String get p2pStatusDescriptionReleasedBySeller;

  /// No description provided for @p2pStatusDescriptionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Trade completed successfully.'**
  String get p2pStatusDescriptionCompleted;

  /// No description provided for @p2pStatusDescriptionCancelled.
  ///
  /// In en, this message translates to:
  /// **'This trade was cancelled.'**
  String get p2pStatusDescriptionCancelled;

  /// No description provided for @p2pStatusDescriptionUnderReview.
  ///
  /// In en, this message translates to:
  /// **'This trade is under review.'**
  String get p2pStatusDescriptionUnderReview;

  /// No description provided for @p2pStatusDescriptionExpiredBeforeConfirm.
  ///
  /// In en, this message translates to:
  /// **'This trade expired before the buyer confirmed payment.'**
  String get p2pStatusDescriptionExpiredBeforeConfirm;

  /// No description provided for @p2pStatusDescriptionPaymentSent.
  ///
  /// In en, this message translates to:
  /// **'Payment sent. The seller has been notified. You’ll receive funds once they release the funds.'**
  String get p2pStatusDescriptionPaymentSent;

  /// No description provided for @p2pStatusDescriptionSellerConfirmedReleasing.
  ///
  /// In en, this message translates to:
  /// **'Seller confirmed payment. We’re releasing your funds shortly.'**
  String get p2pStatusDescriptionSellerConfirmedReleasing;

  /// No description provided for @p2pStatusDescriptionCompletedWalletUpdated.
  ///
  /// In en, this message translates to:
  /// **'Trade completed successfully. Funds should now reflect in your wallet.'**
  String get p2pStatusDescriptionCompletedWalletUpdated;

  /// No description provided for @p2pStatusDescriptionCancelledSupportHelp.
  ///
  /// In en, this message translates to:
  /// **'This trade was cancelled. Reach out to support if you need help.'**
  String get p2pStatusDescriptionCancelledSupportHelp;

  /// No description provided for @p2pStatusDescriptionUnderReviewTeamContact.
  ///
  /// In en, this message translates to:
  /// **'This trade is under review. Our team will contact you if more details are needed.'**
  String get p2pStatusDescriptionUnderReviewTeamContact;

  /// No description provided for @p2pFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get p2pFilterAll;

  /// No description provided for @p2pFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get p2pFilterPending;

  /// No description provided for @p2pFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get p2pFilterActive;

  /// No description provided for @p2pFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get p2pFilterInactive;

  /// No description provided for @p2pFilterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get p2pFilterCompleted;

  /// No description provided for @p2pFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get p2pFilterRejected;

  /// No description provided for @p2pFilterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get p2pFilterPaid;

  /// No description provided for @p2pFilterReleased.
  ///
  /// In en, this message translates to:
  /// **'Released'**
  String get p2pFilterReleased;

  /// No description provided for @p2pFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get p2pFilterCancelled;

  /// No description provided for @p2pFilterDisputed.
  ///
  /// In en, this message translates to:
  /// **'Disputed'**
  String get p2pFilterDisputed;

  /// No description provided for @p2pFilterExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get p2pFilterExpired;

  /// No description provided for @transactionsRangeLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get transactionsRangeLast30Days;

  /// No description provided for @transactionsRangeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get transactionsRangeLast7Days;

  /// No description provided for @transactionsRangeLast90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get transactionsRangeLast90Days;

  /// No description provided for @transactionsRangeLastNDays.
  ///
  /// In en, this message translates to:
  /// **'Last {days} days'**
  String transactionsRangeLastNDays(Object days);

  /// No description provided for @cryptoNetworkPolygonMatic.
  ///
  /// In en, this message translates to:
  /// **'Polygon (MATIC)'**
  String get cryptoNetworkPolygonMatic;

  /// No description provided for @cryptoNetworkEthereumErc20.
  ///
  /// In en, this message translates to:
  /// **'Ethereum (ERC-20)'**
  String get cryptoNetworkEthereumErc20;

  /// No description provided for @cryptoNetworkBscBep20.
  ///
  /// In en, this message translates to:
  /// **'BNB Smart Chain (BEP-20)'**
  String get cryptoNetworkBscBep20;

  /// No description provided for @cryptoNetworkTronTrc20.
  ///
  /// In en, this message translates to:
  /// **'Tron (TRC-20)'**
  String get cryptoNetworkTronTrc20;

  /// No description provided for @cryptoNetworkHintLowFeesFast.
  ///
  /// In en, this message translates to:
  /// **'Low fees • Fast'**
  String get cryptoNetworkHintLowFeesFast;

  /// No description provided for @cryptoNetworkHintHighFeesSecure.
  ///
  /// In en, this message translates to:
  /// **'High fees • Secure'**
  String get cryptoNetworkHintHighFeesSecure;

  /// No description provided for @cryptoNetworkHintVeryLowFeesFast.
  ///
  /// In en, this message translates to:
  /// **'Very low fees • Fast'**
  String get cryptoNetworkHintVeryLowFeesFast;

  /// No description provided for @cryptoNetworkShortPolygon.
  ///
  /// In en, this message translates to:
  /// **'Polygon'**
  String get cryptoNetworkShortPolygon;

  /// No description provided for @cryptoNetworkShortEthereum.
  ///
  /// In en, this message translates to:
  /// **'Ethereum'**
  String get cryptoNetworkShortEthereum;

  /// No description provided for @cryptoNetworkShortBsc.
  ///
  /// In en, this message translates to:
  /// **'BSC'**
  String get cryptoNetworkShortBsc;

  /// No description provided for @cryptoNetworkShortTron.
  ///
  /// In en, this message translates to:
  /// **'Tron'**
  String get cryptoNetworkShortTron;

  /// No description provided for @cryptoNetworkHintVeryLowFeesFastConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Very low fees • Fast confirmations'**
  String get cryptoNetworkHintVeryLowFeesFastConfirmations;

  /// No description provided for @cryptoNetworkHintLowFeesFastConfirmations.
  ///
  /// In en, this message translates to:
  /// **'Low fees • Fast confirmations'**
  String get cryptoNetworkHintLowFeesFastConfirmations;

  /// No description provided for @cryptoNetworkHintLowFeesBroadSupport.
  ///
  /// In en, this message translates to:
  /// **'Low fees • Broad support'**
  String get cryptoNetworkHintLowFeesBroadSupport;

  /// No description provided for @cryptoNetworkHintHighFeesMostCompatible.
  ///
  /// In en, this message translates to:
  /// **'High fees • Most compatible'**
  String get cryptoNetworkHintHighFeesMostCompatible;

  /// No description provided for @notProvidedLabel.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvidedLabel;

  /// No description provided for @withdrawTrc20LengthError.
  ///
  /// In en, this message translates to:
  /// **'TRC-20 addresses must be exactly 34 characters long.'**
  String get withdrawTrc20LengthError;

  /// No description provided for @withdrawTrc20StartWithTError.
  ///
  /// In en, this message translates to:
  /// **'TRC-20 addresses must start with the letter T.'**
  String get withdrawTrc20StartWithTError;

  /// No description provided for @withdrawTrc20Base58Error.
  ///
  /// In en, this message translates to:
  /// **'TRC-20 addresses use Base58 characters only.'**
  String get withdrawTrc20Base58Error;

  /// No description provided for @withdrawNetworkAddressStartsWith0xError.
  ///
  /// In en, this message translates to:
  /// **'This network requires addresses that start with 0x.'**
  String get withdrawNetworkAddressStartsWith0xError;

  /// No description provided for @withdrawAddressLength42Error.
  ///
  /// In en, this message translates to:
  /// **'This address must be exactly 42 characters long.'**
  String get withdrawAddressLength42Error;

  /// No description provided for @withdrawHexCharactersOnlyError.
  ///
  /// In en, this message translates to:
  /// **'Use hexadecimal characters only (0-9, a-f).'**
  String get withdrawHexCharactersOnlyError;

  /// No description provided for @sendMoneyRecipientRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please select a recipient first.'**
  String get sendMoneyRecipientRequiredError;

  /// No description provided for @sendMoneyInvalidTransferDetailsError.
  ///
  /// In en, this message translates to:
  /// **'Invalid transfer details.'**
  String get sendMoneyInvalidTransferDetailsError;

  /// No description provided for @sendMoneyTransferToDescription.
  ///
  /// In en, this message translates to:
  /// **'Transfer to {recipientName}'**
  String sendMoneyTransferToDescription(Object recipientName);

  /// No description provided for @forgotPinCodeSentIfAccountExists.
  ///
  /// In en, this message translates to:
  /// **'If an account exists, we sent a verification code to your email'**
  String get forgotPinCodeSentIfAccountExists;

  /// No description provided for @resetPinCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Verification code is required'**
  String get resetPinCodeRequiredError;

  /// No description provided for @resetPinCodeMustBeSixDigitsError.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 digits'**
  String get resetPinCodeMustBeSixDigitsError;

  /// No description provided for @resetPinConfirmRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your PIN'**
  String get resetPinConfirmRequiredError;

  /// No description provided for @resetPinMismatchError.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get resetPinMismatchError;

  /// No description provided for @verifyEmailFailedToSendCodeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code'**
  String get verifyEmailFailedToSendCodeError;

  /// No description provided for @verifyEmailInvalidOrExpiredCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code'**
  String get verifyEmailInvalidOrExpiredCodeError;

  /// No description provided for @verifyEmailUserNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get verifyEmailUserNotFoundError;

  /// No description provided for @verifyEmailServerErrorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Server error. Try again'**
  String get verifyEmailServerErrorTryAgain;

  /// No description provided for @verifyEmailUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred'**
  String get verifyEmailUnexpectedError;

  /// No description provided for @verifyEmailFailedToResendCodeError.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code'**
  String get verifyEmailFailedToResendCodeError;

  /// No description provided for @quickAuthSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get quickAuthSessionExpiredError;

  /// No description provided for @quickAuthNoInternetError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network and try again.'**
  String get quickAuthNoInternetError;

  /// No description provided for @quickAuthAuthenticationFailedError.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please log in again.'**
  String get quickAuthAuthenticationFailedError;

  /// No description provided for @quickAuthBiometricPromptReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Opei with biometric'**
  String get quickAuthBiometricPromptReason;

  /// No description provided for @quickAuthBiometricFailedError.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get quickAuthBiometricFailedError;

  /// No description provided for @quickAuthLoggedOutCreateNewPinInfo.
  ///
  /// In en, this message translates to:
  /// **'Logged out. Please sign in to create a new PIN.'**
  String get quickAuthLoggedOutCreateNewPinInfo;

  /// No description provided for @quickAuthInvalidPinOneAttemptRemaining.
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN. 1 attempt remaining.'**
  String get quickAuthInvalidPinOneAttemptRemaining;

  /// No description provided for @quickAuthInvalidPinAttemptsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN. {attempts} attempts remaining.'**
  String quickAuthInvalidPinAttemptsRemaining(Object attempts);

  /// No description provided for @quickAuthTooManyPinAttemptsError.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect PIN attempts. Please log in again to set a new PIN.'**
  String get quickAuthTooManyPinAttemptsError;

  /// No description provided for @quickAuthSetupNoActiveUserError.
  ///
  /// In en, this message translates to:
  /// **'No active user context available for quick auth setup'**
  String get quickAuthSetupNoActiveUserError;

  /// No description provided for @quickAuthSetupPinSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN setup complete'**
  String get quickAuthSetupPinSavedSuccess;

  /// No description provided for @quickAuthSetupPinSaveFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save PIN. Please try again.'**
  String get quickAuthSetupPinSaveFailedError;

  /// No description provided for @quickAuthSetupBiometricUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get quickAuthSetupBiometricUnavailableError;

  /// No description provided for @quickAuthSetupBiometricPromptReason.
  ///
  /// In en, this message translates to:
  /// **'Set up biometric authentication for quick access'**
  String get quickAuthSetupBiometricPromptReason;

  /// No description provided for @quickAuthSetupBiometricEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled'**
  String get quickAuthSetupBiometricEnabledSuccess;

  /// No description provided for @quickAuthSetupBiometricEnableFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to enable biometric authentication'**
  String get quickAuthSetupBiometricEnableFailedError;

  /// No description provided for @quickAuthSetupConfirmPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get quickAuthSetupConfirmPinTitle;

  /// No description provided for @quickAuthSetupCreatePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Create PIN'**
  String get quickAuthSetupCreatePinTitle;

  /// No description provided for @quickAuthSetupConfirmPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN again to confirm'**
  String get quickAuthSetupConfirmPinSubtitle;

  /// No description provided for @quickAuthSetupCreatePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a 6-digit PIN to sign in faster'**
  String get quickAuthSetupCreatePinSubtitle;

  /// No description provided for @kycSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get kycSessionExpiredError;

  /// No description provided for @kycVerificationAlreadyCompleteError.
  ///
  /// In en, this message translates to:
  /// **'Verification already complete!'**
  String get kycVerificationAlreadyCompleteError;

  /// No description provided for @kycVerificationUnderReviewError.
  ///
  /// In en, this message translates to:
  /// **'Your verification is under review. Please check back later.'**
  String get kycVerificationUnderReviewError;

  /// No description provided for @kycAddressRequiredBeforeVerificationError.
  ///
  /// In en, this message translates to:
  /// **'Please complete your address information first.'**
  String get kycAddressRequiredBeforeVerificationError;

  /// No description provided for @kycAccountSuspendedError.
  ///
  /// In en, this message translates to:
  /// **'Account suspended. Please contact support.'**
  String get kycAccountSuspendedError;

  /// No description provided for @kycAccountNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Account not found. Please log in again.'**
  String get kycAccountNotFoundError;

  /// No description provided for @kycServiceUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable. Please try again later.'**
  String get kycServiceUnavailableError;

  /// No description provided for @cardsTransactionsSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get cardsTransactionsSessionExpiredError;

  /// No description provided for @cardsCardNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this card.'**
  String get cardsCardNotFoundError;

  /// No description provided for @cardsTransactionsLoadTryAgainSoonError.
  ///
  /// In en, this message translates to:
  /// **'We\'re having trouble loading your transactions. Please try again soon.'**
  String get cardsTransactionsLoadTryAgainSoonError;

  /// No description provided for @expressSetupSelectCurrencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Select currency'**
  String get expressSetupSelectCurrencyTitle;

  /// No description provided for @expressSetupPaymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get expressSetupPaymentMethodTitle;

  /// No description provided for @expressSetupEnterAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get expressSetupEnterAmountTitle;

  /// No description provided for @expressSetupCurrencyHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the local currency you will be paying in.'**
  String get expressSetupCurrencyHint;

  /// No description provided for @expressSetupReviewDepositCta.
  ///
  /// In en, this message translates to:
  /// **'Review deposit'**
  String get expressSetupReviewDepositCta;

  /// No description provided for @expressPreviewQuoteUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get a quote'**
  String get expressPreviewQuoteUnavailableTitle;

  /// No description provided for @expressOrderAcceptedToast.
  ///
  /// In en, this message translates to:
  /// **'Order accepted. Find it under \"My queue\".'**
  String get expressOrderAcceptedToast;

  /// No description provided for @expressSectionActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get expressSectionActive;

  /// No description provided for @expressSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get expressSectionHistory;

  /// No description provided for @mobileMoneyDescriptionMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Enter a clear description (at least 3 characters).'**
  String get mobileMoneyDescriptionMinLengthError;

  /// No description provided for @mobileMoneyDescriptionMaxLengthError.
  ///
  /// In en, this message translates to:
  /// **'Description is too long (max 120 characters).'**
  String get mobileMoneyDescriptionMaxLengthError;

  /// No description provided for @mobileMoneyMissingReviewOrSessionError.
  ///
  /// In en, this message translates to:
  /// **'Missing review or session. Please try again.'**
  String get mobileMoneyMissingReviewOrSessionError;

  /// No description provided for @mobileMoneyAddValidDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Please go back and add a valid description.'**
  String get mobileMoneyAddValidDescriptionError;

  /// No description provided for @mobileMoneyDescriptionTooLong120Error.
  ///
  /// In en, this message translates to:
  /// **'Description is too long. Use 120 characters or less.'**
  String get mobileMoneyDescriptionTooLong120Error;

  /// No description provided for @trustFooterBankGradeEncryption.
  ///
  /// In en, this message translates to:
  /// **'Bank-grade encryption'**
  String get trustFooterBankGradeEncryption;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
