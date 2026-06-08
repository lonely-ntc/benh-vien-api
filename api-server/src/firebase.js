// Khởi tạo Firebase Admin SDK
// Hỗ trợ 2 cách cấu hình:
//   1. File service-account.json  (local dev)
//   2. Env var FIREBASE_CREDENTIALS (Render production)

import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getFirestore }                 from 'firebase-admin/firestore';
import { readFileSync, existsSync }     from 'fs';
import { resolve }                      from 'path';
import { fileURLToPath }                from 'url';
import { dirname }                      from 'path';

if (getApps().length === 0) {
  let credential;

  // ── Ưu tiên 1: env var FIREBASE_CREDENTIALS (production trên Render) ──
  if (process.env.FIREBASE_CREDENTIALS) {
    try {
      const sa = JSON.parse(process.env.FIREBASE_CREDENTIALS);
      credential = cert(sa);
      console.log('🔑  Firebase: dùng FIREBASE_CREDENTIALS env var');
    } catch {
      console.error('❌  FIREBASE_CREDENTIALS không phải JSON hợp lệ.');
      process.exit(1);
    }
  }
  // ── Ưu tiên 2: file service-account.json (local dev) ──
  else {
    const __dirname = dirname(fileURLToPath(import.meta.url));
    const saPath    = resolve(__dirname, '..', 'service-account.json');
    if (!existsSync(saPath)) {
      console.error('\n❌  Không tìm thấy service-account.json trong api-server/');
      console.error('   Tải từ: Firebase Console → Project Settings → Service accounts');
      console.error('   Hoặc set env var FIREBASE_CREDENTIALS với nội dung JSON.\n');
      process.exit(1);
    }
    credential = cert(JSON.parse(readFileSync(saPath, 'utf8')));
    console.log('🔑  Firebase: dùng service-account.json');
  }

  initializeApp({ credential });
}

export const db = getFirestore();
