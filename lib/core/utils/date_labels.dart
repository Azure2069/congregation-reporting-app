/// Small, dependency-free date labels used throughout the reporting UI.
/// Keeping these labels here avoids raw DateTime strings and mismatched formats.
class DateLabels {
  const DateLabels._();

  static const _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String monthYear(DateTime date) =>
      '${_months[date.month - 1]} ${date.year}';

  static String shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  static String dateTime(DateTime date) =>
      '${shortDate(date)} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  static DateTime currentReportingMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }
}
