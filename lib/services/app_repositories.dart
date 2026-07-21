import '../models/client_assignment.dart';
import '../models/consignment_item.dart';
import '../models/inventory_item.dart';
import '../models/sales_forecast.dart';
import '../models/sales_transaction.dart';
import 'firestore_paths.dart';
import 'firestore_repository.dart';

/// One repository instance per collection, shared app-wide. Screens read
/// from these via `.watchAll()` (a live Stream<List<T>>) instead of the
/// old hardcoded static lists.
class AppRepositories {
  AppRepositories._();

  static final inventory = FirestoreRepository<InventoryItem>(
    collectionPath: FirestoreCollections.inventory,
    fromMap: InventoryItem.fromMap,
    toMap: (item) => item.toMap(),
    orderBy: 'dateAdded',
  );

  static final consignments = FirestoreRepository<ConsignmentItem>(
    collectionPath: FirestoreCollections.consignments,
    fromMap: ConsignmentItem.fromMap,
    toMap: (item) => item.toMap(),
  );

  static final clientInquiries = FirestoreRepository<ClientInquiry>(
    collectionPath: FirestoreCollections.clientInquiries,
    fromMap: ClientInquiry.fromMap,
    toMap: (item) => item.toMap(),
    orderBy: 'no',
  );

  static final salesAssociates = FirestoreRepository<SalesAssociateAssignment>(
    collectionPath: FirestoreCollections.salesAssociates,
    fromMap: SalesAssociateAssignment.fromMap,
    toMap: (item) => item.toMap(),
  );

  static final assignmentActivity = FirestoreRepository<FeedEntryRecord>(
    collectionPath: FirestoreCollections.assignmentActivity,
    fromMap: FeedEntryRecord.fromMap,
    toMap: (item) => item.toMap(),
    orderBy: 'createdAt',
  );

  static final salesForecasts = FirestoreRepository<BrandForecast>(
    collectionPath: FirestoreCollections.salesForecasts,
    fromMap: BrandForecast.fromMap,
    toMap: (item) => item.toMap(),
  );

  static final predictionAlerts = FirestoreRepository<FeedEntryRecord>(
    collectionPath: FirestoreCollections.predictionAlerts,
    fromMap: FeedEntryRecord.fromMap,
    toMap: (item) => item.toMap(),
    orderBy: 'createdAt',
  );

  static final salesTransactions = FirestoreRepository<SalesTransaction>(
    collectionPath: FirestoreCollections.salesTransactions,
    fromMap: SalesTransaction.fromMap,
    toMap: (item) => item.toMap(),
    orderBy: 'date',
  );
}
