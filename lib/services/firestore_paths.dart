/// Central place for every Firestore collection name used by the app.
/// Keep this in sync with `firestore.rules`.
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String inventory = 'inventory';
  static const String consignments = 'consignments';
  static const String clientInquiries = 'clientInquiries';
  static const String salesAssociates = 'salesAssociates';
  static const String assignmentActivity = 'assignmentActivity';
  static const String salesForecasts = 'salesForecasts';
  static const String predictionAlerts = 'predictionAlerts';
  static const String salesTransactions = 'salesTransactions';
}
