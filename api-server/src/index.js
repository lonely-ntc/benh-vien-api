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
      'POST /api/auth/login':              'Đăng nhập → JWT Token',
      'GET  /api/benhNhan':                'Danh sách bệnh nhân  [JWT]',
      'GET  /api/benhNhan/:id':            'Chi tiết bệnh nhân   [JWT]',
      'GET  /api/benhTruyenNhiem':         'Danh sách bệnh TN    [JWT]',
      'GET  /api/benhTruyenNhiem/:id':     'Chi tiết bệnh TN     [JWT]',
      'GET  /api/danhMuc':                 'Tất cả danh mục      [JWT]',
      'GET  /api/danhMuc/:code':           'Danh mục theo code   [JWT]',
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
