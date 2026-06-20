import { Router } from 'express';
import { db } from '../firebase.js';
import { sanitize, getPageSize } from '../utils.js';
import { requireAuth } from '../auth.js';
import { tokenStore } from '../tokenStore.js';
import { formatBenhNhanToAPI, formatBenhTNToAPI } from '../formatters.js';

const router = Router();

router.use(requireAuth);

/**
 * POST /api/benhTruyenNhiem/push
 * Lưu hoặc cập nhật một ca bệnh truyền nhiễm từ app mobile
 */
router.post('/push', async (req, res) => {
  try {
    const data = req.body || {};
    const id = data.id;
    const { id: _id, ...saveData } = data;
    saveData.ngayCapNhat = new Date().toISOString();

    if (id) {
      const existing = await db.collection('benhTruyenNhiem').doc(id).get();
      if (existing.exists) {
        await db.collection('benhTruyenNhiem').doc(id).update(saveData);
        return res.json({ success: true, message: 'Đã cập nhật ca bệnh.', id });
      }
    }

    const docRef = await db.collection('benhTruyenNhiem').add({
      ...saveData,
      ngayTao: saveData.ngayTao || new Date().toISOString(),
    });
    res.status(201).json({ success: true, message: 'Đã thêm ca bệnh mới.', id: docRef.id });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhTruyenNhiem
 */
router.get('/', async (req, res) => {
  try {
    const pageSize = getPageSize(req.query);
    let q = db.collection('benhTruyenNhiem').orderBy('ngayTao', 'desc').limit(pageSize);

    if (req.query.chanDoanBenh) {
      q = db.collection('benhTruyenNhiem')
        .where('chanDoanBenh', '==', req.query.chanDoanBenh)
        .orderBy('ngayTao', 'desc').limit(pageSize);
    }
    if (req.query.ketQuaXN) {
      q = db.collection('benhTruyenNhiem')
        .where('ketQuaXN', '==', req.query.ketQuaXN)
        .orderBy('ngayTao', 'desc').limit(pageSize);
    }

    if (req.query.startAfter) {
      const cursor = await db.collection('benhTruyenNhiem').doc(req.query.startAfter).get();
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
 * POST /api/benhTruyenNhiem/byIds
 * Body: { 
 *   benhNhanIds: ['docId1','docId2',...] (optional),
 *   benhTNIds: ['docId1','docId2',...] (required - Firestore document IDs)
 * }
 * Tạo token dựa trên Firestore document IDs
 */
router.post('/byIds', async (req, res) => {
  try {
    const { benhNhanIds = [], benhTNIds = [] } = req.body;
    
    if (!Array.isArray(benhTNIds) || benhTNIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền mảng benhTNIds với ít nhất 1 document ID.' 
      });
    }

    // Lấy dữ liệu bệnh truyền nhiễm theo document ID
    const benhTNData = [];
    for (const docId of benhTNIds) {
      const doc = await db.collection('benhTruyenNhiem').doc(docId).get();
      if (doc.exists) {
        benhTNData.push({ id: doc.id, ...sanitize(doc.data()) });
      }
    }

    // Lấy dữ liệu bệnh nhân theo document ID nếu có
    let benhNhanData = [];
    if (benhNhanIds.length > 0) {
      for (const docId of benhNhanIds) {
        const doc = await db.collection('benhNhan').doc(docId).get();
        if (doc.exists) {
          benhNhanData.push({ id: doc.id, ...sanitize(doc.data()) });
        }
      }
    }

    // Tạo token và lưu document IDs
    const token = tokenStore.create({
      benhNhanIds,
      benhTNIds,
      timestamp: new Date().toISOString(),
      totalBenhNhan: benhNhanData.length,
      totalBenhTN: benhTNData.length,
    });

    res.json({ 
      success: true, 
      token,
      message: 'Token đã được tạo. Sử dụng GET /api/benhTruyenNhiem/thongtinbenhan?token=xxx để lấy dữ liệu.',
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
 * GET /api/benhTruyenNhiem/tatca
 * Lấy toàn bộ ca bệnh không phân trang
 */
router.get('/tatca', async (req, res) => {
  try {
    const snap = await db.collection('benhTruyenNhiem').orderBy('ngayTao', 'desc').get();
    const data = snap.docs.map(d => ({ id: d.id, ...sanitize(d.data()) }));
    res.json({ success: true, total: data.length, data });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhTruyenNhiem/:id
 */
router.get('/:id', async (req, res) => {
  try {
    const doc = await db.collection('benhTruyenNhiem').doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy bệnh án.' });
    }
    res.json({ success: true, data: { id: doc.id, ...sanitize(doc.data()) } });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhTruyenNhiem/thongtinbenhan
 * Query: token=xxx (data token từ POST /byIds)
 * Lấy thông tin bệnh truyền nhiễm đã chọn theo data token
 * Format: Chuẩn API với ID cho danh mục, text cho thông tin cá nhân
 */
router.get('/thongtinbenhan', async (req, res) => {
  console.log('📥 GET /thongtinbenhan - Query:', req.query);
  
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

    // Lấy dữ liệu bệnh nhân theo document ID (nếu có)
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

    // Lấy dữ liệu bệnh truyền nhiễm theo document ID
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
