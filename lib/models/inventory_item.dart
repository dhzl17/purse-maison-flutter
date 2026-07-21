/// Stock status for an inventory item.
enum InventoryStatus { available, reserved, rejected, sold }

/// Transaction state tied to an inventory item, if any.
enum TransactionStatus { none, pending, cancelled, completed }

/// A single row of data for the Inventory Management table.
///
/// Backed by Firestore collection `inventory/{itemId}` — see
/// FirestoreCollections.inventory in services/firestore_paths.dart.
class InventoryItem {
  final String itemId;
  final String brand;
  final String category;
  final String condition;
  final InventoryStatus status;
  final String location;
  final String dateAdded;
  final TransactionStatus transactionStatus;
  final String price;

  const InventoryItem({
    required this.itemId,
    required this.brand,
    required this.category,
    required this.condition,
    required this.status,
    required this.location,
    required this.dateAdded,
    required this.transactionStatus,
    required this.price,
  });

  factory InventoryItem.fromMap(String id, Map<String, dynamic> map) {
    return InventoryItem(
      itemId: id,
      brand: map['brand'] as String? ?? '',
      category: map['category'] as String? ?? '',
      condition: map['condition'] as String? ?? '',
      status: InventoryStatus.values.byName(
        map['status'] as String? ?? 'available',
      ),
      location: map['location'] as String? ?? '',
      dateAdded: map['dateAdded'] as String? ?? '',
      transactionStatus: TransactionStatus.values.byName(
        map['transactionStatus'] as String? ?? 'none',
      ),
      price: map['price'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'category': category,
      'condition': condition,
      'status': status.name,
      'location': location,
      'dateAdded': dateAdded,
      'transactionStatus': transactionStatus.name,
      'price': price,
    };
  }

  InventoryItem copyWith({
    String? brand,
    String? category,
    String? condition,
    InventoryStatus? status,
    String? location,
    String? dateAdded,
    TransactionStatus? transactionStatus,
    String? price,
  }) {
    return InventoryItem(
      itemId: itemId,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      location: location ?? this.location,
      dateAdded: dateAdded ?? this.dateAdded,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      price: price ?? this.price,
    );
  }
}
