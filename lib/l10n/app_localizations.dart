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
