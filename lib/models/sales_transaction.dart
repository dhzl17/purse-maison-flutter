import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// A single completed sale, logged automatically whenever an inventory
/// item's status is changed to "Sold" (see inventory_item_dialog.dart).
/// This is what the Dashboard's "Total Sales", "Monthly Sales Growth",
/// "Average Display Duration", and "Fast/Slow Moving Items" cards are all
/// computed from — see dashboard_page.dart.
///
/// Backed by Firestore collection `salesTransactions/{id}`.
class SalesTransaction {
  final String id;
  final String itemLabel;
  final double amount;
  final DateTime date;

  /// The inventory item this sale came from, if it's still traceable
  /// (the inventory doc itself isn't deleted when sold — see
  /// inventory_item_dialog.dart). Used to look up how long that item sat
  /// in inventory before this sale, via its `dateAdded`. Null for sales
  /// that don't have (or no longer have) a matching inventory doc — those
  /// still count toward Total Sales, just not display-duration stats.
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
