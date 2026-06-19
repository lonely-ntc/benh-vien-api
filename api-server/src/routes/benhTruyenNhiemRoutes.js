import { Router } from 'express';
import { db } from '../firebase.js';
import { sanitize, getPageSize } from '../utils.js';
import { requireAuth } from '../auth.js';
import { tokenStore } from '../tokenStore.js';

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
 *   benhNhanIds: ['id1','id2',...] (optional),
 *   benhTNIds: ['id1','id2',...] (required)
 * }
 * Tạo token và trả về token để có thể lấy dữ liệu sau này
 */
router.post('/byIds', async (req, res) => {
  try {
    const { benhNhanIds = [], benhTNIds = [] } = req.body;
    
    if (!Array.isArray(benhTNIds) || benhTNIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền mảng benhTNIds với ít nhất 1 id.' 
      });
    }

    // Lấy dữ liệu bệnh truyền nhiễm
    const benhTNChunks = [];
    for (let i = 0; i < benhTNIds.length; i += 30) {
      benhTNChunks.push(benhTNIds.slice(i, i + 30));
    }
    
    const benhTNData = [];
    for (const chunk of benhTNChunks) {
      const snap = await db.collection('benhTruyenNhiem').where('__name__', 'in', chunk).get();
      snap.docs.forEach(d => benhTNData.push({ id: d.id, ...sanitize(d.data()) }));
    }

    // Lấy dữ liệu bệnh nhân nếu có
    let benhNhanData = [];
    if (benhNhanIds.length > 0) {
      const benhNhanChunks = [];
      for (let i = 0; i < benhNhanIds.length; i += 30) {
        benhNhanChunks.push(benhNhanIds.slice(i, i + 30));
      }
      
      for (const chunk of benhNhanChunks) {
        const snap = await db.collection('benhNhan').where('__name__', 'in', chunk).get();
        snap.docs.forEach(d => benhNhanData.push({ id: d.id, ...sanitize(d.data()) }));
      }
    }

    // Tạo token và lưu IDs
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
        totalIds: benhNhanIds.length + benhTNIds.length,
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
 * GET /api/benhTruyenNhiem/token/:token
 * Lấy dữ liệu bệnh nhân và bệnh truyền nhiễm theo token đã tạo
 */
router.get('/token/:token', async (req, res) => {
  try {
    const tokenData = tokenStore.get(req.params.token);
    
    if (!tokenData) {
      return res.status(404).json({ 
        success: false, 
        message: 'Token không tồn tại hoặc đã hết hạn.' 
      });
    }

    const { benhNhanIds = [], benhTNIds = [] } = tokenData;

    // Lấy dữ liệu bệnh nhân
    const benhNhanData = [];
    if (benhNhanIds.length > 0) {
      const chunks = [];
      for (let i = 0; i < benhNhanIds.length; i += 30) {
        chunks.push(benhNhanIds.slice(i, i + 30));
      }
      
      for (const chunk of chunks) {
        const snap = await db.collection('benhNhan').where('__name__', 'in', chunk).get();
        snap.docs.forEach(d => benhNhanData.push({ id: d.id, ...sanitize(d.data()) }));
      }
    }

    // Lấy dữ liệu bệnh truyền nhiễm
    const benhTNData = [];
    if (benhTNIds.length > 0) {
      const chunks = [];
      for (let i = 0; i < benhTNIds.length; i += 30) {
        chunks.push(benhTNIds.slice(i, i + 30));
      }
      
      for (const chunk of chunks) {
        const snap = await db.collection('benhTruyenNhiem').where('__name__', 'in', chunk).get();
        snap.docs.forEach(d => benhTNData.push({ id: d.id, ...sanitize(d.data()) }));
      }
    }

    res.json({ 
      success: true,
      token: req.params.token,
      timestamp: tokenData.timestamp,
      data: {
        benhNhan: benhNhanData,
        benhTruyenNhiem: benhTNData,
      },
      summary: {
        benhNhanCount: benhNhanData.length,
        benhTNCount: benhTNData.length,
        total: benhNhanData.length + benhTNData.length,
      }
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

/**
 * GET /api/benhTruyenNhiem/token/:token/info
 * Lấy thông tin về token (không lấy dữ liệu)
 */
router.get('/token/:token/info', async (req, res) => {
  try {
    const info = tokenStore.getInfo(req.params.token);
    
    if (!info) {
      return res.status(404).json({ 
        success: false, 
        message: 'Token không tồn tại hoặc đã hết hạn.' 
      });
    }

    res.json({ 
      success: true,
      token: req.params.token,
      ...info,
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

export default router;
