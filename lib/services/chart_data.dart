import '../models/sales_transaction.dart';

/// Shared helpers for turning raw Firestore data into the small,
/// chart-ready shapes the various chart widgets need (dashboard_charts,
/// inventory_charts, sales_forecast_charts). Kept here instead of
/// duplicated per-page since "last 6 months" bucketing is needed in
/// three different places.

const _monthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// One month bucket: a short label plus the year/month it represents, so
/// callers can match real dates against it.
class ChartMonth {
  final String label;
  final int year;
  final int month;
  const ChartMonth(this.label, this.year, this.month);
}

/// The last [n] months (oldest first), ending at the current month.
List<ChartMonth> lastNMonths(int n) {
  final now = DateTime.now();
  return [
    for (int i = n - 1; i >= 0; i--)
      () {
        // DateTime normalizes a month argument outside 1-12 for us, so
        // "month 0" correctly rolls back into the prior year.
        final d = DateTime(now.year, now.month - i);
        return ChartMonth(_monthAbbrev[d.month - 1], d.year, d.month);
      }(),
  ];
}

/// Total transaction amount per month bucket, aligned 1:1 with [months].
List<double> monthlySalesTotals(
  List<SalesTransaction> transactions,
  List<ChartMonth> months,
) {
  return [
    for (final m in months)
      transactions
          .where((t) => t.date.year == m.year && t.date.month == m.month)
          .fold(0.0, (sum, t) => sum + t.amount),
  ];
}

/// Count of transactions per month bucket, aligned 1:1 with [months] —
/// i.e. how many items sold that month.
List<int> monthlySoldCounts(
  List<SalesTransaction> transactions,
  List<ChartMonth> months,
) {
  return [
    for (final m in months)
      transactions
          .where((t) => t.date.year == m.year && t.date.month == m.month)
          .length,
  ];
}

/// Strips currency symbols/commas from a string like "₱720,000" or
/// "4,850,000" down to a plain number. Falls back to 0.
double parseAmountString(String s) {
  final digitsOnly = s.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(digitsOnly) ?? 0;
}
