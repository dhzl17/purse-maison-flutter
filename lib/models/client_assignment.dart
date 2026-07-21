import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;

/// Status of a client inquiry as it moves through the pipeline.
enum InquiryStatus { newInquiry, closed, followedUp, reserved }

/// Outcome of a client inquiry, if any transaction has happened yet.
enum TransactionResult { none, noPurchase, purchased }

/// Availability of a sales associate.
enum AssociateStatus { assigned, available }

/// A row in the client inquiries table.
///
/// Backed by Firestore collection `clientInquiries/{id}`.
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

/// A row in the sales associate assignment table.
///
/// Backed by Firestore collection `salesAssociates/{id}`.
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

/// An entry in an activity feed (recent assignment activity, prediction
/// alerts, etc). Backed by Firestore collections `assignmentActivity` and
/// `predictionAlerts`.
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
      // Real ordering key — 'timestamp' above is just the display string,
      // same as the original mock data (e.g. "Yesterday, 1:18 PM").
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
