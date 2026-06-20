import { Router } from 'express';
import { db } from '../firebase.js';
import { sanitize, getPageSize } from '../utils.js';
import { requireAuth } from '../auth.js';
import { tokenStore } from '../tokenStore.js';
import { formatBenhNhanToAPI, formatBenhTNToAPI } from '../formatters.js';

const router = Router();

// Tất cả routes đều cần JWT
router.use(requireAuth);

/**
 * POST /api/benhNhan/push
 * Body: { ...benhNhanData }
 * Lưu hoặc cập nhật một bệnh nhân từ app mobile
 */
router.post('/push', async (req, res) => {
  try {
    const data = req.body || {};
    const id = data.id;

    // Xóa field id khỏi data trước khi lưu
    const { id: _id, ...saveData } = data;
    saveData.ngayCapNhat = new Date().toISOString();

    if (id) {
      // Kiểm tra đã tồn tại chưa
      const existing = await db.collection('benhNhan').doc(id).get();
      if (existing.exists) {
        await db.collection('benhNhan').doc(id).update(saveData);
        return res.json({ success: true, message: 'Đã cập nhật bệnh nhân.', id });
      }
    }

    // Tạo mới
    const docRef = await db.collection('benhNhan').add({
      ...saveData,
      ngayDangKy: saveData.ngayDangKy || new Date().toISOString(),
    });
    res.status(201).json({ success: true, message: 'Đã thêm bệnh nhân mới.', id: docRef.id });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhNhan
 * Query: pageSize=50, startAfter=<docId>
 */
router.get('/', async (req, res) => {
  try {
    const pageSize = getPageSize(req.query);
    let q = db.collection('benhNhan').orderBy('soThuTu').limit(pageSize);

    if (req.query.startAfter) {
      const cursor = await db.collection('benhNhan').doc(req.query.startAfter).get();
      if (cursor.exists) q = q.startAfter(cursor);
    }

    const snap = await q.get();
    const data = snap.docs.map(d => ({ id: d.id, ...sanitize(d.data()) }));

    res.json({
      success: true,
      total: data.length,
      pageSize,
      nextStartAfter: data.length === pageSize ? data[data.length - 1].id : null,
      data,
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * POST /api/benhNhan/byIds
 * Body: { 
 *   benhNhanIds: ['docId1','docId2',...],  // Firestore document IDs
 *   benhTNIds: ['docId1','docId2',...]      // Firestore document IDs (optional)
 * }
 * Tạo token dựa trên Firestore document IDs
 */
router.post('/byIds', async (req, res) => {
  try {
    const { benhNhanIds = [], benhTNIds = [] } = req.body;
    
    if (!Array.isArray(benhNhanIds) || benhNhanIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền mảng benhNhanIds với ít nhất 1 document ID.' 
      });
    }

    // Lấy dữ liệu bệnh nhân theo document ID
    const benhNhanData = [];
    for (const docId of benhNhanIds) {
      const doc = await db.collection('benhNhan').doc(docId).get();
      if (doc.exists) {
        benhNhanData.push({ id: doc.id, ...sanitize(doc.data()) });
      }
    }

    // Lấy dữ liệu bệnh truyền nhiễm theo document ID nếu có
    let benhTNData = [];
    if (benhTNIds.length > 0) {
      for (const docId of benhTNIds) {
        const doc = await db.collection('benhTruyenNhiem').doc(docId).get();
        if (doc.exists) {
          benhTNData.push({ id: doc.id, ...sanitize(doc.data()) });
        }
      }
    }

    // Tạo token và lưu document IDs
    const token = tokenStore.create({
      benhNhanIds,  // Firestore document IDs
      benhTNIds,    // Firestore document IDs
      timestamp: new Date().toISOString(),
      totalBenhNhan: benhNhanData.length,
      totalBenhTN: benhTNData.length,
    });

    res.json({ 
      success: true, 
      token,
      message: 'Token đã được tạo. Sử dụng GET /api/benhNhan/thongtinbenhnhan?token=xxx để lấy dữ liệu.',
      summary: {
        benhNhanCount: benhNhanData.length,
        benhTNCount: benhTNData.length,
        requestedBenhNhan: benhNhanIds.length,
        requestedBenhTN: benhTNIds.length,
        notFoundBenhNhan: benhNhanIds.length - benhNhanData.length,
        notFoundBenhTN: benhTNIds.length - benhTNData.length,
      },
      expiresIn: '24 giờ',
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhNhan/tatca
 * Lấy toàn bộ bệnh nhân không phân trang
 */
router.get('/tatca', async (req, res) => {
  try {
    const snap = await db.collection('benhNhan').orderBy('soThuTu').get();
    const data = snap.docs.map(d => ({ id: d.id, ...sanitize(d.data()) }));
    res.json({ success: true, total: data.length, data });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhNhan/:id
 */
router.get('/:id', async (req, res) => {
  try {
    const doc = await db.collection('benhNhan').doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy bệnh nhân.' });
    }
    res.json({ success: true, data: { id: doc.id, ...sanitize(doc.data()) } });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhNhan/thongtinbenhnhan
 * Query: token=xxx (data token từ POST /byIds)
 * Lấy thông tin bệnh nhân đã chọn theo data token
 * Format: Chuẩn API với ID cho danh mục, text cho thông tin cá nhân
 */
router.get('/thongtinbenhnhan', async (req, res) => {
  console.log('📥 GET /thongtinbenhnhan - Query:', req.query);
  
  try {
    const dataToken = req.query.token;
    
    if (!dataToken) {
      console.log('❌ Missing token parameter');
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền token trong query parameter (?token=xxx)' 
      });
    }
    
    const tokenData = tokenStore.get(dataToken);
    console.log('🔍 Token data:', tokenData ? 'Found' : 'Not found');
    
    if (!tokenData) {
      return res.status(404).json({ 
        success: false, 
        message: 'Token không tồn tại hoặc đã hết hạn.' 
      });
    }

    const { benhNhanIds = [], benhTNIds = [] } = tokenData;
    console.log(`📊 Fetching: ${benhNhanIds.length} BN IDs, ${benhTNIds.length} BTN IDs`);

    // Lấy dữ liệu bệnh nhân theo document ID
    const benhNhanData = [];
    if (benhNhanIds.length > 0) {
      for (const docId of benhNhanIds) {
        const doc = await db.collection('benhNhan').doc(docId).get();
        if (doc.exists) {
          const data = doc.data();
          benhNhanData.push(formatBenhNhanToAPI(data));
        }
      }
    }

    // Lấy dữ liệu bệnh truyền nhiễm theo document ID (nếu có)
    const benhTNData = [];
    if (benhTNIds.length > 0) {
      for (const docId of benhTNIds) {
        const doc = await db.collection('benhTruyenNhiem').doc(docId).get();
        if (doc.exists) {
          const data = doc.data();
          benhTNData.push(formatBenhTNToAPI(data));
        }
      }
    }

    console.log(`✅ Returning: ${benhNhanData.length} BN, ${benhTNData.length} BTN`);

    res.json({ 
      success: true,
      token: dataToken,
      timestamp: tokenData.timestamp,
      data: {
        benhNhan: benhNhanData,
        benhTruyenNhiem: benhTNData,
      },
      summary: {
        benhNhanCount: benhNhanData.length,
        benhTNCount: benhTNData.length,
        total: benhNhanData.length + benhTNData.length,
        requestedBenhNhan: benhNhanIds.length,
        requestedBenhTN: benhTNIds.length,
        notFoundBenhNhan: benhNhanIds.length - benhNhanData.length,
        notFoundBenhTN: benhTNIds.length - benhTNData.length,
      }
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

export default router;
