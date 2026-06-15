import { Router } from 'express';
import { db } from '../firebase.js';
import { sanitize, getPageSize } from '../utils.js';
import { requireAuth } from '../auth.js';

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
 * Query: pageSize=50, startAfter=<docId>, chanDoanBenh=<string>, ketQuaXN=<string>
 */
router.get('/', async (req, res) => {
  try {
    const pageSize = getPageSize(req.query);
    let q = db.collection('benhTruyenNhiem').orderBy('ngayTao', 'desc').limit(pageSize);

    // Lọc theo chẩn đoán hoặc kết quả XN nếu có
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

export default router;
