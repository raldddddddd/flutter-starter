import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Starter'**
  String get appTitle;

  /// No description provided for @environmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Environment: {environment}'**
  String environmentLabel(String environment);

  /// No description provided for @sampleItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample items'**
  String get sampleItemsTitle;

  /// No description provided for @componentShowcaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Component Showcase'**
  String get componentShowcaseTitle;

  /// No description provided for @signInNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Sign in is not configured yet.'**
  String get signInNotConfigured;

  /// No description provided for @openSampleDemo.
  ///
  /// In en, this message translates to:
  /// **'Open sample demo'**
  String get openSampleDemo;

  /// No description provided for @sampleDemoError.
  ///
  /// In en, this message translates to:
  /// **'Unable to start the sample demo.'**
  String get sampleDemoError;

  /// No description provided for @refreshSampleItems.
  ///
  /// In en, this message translates to:
  /// **'Refresh sample items'**
  String get refreshSampleItems;

  /// No description provided for @sampleItemsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Sample items are up to date.'**
  String get sampleItemsUpToDate;

  /// No description provided for @sampleItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Sample item added.'**
  String get sampleItemAdded;

  /// No description provided for @addSampleItem.
  ///
  /// In en, this message translates to:
  /// **'Add sample item'**
  String get addSampleItem;

  /// No description provided for @newSampleItem.
  ///
  /// In en, this message translates to:
  /// **'New sample item'**
  String get newSampleItem;

  /// No description provided for @offlineSessionNotice.
  ///
  /// In en, this message translates to:
  /// **'Offline session: showing local data'**
  String get offlineSessionNotice;

  /// No description provided for @cachedRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Refresh failed. Showing cached items.'**
  String get cachedRefreshError;

  /// No description provided for @loadingSampleItems.
  ///
  /// In en, this message translates to:
  /// **'Loading sample items'**
  String get loadingSampleItems;

  /// No description provided for @loadSampleItemsError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sample items'**
  String get loadSampleItemsError;

  /// No description provided for @tryRefreshingAgain.
  ///
  /// In en, this message translates to:
  /// **'Try refreshing again.'**
  String get tryRefreshingAgain;

  /// No description provided for @noSampleItems.
  ///
  /// In en, this message translates to:
  /// **'No sample items yet'**
  String get noSampleItems;

  /// No description provided for @sampleItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sample items} =1{1 sample item} other{{count} sample items}}'**
  String sampleItemCount(int count);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @failureConnection.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t connect. Check your connection and try again.'**
  String get failureConnection;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Try again.'**
  String get failureTimeout;

  /// No description provided for @failureNetworkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The service is unavailable. Try again later.'**
  String get failureNetworkUnavailable;

  /// No description provided for @failureAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Sign in again.'**
  String get failureAuthentication;

  /// No description provided for @failureAuthorization.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this content.'**
  String get failureAuthorization;

  /// No description provided for @failureValidation.
  ///
  /// In en, this message translates to:
  /// **'Check the information and try again.'**
  String get failureValidation;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'This content is no longer available.'**
  String get failureNotFound;

  /// No description provided for @failureConflict.
  ///
  /// In en, this message translates to:
  /// **'This content changed. Refresh and try again.'**
  String get failureConflict;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'The server couldn\'t complete the request. Try again.'**
  String get failureServer;

  /// No description provided for @failureStorage.
  ///
  /// In en, this message translates to:
  /// **'Local data couldn\'t be loaded. Try again.'**
  String get failureStorage;

  /// No description provided for @failureUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get failureUnexpected;

  /// No description provided for @showcaseDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get showcaseDarkTheme;

  /// No description provided for @showcaseLargeText.
  ///
  /// In en, this message translates to:
  /// **'Large text (180%)'**
  String get showcaseLargeText;

  /// No description provided for @showcaseSemanticColors.
  ///
  /// In en, this message translates to:
  /// **'Semantic colors'**
  String get showcaseSemanticColors;

  /// No description provided for @showcasePrimaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get showcasePrimaryColor;

  /// No description provided for @showcaseSecondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get showcaseSecondaryColor;

  /// No description provided for @showcaseSurfaceColor.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get showcaseSurfaceColor;

  /// No description provided for @showcaseErrorColor.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get showcaseErrorColor;

  /// No description provided for @showcaseTypography.
  ///
  /// In en, this message translates to:
  /// **'Typography'**
  String get showcaseTypography;

  /// No description provided for @showcaseDisplaySmall.
  ///
  /// In en, this message translates to:
  /// **'Display small'**
  String get showcaseDisplaySmall;

  /// No description provided for @showcaseTitleLarge.
  ///
  /// In en, this message translates to:
  /// **'Title large'**
  String get showcaseTitleLarge;

  /// No description provided for @showcaseBodyLarge.
  ///
  /// In en, this message translates to:
  /// **'Body large'**
  String get showcaseBodyLarge;

  /// No description provided for @showcaseLabelLarge.
  ///
  /// In en, this message translates to:
  /// **'Label large'**
  String get showcaseLabelLarge;

  /// No description provided for @showcaseSpacingRadius.
  ///
  /// In en, this message translates to:
  /// **'Spacing and radius'**
  String get showcaseSpacingRadius;

  /// No description provided for @showcaseButtons.
  ///
  /// In en, this message translates to:
  /// **'Buttons'**
  String get showcaseButtons;

  /// No description provided for @showcasePrimaryButton.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get showcasePrimaryButton;

  /// No description provided for @showcaseSecondaryButton.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get showcaseSecondaryButton;

  /// No description provided for @showcaseTextButton.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get showcaseTextButton;

  /// No description provided for @showcaseDisabledButton.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get showcaseDisabledButton;

  /// No description provided for @showcaseLoadingButton.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get showcaseLoadingButton;

  /// No description provided for @showcaseTextInput.
  ///
  /// In en, this message translates to:
  /// **'Text input'**
  String get showcaseTextInput;

  /// No description provided for @showcaseName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get showcaseName;

  /// No description provided for @showcaseNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get showcaseNameHint;

  /// No description provided for @showcaseDisabledInput.
  ///
  /// In en, this message translates to:
  /// **'Disabled input'**
  String get showcaseDisabledInput;

  /// No description provided for @showcaseCardLongCopy.
  ///
  /// In en, this message translates to:
  /// **'Card and long copy'**
  String get showcaseCardLongCopy;

  /// No description provided for @showcaseLongCopy.
  ///
  /// In en, this message translates to:
  /// **'This is intentionally long copy. It demonstrates how the starter card and typography respond when content wraps across several lines, the screen is narrow, or the reader chooses a much larger text size.'**
  String get showcaseLongCopy;

  /// No description provided for @showcaseLoadingState.
  ///
  /// In en, this message translates to:
  /// **'Loading state'**
  String get showcaseLoadingState;

  /// No description provided for @showcaseLoadingContent.
  ///
  /// In en, this message translates to:
  /// **'Loading content'**
  String get showcaseLoadingContent;

  /// No description provided for @showcaseEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Empty state'**
  String get showcaseEmptyState;

  /// No description provided for @showcaseNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get showcaseNothingHere;

  /// No description provided for @showcaseNewContent.
  ///
  /// In en, this message translates to:
  /// **'New content will appear here when available.'**
  String get showcaseNewContent;

  /// No description provided for @showcaseErrorState.
  ///
  /// In en, this message translates to:
  /// **'Error state'**
  String get showcaseErrorState;

  /// No description provided for @showcaseCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load content'**
  String get showcaseCouldNotLoad;

  /// No description provided for @showcaseCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get showcaseCheckConnection;

  /// No description provided for @showcaseFormatting.
  ///
  /// In en, this message translates to:
  /// **'Localized formatting'**
  String get showcaseFormatting;

  /// No description provided for @showcaseGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String showcaseGreeting(String name);

  /// No description provided for @showcaseDate.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String showcaseDate(DateTime date);

  /// No description provided for @showcaseTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String showcaseTime(DateTime time);

  /// No description provided for @showcaseNumber.
  ///
  /// In en, this message translates to:
  /// **'Number: {number}'**
  String showcaseNumber(num number);

  /// No description provided for @showcaseCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency: {amount}'**
  String showcaseCurrency(double amount);
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
