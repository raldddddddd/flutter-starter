// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredMessage =>
      'This version is no longer supported. Update the app to continue.';

  @override
  String environmentLabel(String environment) {
    return 'Environment: $environment';
  }

  @override
  String get sampleItemsTitle => 'Sample items';

  @override
  String get componentShowcaseTitle => 'Component Showcase';

  @override
  String get signInNotConfigured => 'Sign in is not configured yet.';

  @override
  String get openSampleDemo => 'Open sample demo';

  @override
  String get sampleDemoError => 'Unable to start the sample demo.';

  @override
  String get refreshSampleItems => 'Refresh sample items';

  @override
  String get sampleItemsUpToDate => 'Sample items are up to date.';

  @override
  String get sampleItemAdded => 'Sample item added.';

  @override
  String get addSampleItem => 'Add sample item';

  @override
  String get newSampleItem => 'New sample item';

  @override
  String get offlineSessionNotice => 'Offline session: showing local data';

  @override
  String get cachedRefreshError => 'Refresh failed. Showing cached items.';

  @override
  String get loadingSampleItems => 'Loading sample items';

  @override
  String get loadSampleItemsError => 'Unable to load sample items';

  @override
  String get tryRefreshingAgain => 'Try refreshing again.';

  @override
  String get noSampleItems => 'No sample items yet';

  @override
  String sampleItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sample items',
      one: '1 sample item',
      zero: 'No sample items',
    );
    return '$_temp0';
  }

  @override
  String get loading => 'Loading';

  @override
  String get empty => 'Empty';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get failureConnection =>
      'Couldn\'t connect. Check your connection and try again.';

  @override
  String get failureTimeout => 'The request timed out. Try again.';

  @override
  String get failureNetworkUnavailable =>
      'The service is unavailable. Try again later.';

  @override
  String get failureAuthentication => 'Your session has ended. Sign in again.';

  @override
  String get failureAuthorization => 'You don\'t have access to this content.';

  @override
  String get failureValidation => 'Check the information and try again.';

  @override
  String get failureNotFound => 'This content is no longer available.';

  @override
  String get failureConflict => 'This content changed. Refresh and try again.';

  @override
  String get failureServer =>
      'The server couldn\'t complete the request. Try again.';

  @override
  String get failureStorage => 'Local data couldn\'t be loaded. Try again.';

  @override
  String get failureUnexpected => 'Something went wrong. Try again.';

  @override
  String get showcaseDarkTheme => 'Dark theme';

  @override
  String get showcaseLargeText => 'Large text (180%)';

  @override
  String get showcaseSemanticColors => 'Semantic colors';

  @override
  String get showcasePrimaryColor => 'Primary';

  @override
  String get showcaseSecondaryColor => 'Secondary';

  @override
  String get showcaseSurfaceColor => 'Surface';

  @override
  String get showcaseErrorColor => 'Error';

  @override
  String get showcaseTypography => 'Typography';

  @override
  String get showcaseDisplaySmall => 'Display small';

  @override
  String get showcaseTitleLarge => 'Title large';

  @override
  String get showcaseBodyLarge => 'Body large';

  @override
  String get showcaseLabelLarge => 'Label large';

  @override
  String get showcaseSpacingRadius => 'Spacing and radius';

  @override
  String get showcaseButtons => 'Buttons';

  @override
  String get showcasePrimaryButton => 'Primary';

  @override
  String get showcaseSecondaryButton => 'Secondary';

  @override
  String get showcaseTextButton => 'Text';

  @override
  String get showcaseDisabledButton => 'Disabled';

  @override
  String get showcaseLoadingButton => 'Loading';

  @override
  String get showcaseTextInput => 'Text input';

  @override
  String get showcaseName => 'Name';

  @override
  String get showcaseNameHint => 'Enter a name';

  @override
  String get showcaseDisabledInput => 'Disabled input';

  @override
  String get showcaseCardLongCopy => 'Card and long copy';

  @override
  String get showcaseLongCopy =>
      'This is intentionally long copy. It demonstrates how the starter card and typography respond when content wraps across several lines, the screen is narrow, or the reader chooses a much larger text size.';

  @override
  String get showcaseLoadingState => 'Loading state';

  @override
  String get showcaseLoadingContent => 'Loading content';

  @override
  String get showcaseEmptyState => 'Empty state';

  @override
  String get showcaseNothingHere => 'Nothing here yet';

  @override
  String get showcaseNewContent =>
      'New content will appear here when available.';

  @override
  String get showcaseErrorState => 'Error state';

  @override
  String get showcaseCouldNotLoad => 'Could not load content';

  @override
  String get showcaseCheckConnection => 'Check your connection and try again.';

  @override
  String get showcaseFormatting => 'Localized formatting';

  @override
  String showcaseGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String showcaseDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Date: $dateString';
  }

  @override
  String showcaseTime(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.jm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Time: $timeString';
  }

  @override
  String showcaseNumber(num number) {
    final intl.NumberFormat numberNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String numberString = numberNumberFormat.format(number);

    return 'Number: $numberString';
  }

  @override
  String showcaseCurrency(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
    );
    final String amountString = amountNumberFormat.format(amount);

    return 'Currency: $amountString';
  }
}
