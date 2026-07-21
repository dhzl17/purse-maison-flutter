import '../models/sales_transaction.dart';


const _monthAbbrev = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

class ChartMonth {
  final String label;
  final int year;
  final int month;
  const ChartMonth(this.label, this.year, this.month);
}

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

double parseAmountString(String s) {
  final digitsOnly = s.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(digitsOnly) ?? 0;
}
