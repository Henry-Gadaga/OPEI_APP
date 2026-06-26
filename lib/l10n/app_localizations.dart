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

  /// No description provided for @addressAptSuiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Apt / Suite'**
  String get addressAptSuiteLabel;

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

  /// No description provided for @addressStateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get addressStateLabel;

  /// No description provided for @addressBvnLabel.
  ///
  /// In en, this message translates to:
  /// **'BVN'**
  String get addressBvnLabel;

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
  /// **'Submit Rating'**
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

  /// No description provided for @p2pCouldNotLoadAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t load your ads'**
  String get p2pCouldNotLoadAdsTitle;

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
