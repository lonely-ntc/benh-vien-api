import { Router } from 'express';
import { dangNhap } from '../auth.js';

const router = Router();

/**
 * POST /api/auth/login
 * Body: { "username": "...", "password": "..." }
 * Response: { success, token, expiresIn, role, username, hoTen }
 */
router.post('/login', async (req, res) => {
  const { username, password } = req.body || {};

  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng cung cấp username và password.',
    });
  }

  try {
    const result = await dangNhap(username, password);
    res.json({
      success: true,
      message: 'Đăng nhập thành công.',
      token: result.token,
      expiresIn: process.env.JWT_EXPIRES_IN || '8h',
      role: result.role,
      username: result.username,
      hoTen: result.hoTen,
    });
  } catch (err) {
    res.status(err.status || 500).json({
      success: false,
      message: err.message || 'Lỗi server.',
    });
  }
});

export default router;
