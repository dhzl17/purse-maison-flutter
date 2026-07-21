import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;

enum InquiryStatus { newInquiry, closed, followedUp, reserved }

enum TransactionResult { none, noPurchase, purchased }

enum AssociateStatus { assigned, available }

class ClientInquiry {
  final String id;
  final int no;
  final String clientName;
  final String clientType; // Walk-in, VIP
  final String clientRole; // Buyer, Consignor
  final InquiryStatus inquiryStatus;
  final String inquirySource; // Facebook, Tiktok, Instagram, ...
  final TransactionResult transactionResult;

  const ClientInquiry({
    this.id = '',
    required this.no,
    required this.clientName,
    required this.clientType,
    required this.clientRole,
    required this.inquiryStatus,
    required this.inquirySource,
    required this.transactionResult,
  });

  factory ClientInquiry.fromMap(String id, Map<String, dynamic> map) {
    return ClientInquiry(
      id: id,
      no: (map['no'] as num?)?.toInt() ?? 0,
      clientName: map['clientName'] as String? ?? '',
      clientType: map['clientType'] as String? ?? '',
      clientRole: map['clientRole'] as String? ?? '',
      inquiryStatus: InquiryStatus.values.byName(
        map['inquiryStatus'] as String? ?? 'newInquiry',
      ),
      inquirySource: map['inquirySource'] as String? ?? '',
      transactionResult: TransactionResult.values.byName(
        map['transactionResult'] as String? ?? 'none',
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'no': no,
      'clientName': clientName,
      'clientType': clientType,
      'clientRole': clientRole,
      'inquiryStatus': inquiryStatus.name,
      'inquirySource': inquirySource,
      'transactionResult': transactionResult.name,
    };
  }
}

class SalesAssociateAssignment {
  final String id;
  final String associateName;
  final AssociateStatus status;
  final String currentClient; // '-' when the associate has no current client

  const SalesAssociateAssignment({
    this.id = '',
    required this.associateName,
    required this.status,
    required this.currentClient,
  });

  factory SalesAssociateAssignment.fromMap(String id, Map<String, dynamic> map) {
    return SalesAssociateAssignment(
      id: id,
      associateName: map['associateName'] as String? ?? '',
      status: AssociateStatus.values.byName(
        map['status'] as String? ?? 'available',
      ),
      currentClient: map['currentClient'] as String? ?? '-',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'associateName': associateName,
      'status': status.name,
      'currentClient': currentClient,
    };
  }
}

class FeedEntryRecord {
  final String id;
  final String description;
  final String timestamp;

  const FeedEntryRecord({
    this.id = '',
    required this.description,
    required this.timestamp,
  });

  factory FeedEntryRecord.fromMap(String id, Map<String, dynamic> map) {
    return FeedEntryRecord(
      id: id,
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'timestamp': timestamp,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
