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
 * 
 * Tạo Data Token chứa toàn bộ dữ liệu bệnh truyền nhiễm đã mã hóa
 * Token này sẽ được giải mã bằng JWT Secret khi lấy dữ liệu
 */
router.post('/byIds', async (req, res) => {
  try {
    const { benhNhanIds = [], benhTNIds = [] } = req.body;
    
    console.log('📥 POST /byIds - Creating data token for:', {
      benhNhanIds: benhNhanIds.length,
      benhTNIds: benhTNIds.length,
      user: req.user.username,
    });
    
    if (!Array.isArray(benhTNIds) || benhTNIds.length === 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền mảng benhTNIds với ít nhất 1 mã bệnh án (VD: BA0001).' 
      });
    }

    // ═══ Lấy dữ liệu bệnh truyền nhiễm từ Firestore ═══
    const benhTNChunks = [];
    for (let i = 0; i < benhTNIds.length; i += 10) {
      benhTNChunks.push(benhTNIds.slice(i, i + 10));
    }
    
    const benhTNData = [];
    for (const chunk of benhTNChunks) {
      console.log('🔍 Querying benhTruyenNhiem where benhAnId in:', chunk);
      const snap = await db.collection('benhTruyenNhiem')
        .where('benhAnId', 'in', chunk)
        .get();
      console.log(`✅ Found ${snap.size} documents`);
      snap.docs.forEach(d => {
        const data = d.data();
        // Format data theo chuẩn API
        benhTNData.push(formatBenhTNToAPI(data));
      });
    }

    // ═══ Lấy dữ liệu bệnh nhân nếu có ═══
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
        snap.docs.forEach(d => {
          const data = d.data();
          benhNhanData.push(formatBenhNhanToAPI(data));
        });
      }
    }

    console.log(`📊 Data retrieved: ${benhNhanData.length} bệnh nhân, ${benhTNData.length} bệnh TN`);

    // ═══ Tạo Data Token chứa toàn bộ dữ liệu đã được mã hóa ═══
    const token = tokenStore.create({
      type: 'data_token',
      benhNhan: benhNhanData,
      benhTruyenNhiem: benhTNData,
      metadata: {
        requestedBenhNhanIds: benhNhanIds,
        requestedBenhTNIds: benhTNIds,
        createdBy: req.user.username,
        timestamp: new Date().toISOString(),
      }
    });

    res.json({ 
      success: true, 
      token,
      message: 'Data token đã tạo. Sử dụng GET /api/benhTruyenNhiem/thongtinbenhan?token=xxx với JWT token trong header để lấy dữ liệu.',
      summary: {
        benhNhanCount: benhNhanData.length,
        benhTNCount: benhTNData.length,
        requestedBenhNhan: benhNhanIds.length,
        requestedBenhTN: benhTNIds.length,
        notFoundBenhNhan: benhNhanIds.length - benhNhanData.length,
        notFoundBenhTN: benhTNIds.length - benhTNData.length,
      },
      expiresIn: '24 giờ',
      note: 'Data token được mã hóa bằng JWT Secret. Cần JWT token để giải mã.',
    });
  } catch (e) {
    console.error('❌ Error in /byIds:', e);
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
 * Query: token=xxx (encrypted data token)
 * Header: Authorization: Bearer <JWT_TOKEN> (để xác thực và giải mã)
 * 
 * Lấy dữ liệu bệnh truyền nhiễm đã được mã hóa trong Data Token
 * JWT Token được dùng để:
 * 1. Xác thực người dùng
 * 2. Giải mã Data Token (vì Data Token được mã hóa bằng JWT Secret)
 */
router.get('/thongtinbenhan', async (req, res) => {
  console.log('📥 GET /thongtinbenhan');
  console.log('   Query token:', req.query.token?.substring(0, 20) + '...');
  console.log('   User:', req.user.username);
  
  try {
    const dataToken = req.query.token;
    
    if (!dataToken) {
      console.log('❌ Missing token parameter');
      return res.status(400).json({ 
        success: false, 
        message: 'Cần truyền data token trong query parameter (?token=xxx)' 
      });
    }
    
    // Giải mã Data Token (sử dụng JWT Secret)
    const tokenData = tokenStore.get(dataToken);
    console.log('🔍 Token data:', tokenData ? 'Decoded successfully' : 'Failed to decode');
    
    if (!tokenData) {
      return res.status(404).json({ 
        success: false, 
        message: 'Data token không hợp lệ, đã hết hạn, hoặc không thể giải mã. Vui lòng tạo token mới.' 
      });
    }

    // Kiểm tra token type
    if (tokenData.type !== 'data_token') {
      return res.status(400).json({ 
        success: false, 
        message: 'Token không đúng định dạng.' 
      });
    }

    const { benhNhan = [], benhTruyenNhiem = [], metadata = {} } = tokenData;
    
    console.log(`✅ Returning encrypted data: ${benhNhan.length} BN, ${benhTruyenNhiem.length} BTN`);
    console.log(`   Created by: ${metadata.createdBy}, at: ${metadata.timestamp}`);

    res.json({ 
      success: true,
      message: 'Dữ liệu đã được giải mã thành công',
      data: {
        benhNhan,
        benhTruyenNhiem,
      },
      metadata: {
        createdBy: metadata.createdBy,
        createdAt: metadata.timestamp,
        requestedBenhNhanIds: metadata.requestedBenhNhanIds,
        requestedBenhTNIds: metadata.requestedBenhTNIds,
      },
      summary: {
        benhNhanCount: benhNhan.length,
        benhTNCount: benhTruyenNhiem.length,
        total: benhNhan.length + benhTruyenNhiem.length,
      }
    });
  } catch (e) {
    console.error('❌ Error in /thongtinbenhan:', e);
    res.status(500).json({ success: false, message: e.message });
  }
});

export default router;
