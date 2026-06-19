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
 *   benhNhanIds: ['BN0001','BN0002',...],  // Mã bệnh nhân
 *   benhTNIds: ['BA0001','BA0002',...]      // Mã bệnh án (optional)
 * }
 * Tạo token dựa trên mã bệnh nhân (benhNhanId) và mã bệnh án (benhAnId)
 * Không phải Firestore document ID
 */
router.post('/byIds', async (req, res) => {
  try {
    const { benhNhanIds = [], benhTNIds = [] } = req.body;
    
    if (!Array.isArray(benhNhanIds) || benhNhanIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền mảng benhNhanIds với ít nhất 1 mã bệnh nhân (VD: BN0001).' 
      });
    }

    // Lấy dữ liệu bệnh nhân theo benhNhanId
    const benhNhanChunks = [];
    for (let i = 0; i < benhNhanIds.length; i += 10) {
      benhNhanChunks.push(benhNhanIds.slice(i, i + 10));
    }
    
    const benhNhanData = [];
    for (const chunk of benhNhanChunks) {
      const snap = await db.collection('benhNhan')
        .where('benhNhanId', 'in', chunk)
        .get();
      snap.docs.forEach(d => benhNhanData.push({ id: d.id, ...sanitize(d.data()) }));
    }

    // Lấy dữ liệu bệnh truyền nhiễm theo benhAnId nếu có
    let benhTNData = [];
    if (benhTNIds.length > 0) {
      const benhTNChunks = [];
      for (let i = 0; i < benhTNIds.length; i += 10) {
        benhTNChunks.push(benhTNIds.slice(i, i + 10));
      }
      
      for (const chunk of benhTNChunks) {
        const snap = await db.collection('benhTruyenNhiem')
          .where('benhAnId', 'in', chunk)
          .get();
        snap.docs.forEach(d => benhTNData.push({ id: d.id, ...sanitize(d.data()) }));
      }
    }

    // Tạo token và lưu mã nghiệp vụ (không phải document ID)
    const token = tokenStore.create({
      benhNhanIds,  // ['BN0001', 'BN0002', ...]
      benhTNIds,    // ['BA0001', 'BA0002', ...]
      timestamp: new Date().toISOString(),
      totalBenhNhan: benhNhanData.length,
      totalBenhTN: benhTNData.length,
    });

    res.json({ 
      success: true, 
      token,
      message: 'Token đã được tạo. Sử dụng GET /api/benhNhan/token/:token để lấy dữ liệu.',
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
  try {
    const dataToken = req.query.token;
    
    if (!dataToken) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền token trong query parameter (?token=xxx)' 
      });
    }
    
    const tokenData = tokenStore.get(dataToken);
    
    if (!tokenData) {
      return res.status(404).json({ 
        success: false, 
        message: 'Token không tồn tại hoặc đã hết hạn.' 
      });
    }

    const { benhNhanIds = [], benhTNIds = [] } = tokenData;

    // Lấy dữ liệu bệnh nhân theo benhNhanId
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

    // Lấy dữ liệu bệnh truyền nhiễm theo benhAnId (nếu có)
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
