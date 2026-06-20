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
 *   benhNhanIds: ['BN0001','BN0002',...] (optional),
 *   benhTNIds: ['BA0001','BA0002',...] (required - mã bệnh án)
 * }
 * Tạo token dựa trên mã bệnh án (benhAnId)
 */
router.post('/byIds', async (req, res) => {
  try {
    const { benhNhanIds = [], benhTNIds = [] } = req.body;
    
    if (!Array.isArray(benhTNIds) || benhTNIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền mảng benhTNIds với ít nhất 1 mã bệnh án (VD: BA0001).' 
      });
    }

    // Lấy dữ liệu bệnh truyền nhiễm theo benhAnId
    const benhTNChunks = [];
    for (let i = 0; i < benhTNIds.length; i += 10) {
      benhTNChunks.push(benhTNIds.slice(i, i + 10));
    }
    
    const benhTNData = [];
    for (const chunk of benhTNChunks) {
      const snap = await db.collection('benhTruyenNhiem')
        .where('benhAnId', 'in', chunk)
        .get();
      snap.docs.forEach(d => benhTNData.push({ id: d.id, ...sanitize(d.data()) }));
    }

    // Lấy dữ liệu bệnh nhân theo benhNhanId nếu có
    let benhNhanData = [];
    if (benhNhanIds.length > 0) {
      const benhNhanChunks = [];
      for (let i = 0; i < benhNhanIds.length; i += 10) {
        benhNhanChunks.push(benhNhanIds.slice(i, i + 10));
      }
      
      for (const chunk of benhNhanChunks) {
        const snap = await db.collection('benhNhan')
          .where('benhNhanId', 'in', chunk)
          .get();
        snap.docs.forEach(d => benhNhanData.push({ id: d.id, ...sanitize(d.data()) }));
      }
    }

    // Tạo token và lưu mã nghiệp vụ
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
      message: 'Token đã được tạo. Sử dụng GET /api/benhTruyenNhiem/token/:token để lấy dữ liệu.',
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
    console.log(`📊 Fetching: ${benhNhanIds.length} BN, ${benhTNIds.length} BTN`);

    // Lấy dữ liệu bệnh nhân theo benhNhanId (nếu có)
    const benhNhanData = [];
    if (benhNhanIds.length > 0) {
      const chunks = [];
      for (let i = 0; i < benhNhanIds.length; i += 10) {
        chunks.push(benhNhanIds.slice(i, i + 10));
      }
      
      for (const chunk of chunks) {
        const snap = await db.collection('benhNhan')
          .where('benhNhanId', 'in', chunk)
          .get();
        snap.docs.forEach(d => {
          const data = d.data();
          benhNhanData.push(formatBenhNhanToAPI(data));
        });
      }
    }

    // Lấy dữ liệu bệnh truyền nhiễm theo benhAnId
    const benhTNData = [];
    if (benhTNIds.length > 0) {
      const chunks = [];
      for (let i = 0; i < benhTNIds.length; i += 10) {
        chunks.push(benhTNIds.slice(i, i + 10));
      }
      
      for (const chunk of chunks) {
        const snap = await db.collection('benhTruyenNhiem')
          .where('benhAnId', 'in', chunk)
          .get();
        snap.docs.forEach(d => {
          const data = d.data();
          benhTNData.push(formatBenhTNToAPI(data));
        });
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
