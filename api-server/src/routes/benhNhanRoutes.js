import { Router } from 'express';
import { db } from '../firebase.js';
import { sanitize, getPageSize } from '../utils.js';
import { requireAuth } from '../auth.js';

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
 * Body: { ids: ['id1','id2',...] }
 * Trả về dữ liệu của đúng những bệnh nhân có id trong danh sách
 */
router.post('/byIds', async (req, res) => {
  try {
    const ids = req.body?.ids;
    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ success: false, message: 'Cần truyền mảng ids.' });
    }
    const chunks = [];
    for (let i = 0; i < ids.length; i += 30) chunks.push(ids.slice(i, i + 30));
    const allDocs = [];
    for (const chunk of chunks) {
      const snap = await db.collection('benhNhan').where('__name__', 'in', chunk).get();
      snap.docs.forEach(d => allDocs.push({ id: d.id, ...sanitize(d.data()) }));
    }
    res.json({ success: true, total: allDocs.length, data: allDocs });
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

export default router;
