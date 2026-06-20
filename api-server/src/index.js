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
      'GET  /api/benhNhan':                             'Xem tất cả bệnh nhân [JWT]',
      'POST /api/benhNhan/byIds':                       'Tạo data token mã hóa từ benhNhanIds [JWT]',
      'GET  /api/benhNhan/thongtinbenhnhan?token=xxx':  'Giải mã data token và lấy dữ liệu [JWT]',
      
      '=== BỆNH TRUYỀN NHIỄM ===': '',
      'GET  /api/benhTruyenNhiem':                      'Xem tất cả bệnh truyền nhiễm [JWT]',
      'POST /api/benhTruyenNhiem/byIds':                'Tạo data token từ benhAnIds [JWT]',
      'GET  /api/benhTruyenNhiem/thongtinbenhan?token=xxx': 'Giải mã data token và lấy dữ liệu [JWT]',
      
      '=== DANH MỤC ===': '',
      'GET  /api/danhMuc/:collection':                  'Lấy danh mục (gioiTinh, danToc, benhNen...) [JWT]',
    },
  });
});

// ── 404 handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  console.log(`⚠️  404 Not Found: ${req.method} ${req.path}`);
  res.status(404).json({ success: false, message: `Endpoint "${req.path}" không tồn tại.` });
});

// ── Error handler ─────────────────────────────────────────────────────────────
app.use((err, req, res, _next) => {
  console.error('❌ Server Error:', err);
  // Đảm bảo luôn trả về JSON
  if (!res.headersSent) {
    res.status(500).json({ success: false, message: 'Lỗi server nội bộ.', error: err.message });
  }
});

// ── Khởi động ─────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🚀  Bệnh Viện API đang chạy tại http://localhost:${PORT}`);
  console.log(`    Docs: GET http://localhost:${PORT}/\n`);
});
