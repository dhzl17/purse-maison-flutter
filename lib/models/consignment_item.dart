
enum AuthenticationStatus { verified, rejected }

enum PayoutStatus { notYetSold, sold, cancelled }

class ConsignmentItem {
  final String itemId;
  final String brand;
  final String itemName;
  final String imagePath;
  final String category;
  final String condition;
  final AuthenticationStatus authentication;
  final String status;
  final String price;
  final PayoutStatus payoutStatus;

  const ConsignmentItem({
    required this.itemId,
    required this.brand,
    required this.itemName,
    required this.imagePath,
    required this.category,
    required this.condition,
    required this.authentication,
    required this.status,
    required this.price,
    required this.payoutStatus,
  });

  factory ConsignmentItem.fromMap(String id, Map<String, dynamic> map) {
    return ConsignmentItem(
      itemId: id,
      brand: map['brand'] as String? ?? '',
      itemName: map['itemName'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '',
      category: map['category'] as String? ?? '',
      condition: map['condition'] as String? ?? '',
      authentication: AuthenticationStatus.values.byName(
        map['authentication'] as String? ?? 'verified',
      ),
      status: map['status'] as String? ?? '',
      price: map['price'] as String? ?? '',
      payoutStatus: PayoutStatus.values.byName(
        map['payoutStatus'] as String? ?? 'notYetSold',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'itemName': itemName,
      'imagePath': imagePath,
      'category': category,
      'condition': condition,
      'authentication': authentication.name,
      'status': status,
      'price': price,
      'payoutStatus': payoutStatus.name,
    };
  }
}
