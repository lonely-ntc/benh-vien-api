import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// Initialize Firebase Admin
const serviceAccount = JSON.parse(readFileSync('./service-account.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// ─────────────────────────────────────────────────────────────────────────────
// DELETE ALL DOCUMENTS IN A COLLECTION
// ─────────────────────────────────────────────────────────────────────────────
async function deleteCollection(collectionName) {
  console.log(`🗑️  Deleting all documents in ${collectionName}...`);
  const collectionRef = db.collection(collectionName);
  const query = collectionRef.limit(500);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve).catch(reject);
  });
}

async function deleteQueryBatch(query, resolve) {
  const snapshot = await query.get();

  const batchSize = snapshot.size;
  if (batchSize === 0) {
    resolve();
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();

  process.nextTick(() => {
    deleteQueryBatch(query, resolve);
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TINH DATA - 63 PROVINCES
// ─────────────────────────────────────────────────────────────────────────────
const tinhData = [
  { Id: 1, Name: 'Thành phố Hà Nội' },
  { Id: 2, Name: 'Tỉnh Hà Giang' },
  { Id: 3, Name: 'Tỉnh Cao Bằng' },
  { Id: 4, Name: 'Tỉnh Bắc Kạn' },
  { Id: 5, Name: 'Tỉnh Tuyên Quang' },
  { Id: 6, Name: 'Tỉnh Lào Cai' },
  { Id: 7, Name: 'Tỉnh Điện Biên' },
  { Id: 8, Name: 'Tỉnh Lai Châu' },
  { Id: 9, Name: 'Tỉnh Sơn La' },
  { Id: 10, Name: 'Tỉnh Yên Bái' },
  { Id: 11, Name: 'Tỉnh Hòa Bình' },
  { Id: 12, Name: 'Tỉnh Thái Nguyên' },
  { Id: 13, Name: 'Tỉnh Lạng Sơn' },
  { Id: 14, Name: 'Tỉnh Quảng Ninh' },
  { Id: 15, Name: 'Tỉnh Bắc Giang' },
  { Id: 16, Name: 'Tỉnh Phú Thọ' },
  { Id: 17, Name: 'Tỉnh Vĩnh Phúc' },
  { Id: 18, Name: 'Tỉnh Bắc Ninh' },
  { Id: 19, Name: 'Tỉnh Hải Dương' },
  { Id: 20, Name: 'Thành phố Hải Phòng' },
  { Id: 21, Name: 'Tỉnh Hưng Yên' },
  { Id: 22, Name: 'Tỉnh Thái Bình' },
  { Id: 23, Name: 'Tỉnh Hà Nam' },
  { Id: 24, Name: 'Tỉnh Nam Định' },
  { Id: 25, Name: 'Tỉnh Ninh Bình' },
  { Id: 26, Name: 'Tỉnh Thanh Hóa' },
  { Id: 27, Name: 'Tỉnh Nghệ An' },
  { Id: 28, Name: 'Tỉnh Hà Tĩnh' },
  { Id: 29, Name: 'Tỉnh Quảng Bình' },
  { Id: 30, Name: 'Tỉnh Quảng Trị' },
  { Id: 31, Name: 'Tỉnh Thừa Thiên Huế' },
  { Id: 32, Name: 'Thành phố Đà Nẵng' },
  { Id: 33, Name: 'Tỉnh Quảng Nam' },
  { Id: 34, Name: 'Tỉnh Quảng Ngãi' },
  { Id: 35, Name: 'Tỉnh Bình Định' },
  { Id: 36, Name: 'Tỉnh Phú Yên' },
  { Id: 37, Name: 'Tỉnh Khánh Hòa' },
  { Id: 38, Name: 'Tỉnh Ninh Thuận' },
  { Id: 39, Name: 'Tỉnh Bình Thuận' },
  { Id: 40, Name: 'Tỉnh Kon Tum' },
  { Id: 41, Name: 'Tỉnh Gia Lai' },
  { Id: 42, Name: 'Tỉnh Đắk Lắk' },
  { Id: 43, Name: 'Tỉnh Đắk Nông' },
  { Id: 44, Name: 'Tỉnh Lâm Đồng' },
  { Id: 45, Name: 'Tỉnh Bình Phước' },
  { Id: 46, Name: 'Tỉnh Tây Ninh' },
  { Id: 47, Name: 'Tỉnh Bình Dương' },
  { Id: 48, Name: 'Tỉnh Đồng Nai' },
  { Id: 49, Name: 'Tỉnh Bà Rịa - Vũng Tàu' },
  { Id: 50, Name: 'Thành phố Hồ Chí Minh' },
  { Id: 51, Name: 'Tỉnh Long An' },
  { Id: 52, Name: 'Tỉnh Tiền Giang' },
  { Id: 53, Name: 'Tỉnh Bến Tre' },
  { Id: 54, Name: 'Tỉnh Trà Vinh' },
  { Id: 55, Name: 'Tỉnh Vĩnh Long' },
  { Id: 56, Name: 'Tỉnh Đồng Tháp' },
  { Id: 57, Name: 'Tỉnh An Giang' },
  { Id: 58, Name: 'Tỉnh Kiên Giang' },
  { Id: 59, Name: 'Thành phố Cần Thơ' },
  { Id: 60, Name: 'Tỉnh Hậu Giang' },
  { Id: 61, Name: 'Tỉnh Sóc Trăng' },
  { Id: 62, Name: 'Tỉnh Bạc Liêu' },
  { Id: 63, Name: 'Tỉnh Cà Mau' }
];

// ─────────────────────────────────────────────────────────────────────────────
// SEED TINH WITH CORRECT IDS
// ─────────────────────────────────────────────────────────────────────────────
async function seedTinh() {
  console.log('\n📦 Seeding Tinh collection...');
  const batch = db.batch();
  
  for (const item of tinhData) {
    // Use the Id as document ID
    const docRef = db.collection('tinh').doc(item.Id.toString());
    batch.set(docRef, {
      id: item.Id,
      name: item.Name
    });
  }
  
  await batch.commit();
  console.log(`✅ Seeded ${tinhData.length} provinces/cities`);
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────
async function main() {
  try {
    console.log('🚀 Starting Tinh collection refresh...\n');
    
    // Step 1: Delete old data
    await deleteCollection('tinh');
    console.log('✅ Old data deleted\n');
    
    // Step 2: Seed new data
    await seedTinh();
    
    // Step 3: Verify
    const snapshot = await db.collection('tinh').get();
    console.log(`\n✅ Verification: ${snapshot.size} documents in Tinh collection`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

main();
