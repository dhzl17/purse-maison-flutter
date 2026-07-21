import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Backed by Firestore collection `salesTransactions/{id}`.
class SalesTransaction {
  final String id;
  final String itemLabel;
  final double amount;
  final DateTime date;

  final String? itemId;

  const SalesTransaction({
    this.id = '',
    required this.itemLabel,
    required this.amount,
    required this.date,
    this.itemId,
  });

  factory SalesTransaction.fromMap(String id, Map<String, dynamic> map) {
    final rawDate = map['date'];
    return SalesTransaction(
      id: id,
      itemLabel: map['itemLabel'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: rawDate is Timestamp ? rawDate.toDate() : DateTime.now(),
      itemId: map['itemId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemLabel': itemLabel,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'itemId': itemId,
    };
  }
}
