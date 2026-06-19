import 'dotenv/config';
import express from 'express';
import cors from 'cors';

import authRoutes        from './routes/authRoutes.js';
import benhNhanRoutes    from './routes/benhNhanRoutes.js';
import benhTNRoutes      from './routes/benhTruyenNhiemRoutes.js';
import danhMucRoutes     from './routes/danhMucRoutes.js';

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// Log mỗi request
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// ── Routes ────────────────────────────────────────────────────────────────────
app.use('/api/auth',             authRoutes);
app.use('/api/benhNhan',         benhNhanRoutes);
app.use('/api/benhTruyenNhiem',  benhTNRoutes);
app.use('/api/danhMuc',          danhMucRoutes);

// ── Health check (không cần JWT) ─────────────────────────────────────────────
app.get('/', (_req, res) => {
  res.json({
    service: 'Bệnh Viện API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      'POST /api/auth/login':                           'Đăng nhập → JWT Token chung',
      
      '=== BỆNH NHÂN ===': '',
      'GET  /api/benhNhan':                             'Tất cả bệnh nhân (phân trang) [JWT]',
      'GET  /api/benhNhan/tatca':                       'Tất cả bệnh nhân (không phân trang) [JWT]',
      'POST /api/benhNhan/byIds':                       'Tạo data token từ mã bệnh nhân (benhNhanId) [JWT]',
      'GET  /api/benhNhan/thongtinbenhnhan?token=xxx':  'Lấy dữ liệu đã chọn theo data token [JWT]',
      'POST /api/benhNhan/push':                        'Thêm/cập nhật bệnh nhân [JWT]',
      'GET  /api/benhNhan/:id':                         'Lấy 1 bệnh nhân theo Firestore ID [JWT]',
      
      '=== BỆNH TRUYỀN NHIỄM ===': '',
      'GET  /api/benhTruyenNhiem':                      'Tất cả bệnh TN (phân trang) [JWT]',
      'GET  /api/benhTruyenNhiem/tatca':                'Tất cả bệnh TN (không phân trang) [JWT]',
      'POST /api/benhTruyenNhiem/byIds':                'Tạo data token từ mã bệnh án (benhAnId) [JWT]',
      'GET  /api/benhTruyenNhiem/thongtinbenhan?token=xxx': 'Lấy dữ liệu đã chọn theo data token [JWT]',
      'POST /api/benhTruyenNhiem/push':                 'Thêm/cập nhật bệnh TN [JWT]',
      'GET  /api/benhTruyenNhiem/:id':                  'Lấy 1 ca bệnh theo Firestore ID [JWT]',
      
      '=== DANH MỤC ===': '',
      'GET  /api/danhMuc/:collection':                  'Lấy danh mục (gioiTinh, danToc, benhNen...) [JWT]',
    },
  });
});

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Endpoint "${req.path}" không tồn tại.` });
});

// ── Error handler ─────────────────────────────────────────────────────────────
app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ success: false, message: 'Lỗi server nội bộ.' });
});

// ── Khởi động ─────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🚀  Bệnh Viện API đang chạy tại http://localhost:${PORT}`);
  console.log(`    Docs: GET http://localhost:${PORT}/\n`);
});
