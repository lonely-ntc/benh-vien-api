/**
 * Script thêm field benhNhanId cho TẤT CẢ bệnh nhân
 * Format: BN + soThuTu (VD: BN0001, BN0301, BN9999)
 */

import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// Init Firebase
const serviceAccount = JSON.parse(readFileSync('./service-account.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixAllBenhNhanId() {
  console.log('🚀 Bắt đầu thêm benhNhanId cho TẤT CẢ bệnh nhân...\n');
  
  const snapshot = await db.collection('benhNhan').get();
  console.log(`📊 Tìm thấy ${snapshot.size} bệnh nhân\n`);
  
  let updated = 0;
  let skipped = 0;
  let errors = 0;
  
  for (const doc of snapshot.docs) {
    const data = doc.data();
    
    // Nếu đã có benhNhanId thì skip
    if (data.benhNhanId) {
      console.log(`⏭️  Skip ${doc.id} - Đã có benhNhanId: ${data.benhNhanId}`);
      skipped++;
      continue;
    }
    
    // Tạo benhNhanId từ soThuTu
    let benhNhanId;
    if (data.soThuTu) {
      benhNhanId = `BN${String(data.soThuTu).padStart(4, '0')}`; // BN0001, BN0301, BN9999
    } else {
      console.log(`⚠️  ${doc.id} - Không có soThuTu, bỏ qua`);
      errors++;
      continue;
    }
    
    try {
      // Cập nhật
      await doc.ref.update({ benhNhanId });
      console.log(`✅ ${doc.id} → benhNhanId: ${benhNhanId} (hoTen: ${data.hoTen}, soThuTu: ${data.soThuTu})`);
      updated++;
    } catch (err) {
      console.error(`❌ ${doc.id} - Lỗi: ${err.message}`);
      errors++;
    }
  }
  
  console.log(`\n✨ Hoàn thành!`);
  console.log(`   - Đã cập nhật: ${updated}`);
  console.log(`   - Đã bỏ qua (đã có benhNhanId): ${skipped}`);
  console.log(`   - Lỗi: ${errors}`);
  console.log(`   - Tổng: ${snapshot.size}`);
}

fixAllBenhNhanId()
  .then(() => process.exit(0))
  .catch(err => {
    console.error('❌ Lỗi:', err);
    process.exit(1);
  });
