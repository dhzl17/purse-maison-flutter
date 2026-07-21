/**
 * One-time seed script: creates the 3 demo Firebase Auth accounts (same
 * usernames/passwords/roles as the old MockAccounts list) and populates
 * every Firestore collection with the same sample data the app used to
 * show as hardcoded dummy lists, so the app isn't empty on first run.
 *
 * Setup (see SETUP.md for the full walkthrough):
 *   1. Firebase Console → Project Settings → Service Accounts →
 *      "Generate new private key" → save the JSON as
 *      seed/serviceAccountKey.json (this file is gitignored — never
 *      commit it, it grants full admin access to your project).
 *   2. cd seed && npm install
 *   3. node seed.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();
const db = admin.firestore();

const ACCOUNTS = [
  { username: 'superadmin', password: 'admin123', role: 'superAdmin' },
  { username: 'salesassociate', password: 'sales123', role: 'salesAssociate' },
  { username: 'operationalstaff', password: 'ops123', role: 'operationalStaff' },
];

async function seedAccounts() {
  for (const acc of ACCOUNTS) {
    const email = `${acc.username}@pursemaison.app`;
    let user;
    try {
      user = await auth.getUserByEmail(email);
      console.log(`✓ ${email} already exists (uid ${user.uid})`);
    } catch (e) {
      user = await auth.createUser({
        email,
        password: acc.password,
        emailVerified: true,
      });
      console.log(`+ created ${email} (uid ${user.uid})`);
    }
    await db.collection('users').doc(user.uid).set({
      username: acc.username,
      role: acc.role,
    });
  }
}

const INVENTORY_BASE = [
  { id: 'INV-001', brand: 'Hermès', category: 'Handbag', condition: 'Very Good', status: 'available', location: 'Showroom', dateAdded: '4/20/2024', transactionStatus: 'none', price: '₱720,000' },
  { id: 'INV-002', brand: 'Chanel', category: 'Shoulder Bag', condition: 'Excellent', status: 'reserved', location: 'Showroom', dateAdded: '4/18/2024', transactionStatus: 'pending', price: '₱265,000' },
  { id: 'INV-003', brand: 'Louis Vuitton', category: 'Tote', condition: 'Excellent', status: 'available', location: 'Showroom', dateAdded: '4/15/2024', transactionStatus: 'none', price: '₱165,000' },
  { id: 'INV-004', brand: 'Prada', category: 'Tote', condition: 'Excellent', status: 'rejected', location: 'For Return', dateAdded: '4/12/2024', transactionStatus: 'cancelled', price: '₱240,000' },
  { id: 'INV-005', brand: 'Gucci', category: 'Crossbody', condition: 'Good', status: 'sold', location: 'Released', dateAdded: '4/10/2024', transactionStatus: 'completed', price: '₱110,000' },
  { id: 'INV-006', brand: 'Dior', category: 'Shoulder Bag', condition: 'Excellent', status: 'available', location: 'Stockroom', dateAdded: '4/4/2024', transactionStatus: 'none', price: '₱240,000' },
];

function buildInventory() {
  const items = [...INVENTORY_BASE];
  const extraBrands = ['Fendi', 'Bottega Veneta', 'Celine', 'Saint Laurent', 'Loewe', 'Balenciaga'];
  const extraCategories = ['Handbag', 'Shoulder Bag', 'Tote', 'Crossbody', 'Clutch'];
  const extraConditions = ['Very Good', 'Excellent', 'Good'];
  const extraLocations = ['Showroom', 'Released', 'Stockroom', 'For Return'];
  const extraStatuses = ['available', 'reserved', 'sold', 'available', 'rejected', 'sold'];
  const extraTransactions = ['none', 'pending', 'completed', 'none', 'cancelled', 'completed'];
  const extraDates = ['3/2/2024', '3/8/2024', '3/14/2024', '3/20/2024', '3/26/2024', '4/1/2024'];
  const extraPrices = ['₱310,000', '₱185,000', '₱95,000', '₱420,000', '₱150,000', '₱88,000'];

  for (let i = 0; i < 30; i++) {
    items.push({
      id: `INV-${String(items.length + 1).padStart(3, '0')}`,
      brand: extraBrands[i % extraBrands.length],
      category: extraCategories[i % extraCategories.length],
      condition: extraConditions[i % extraConditions.length],
      status: extraStatuses[i % extraStatuses.length],
      location: extraLocations[i % extraLocations.length],
      dateAdded: extraDates[i % extraDates.length],
      transactionStatus: extraTransactions[i % extraTransactions.length],
      price: extraPrices[i % extraPrices.length],
    });
  }
  return items;
}

const CONSIGNMENTS = [
  { id: '1101', brand: 'Hermès', itemName: 'Kelly 28 Epsom Noir', imagePath: 'assets/images/hermes_kelly.png', category: 'Handbag', condition: 'Very Good', authentication: 'verified', status: 'Received', price: '₱720,000', payoutStatus: 'notYetSold' },
  { id: '1102', brand: 'Chanel', itemName: 'Chanel Boy Bag Small', imagePath: 'assets/images/chanel_boy_bag_small.png', category: 'Shoulder Bag', condition: 'Excellent', authentication: 'verified', status: 'For Photography', price: '₱265,000', payoutStatus: 'notYetSold' },
  { id: '1103', brand: 'Louis Vuitton', itemName: 'LV OnTheGo MM', imagePath: 'assets/images/lv_onthego_mm.png', category: 'Tote', condition: 'Excellent', authentication: 'verified', status: 'Received', price: '₱165,000', payoutStatus: 'notYetSold' },
  { id: '1104', brand: 'Prada', itemName: 'Prada Galleria Saffiano', imagePath: 'assets/images/prada_galleria_saffiano.png', category: 'Tote', condition: 'Excellent', authentication: 'rejected', status: 'Return to Consignor', price: '₱110,000', payoutStatus: 'cancelled' },
  { id: '1105', brand: 'Gucci', itemName: 'Gucci Marmont Matelassé', imagePath: 'assets/images/gucci_marmont_matelasse.png', category: 'Crossbody', condition: 'Good', authentication: 'verified', status: 'Received', price: '₱92,000', payoutStatus: 'sold' },
  { id: '1106', brand: 'Dior', itemName: 'Dior Saddle Bag Oblique', imagePath: 'assets/images/dior_saddle_oblique.png', category: 'Shoulder Bag', condition: 'Excellent', authentication: 'verified', status: 'Received', price: '₱240,000', payoutStatus: 'notYetSold' },
  { id: '1107', brand: 'Fendi', itemName: 'Fendi Baguette Medium', imagePath: 'assets/images/fendi_baguette.png', category: 'Shoulder Bag', condition: 'Good', authentication: 'verified', status: 'Received', price: '₱135,000', payoutStatus: 'notYetSold' },
  { id: '1108', brand: 'Bottega Veneta', itemName: 'Bottega Jodie Small', imagePath: 'assets/images/bottega_jodie.png', category: 'Hobo', condition: 'Very Good', authentication: 'verified', status: 'For Photography', price: '₱178,000', payoutStatus: 'notYetSold' },
  { id: '1109', brand: 'Celine', itemName: 'Celine Triomphe Canvas', imagePath: 'assets/images/celine_triomphe_canvas.png', category: 'Shoulder Bag', condition: 'Excellent', authentication: 'verified', status: 'Received', price: '₱98,000', payoutStatus: 'sold' },
];

const CLIENT_INQUIRIES = [
  { id: 'ci-1', no: 1, clientName: 'Maria Santos', clientType: 'Walk-in', clientRole: 'Buyer', inquiryStatus: 'newInquiry', inquirySource: 'Facebook', transactionResult: 'none' },
  { id: 'ci-2', no: 2, clientName: 'John Cruz', clientType: 'Walk-in', clientRole: 'Buyer', inquiryStatus: 'closed', inquirySource: 'Facebook', transactionResult: 'noPurchase' },
  { id: 'ci-3', no: 3, clientName: 'Angelie Reyes', clientType: 'Walk-in', clientRole: 'Consignor', inquiryStatus: 'followedUp', inquirySource: 'Tiktok', transactionResult: 'none' },
  { id: 'ci-4', no: 4, clientName: 'Mark Tan', clientType: 'Walk-in', clientRole: 'Buyer', inquiryStatus: 'newInquiry', inquirySource: 'Instagram', transactionResult: 'none' },
  { id: 'ci-5', no: 5, clientName: 'Sofia Lim', clientType: 'Walk-in', clientRole: 'Buyer', inquiryStatus: 'followedUp', inquirySource: 'Tiktok', transactionResult: 'none' },
  { id: 'ci-6', no: 6, clientName: 'Lily Tiu', clientType: 'VIP', clientRole: 'Buyer', inquiryStatus: 'reserved', inquirySource: 'Facebook', transactionResult: 'purchased' },
  { id: 'ci-7', no: 7, clientName: 'Sophia Moore', clientType: 'Walk-in', clientRole: 'Consignor', inquiryStatus: 'followedUp', inquirySource: 'Tiktok', transactionResult: 'none' },
];

const SALES_ASSOCIATES = [
  { id: 'sa-1', associateName: 'Alex Rivera', status: 'assigned', currentClient: 'Lily Tiu' },
  { id: 'sa-2', associateName: 'Bea Gonzales', status: 'available', currentClient: '-' },
  { id: 'sa-3', associateName: 'Carlo Mendoza', status: 'assigned', currentClient: 'John Cruz' },
  { id: 'sa-4', associateName: 'Denise Flores', status: 'assigned', currentClient: 'Angelie Reyes' },
  { id: 'sa-5', associateName: 'Ethan Lee', status: 'assigned', currentClient: 'Sophia Moore' },
  { id: 'sa-6', associateName: 'Franz Garcia', status: 'assigned', currentClient: 'Mark Tan' },
  { id: 'sa-7', associateName: 'Cris Vega', status: 'assigned', currentClient: 'Sofia Lim' },
];

const ASSIGNMENT_ACTIVITY = [
  { id: 'act-1', description: 'Client "Lily Tiu" assigned to Associate "Alex Rivera"', timestamp: 'Today, 10:20 AM' },
  { id: 'act-2', description: 'Online inquiry from "Peter Tan" assigned to Associate "Cris Vega"', timestamp: 'Yesterday, 1:18 PM' },
  { id: 'act-3', description: 'Client "Sofia Lim" assigned to Associate "Cris Vega"', timestamp: 'Yesterday, 9:15 AM' },
];

const SALES_FORECASTS = [
  { id: 'Louis Vuitton', brand: 'Louis Vuitton', historicalSales: '4,850,000', projectedSales: '5,420,000', projectedGrowthPercent: 11.8, trend: 'increasing' },
  { id: 'Chanel', brand: 'Chanel', historicalSales: '4,100,000', projectedSales: '4,650,000', projectedGrowthPercent: 13.4, trend: 'increasing' },
  { id: 'Dior', brand: 'Dior', historicalSales: '2,950,000', projectedSales: '3,550,000', projectedGrowthPercent: 13.6, trend: 'increasing' },
  { id: 'Gucci', brand: 'Gucci', historicalSales: '2,300,000', projectedSales: '2,550,000', projectedGrowthPercent: 10.9, trend: 'increasing' },
  { id: 'Prada', brand: 'Prada', historicalSales: '1,600,000', projectedSales: '1,350,000', projectedGrowthPercent: -15.6, trend: 'decreasing' },
  { id: 'YSL', brand: 'YSL', historicalSales: '1,200,000', projectedSales: '1,250,000', projectedGrowthPercent: 4.2, trend: 'stable' },
];

const PREDICTION_ALERTS = [
  { id: 'pa-1', description: 'Demand for Chanel handbags is expected to increase significantly next month.', timestamp: 'Apr 28, 2024' },
  { id: 'pa-2', description: 'Louis Vuitton is projected to have sustained high demand in Q3.', timestamp: 'Apr 28, 2024' },
  { id: 'pa-3', description: 'Prada Handbags are projected to have lower demand. Consider reducing inventory.', timestamp: 'Apr 28, 2024' },
  { id: 'pa-4', description: 'Gucci wallets show steady growth. Maintain current inventory level.', timestamp: 'Apr 28, 2024' },
];

function buildSalesTransactions() {
  const now = new Date();
  const thisMonth = (day, amount, label, itemId) => ({
    id: `seed-txn-this-${day}`,
    itemLabel: label,
    amount,
    date: new Date(now.getFullYear(), now.getMonth(), day),
    itemId: itemId || null,
  });
  const lastMonth = (day, amount, label, itemId) => ({
    id: `seed-txn-last-${day}`,
    itemLabel: label,
    amount,
    date: new Date(now.getFullYear(), now.getMonth() - 1, day),
    itemId: itemId || null,
  });

  return [
    thisMonth(2, 110000, 'Gucci Marmont Matelasse (INV-005)', 'INV-005'),
    thisMonth(9, 98000, 'Celine Triomphe Canvas (1109)'),
    thisMonth(15, 240000, 'Dior Saddle Bag Oblique (INV-006)'),
    lastMonth(4, 92000, 'Gucci Marmont Matelasse (1105)'),
    lastMonth(11, 88000, 'Balenciaga sample sale (INV-030)'),
    lastMonth(19, 150000, 'Loewe sample sale (INV-024)'),
    lastMonth(26, 95000, 'Celine sample sale (INV-015)'),
  ];
}

async function seedCollection(name, rows, { withCreatedAt = false } = {}) {
  const batch = db.batch();
  for (const row of rows) {
    const { id, ...data } = row;
    if (withCreatedAt) data.createdAt = admin.firestore.FieldValue.serverTimestamp();
    batch.set(db.collection(name).doc(id), data, { merge: true });
  }
  await batch.commit();
  console.log(`✓ seeded ${rows.length} docs into "${name}"`);
}

async function main() {
  await seedAccounts();
  await seedCollection('inventory', buildInventory());
  await seedCollection('consignments', CONSIGNMENTS);
  await seedCollection('clientInquiries', CLIENT_INQUIRIES);
  await seedCollection('salesAssociates', SALES_ASSOCIATES);
  await seedCollection('assignmentActivity', ASSIGNMENT_ACTIVITY, { withCreatedAt: true });
  await seedCollection('salesForecasts', SALES_FORECASTS);
  await seedCollection('predictionAlerts', PREDICTION_ALERTS, { withCreatedAt: true });
  await seedCollection('salesTransactions', buildSalesTransactions());
  console.log('\nAll done. Log in with superadmin / admin123 (or salesassociate / sales123, operationalstaff / ops123).');
  process.exit(0);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
