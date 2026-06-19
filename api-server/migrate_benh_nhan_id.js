/**
 * Migration Script: Thêm trường benhNhanId cho tất cả bệnh nhân
 * 
 * Script này sẽ:
 * 1. Quét tất cả documents trong collection benhNhan
 * 2. Tạo mã bệnh nhân tự động theo format: BN0001, BN0002, ...
 * 3. Cập nhật Firestore với trường benhNhanId mới
 * 
 * Chạy: node migrate_benh_nhan_id.js
 */

import 'dotenv/config';
import admin from 'firebase-admin';
import { readFileSync } from 'fs';

// ── Khởi tạo Firebase Admin ────────────────────────────────────────────────
const serviceAccount = JSON.parse(readFileSync('./service-account.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

/**
 * Tạo mã bệnh nhân theo format BN0001, BN0002, ...
 */
function generateBenhNhanId(index) {
  const number = (index + 1).toString().padStart(4, '0');
  return `BN${number}`;
}

/**
 * Migration chính
 */
async function migrateBenhNhanIds() {
  console.log('🚀 Bắt đầu migration: Thêm benhNhanId cho bệnh nhân\n');

  try {
    // Lấy tất cả bệnh nhân, sắp xếp theo soThuTu hoặc ngayDangKy
    const snapshot = await db.collection('benhNhan')
      .orderBy('soThuTu', 'asc')
      .get();

    if (snapshot.empty) {
      console.log('⚠️  Không tìm thấy bệnh nhân nào trong database.');
      return;
    }

    console.log(`📊 Tìm thấy ${snapshot.size} bệnh nhân\n`);

    const batch = db.batch();
    let updateCount = 0;
    let skipCount = 0;

    snapshot.docs.forEach((doc, index) => {
      const data = doc.data();
      
      // Nếu đã có benhNhanId thì skip
      if (data.benhNhanId) {
        skipCount++;
        console.log(`⏭️  [${index + 1}/${snapshot.size}] Skip: ${doc.id} - ${data.hoTen} (đã có: ${data.benhNhanId})`);
        return;
      }

      // Tạo mã bệnh nhân mới
      const benhNhanId = generateBenhNhanId(index);
      
      // Thêm vào batch update
      batch.update(doc.ref, { 
        benhNhanId,
        ngayCapNhat: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      updateCount++;
      console.log(`✅ [${index + 1}/${snapshot.size}] Update: ${doc.id} - ${data.hoTen || '(Không có tên)'} → ${benhNhanId}`);
    });

    // Commit batch
    if (updateCount > 0) {
      console.log(`\n⏳ Đang cập nhật ${updateCount} bệnh nhân...`);
      await batch.commit();
      console.log(`\n✅ Hoàn thành! Đã cập nhật ${updateCount} bệnh nhân.`);
    } else {
      console.log('\n✅ Không có bệnh nhân nào cần cập nhật.');
    }

    if (skipCount > 0) {
      console.log(`⏭️  Đã bỏ qua ${skipCount} bệnh nhân (đã có mã).`);
    }

    // Thống kê
    console.log('\n' + '='.repeat(60));
    console.log('📊 THỐNG KÊ:');
    console.log(`   Tổng số bệnh nhân:     ${snapshot.size}`);
    console.log(`   Đã cập nhật:           ${updateCount}`);
    console.log(`   Đã bỏ qua:             ${skipCount}`);
    console.log('='.repeat(60));

  } catch (error) {
    console.error('❌ Lỗi khi migration:', error);
    process.exit(1);
  }
}

/**
 * Kiểm tra kết quả sau migration
 */
async function verifyMigration() {
  console.log('\n🔍 Kiểm tra kết quả migration...\n');

  try {
    const snapshot = await db.collection('benhNhan').get();
    
    let hasIdCount = 0;
    let noIdCount = 0;
    const duplicates = {};

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      if (data.benhNhanId) {
        hasIdCount++;
        // Kiểm tra trùng lặp
        if (duplicates[data.benhNhanId]) {
          duplicates[data.benhNhanId].push(doc.id);
        } else {
          duplicates[data.benhNhanId] = [doc.id];
        }
      } else {
        noIdCount++;
        console.log(`⚠️  Thiếu benhNhanId: ${doc.id} - ${data.hoTen || '(Không có tên)'}`);
      }
    });

    // Kiểm tra trùng lặp
    const duplicateIds = Object.keys(duplicates).filter(id => duplicates[id].length > 1);
    if (duplicateIds.length > 0) {
      console.log('\n⚠️  Phát hiện mã bệnh nhân trùng lặp:');
      duplicateIds.forEach(id => {
        console.log(`   ${id}: ${duplicates[id].join(', ')}`);
      });
    }

    console.log('\n' + '='.repeat(60));
    console.log('✅ KẾT QUẢ KIỂM TRA:');
    console.log(`   Có benhNhanId:         ${hasIdCount}`);
    console.log(`   Thiếu benhNhanId:      ${noIdCount}`);
    console.log(`   Mã trùng lặp:          ${duplicateIds.length}`);
    console.log('='.repeat(60));

    if (noIdCount === 0 && duplicateIds.length === 0) {
      console.log('\n🎉 Migration thành công hoàn toàn!');
    } else {
      console.log('\n⚠️  Migration có vấn đề, cần kiểm tra lại.');
    }

  } catch (error) {
    console.error('❌ Lỗi khi kiểm tra:', error);
  }
}

/**
 * Chạy migration
 */
async function main() {
  console.log('\n' + '='.repeat(60));
  console.log('  MIGRATION: Thêm benhNhanId cho Bệnh Nhân');
  console.log('='.repeat(60) + '\n');

  await migrateBenhNhanIds();
  await verifyMigration();

  console.log('\n✅ Hoàn tất!\n');
  process.exit(0);
}

// Run
main().catch(error => {
  console.error('❌ Lỗi nghiêm trọng:', error);
  process.exit(1);
});
