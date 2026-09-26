import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/l10n/generated/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  test(
    'English localization supports parameters, plurals, and formats',
    () async {
      await initializeDateFormatting('en');
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(l10n.environmentLabel('dev'), 'Environment: dev');
      expect(l10n.showcaseGreeting('Alex'), 'Hello, Alex!');
      expect(l10n.sampleItemCount(0), 'No sample items');
      expect(l10n.sampleItemCount(1), '1 sample item');
      expect(l10n.sampleItemCount(2), '2 sample items');
      expect(
        l10n.showcaseDate(DateTime(2026, 9, 26)),
        contains('Sep 26, 2026'),
      );
      final time = l10n.showcaseTime(DateTime(2026, 9, 26, 14, 30));
      expect(time, contains('2:30'));
      expect(time, contains('PM'));
      expect(l10n.showcaseNumber(12345.67), contains('12,345.67'));
      expect(l10n.showcaseCurrency(1234.5), contains('1,234.50'));
    },
  );
}
