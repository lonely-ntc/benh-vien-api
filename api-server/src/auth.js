// Xử lý xác thực và JWT
import { createHash } from 'crypto';
import jwt from 'jsonwebtoken';
import { db } from './firebase.js';

const JWT_SECRET   = process.env.JWT_SECRET   || 'benhvien_jwt_secret_change_this';
const JWT_EXPIRES  = process.env.JWT_EXPIRES_IN || '8h';

export const sha256 = str =>
  createHash('sha256').update(str, 'utf8').digest('hex');

// ── Tạo JWT ──────────────────────────────────────────────────────────────────
export function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES });
}

// ── Middleware xác thực JWT ───────────────────────────────────────────────────
export function requireAuth(req, res, next) {
  const auth = req.headers['authorization'] || '';
  if (!auth.startsWith('Bearer ')) {
    return res.status(401).json({
      success: false,
      message: 'Yêu cầu token xác thực. Header: Authorization: Bearer <token>',
    });
  }
  try {
    req.user = jwt.verify(auth.slice(7), JWT_SECRET);
    next();
  } catch (err) {
    const msg = err.name === 'TokenExpiredError'
      ? 'Token đã hết hạn. Vui lòng đăng nhập lại.'
      : 'Token không hợp lệ.';
    res.status(401).json({ success: false, message: msg });
  }
}

// ── Đăng nhập: kiểm tra admin + tài khoản thường ─────────────────────────────
export async function dangNhap(username, password) {
  const u = username.trim();
  const h = sha256(password);

  // 1. Kiểm tra admin
  const adminDoc = await db.collection('adminConfig').doc('admin').get();
  if (adminDoc.exists) {
    const d = adminDoc.data();
    if (u === d.username) {
      if (h !== d.passwordHash) throw { status: 401, message: 'Mật khẩu không đúng.' };
      const token = signToken({ sub: 'admin', username: u, role: 'admin' });
      return { token, role: 'admin', username: u, hoTen: 'Admin' };
    }
  }

  // 2. Kiểm tra tài khoản thường
  const snap = await db.collection('taiKhoan')
    .where('username', '==', u)
    .where('hoatDong', '==', true)
    .limit(1).get();

  if (snap.empty) {
    throw { status: 401, message: 'Tên đăng nhập không tồn tại hoặc bị vô hiệu hóa.' };
  }

  const tk = snap.docs[0].data();
  if (h !== tk.passwordHash) throw { status: 401, message: 'Mật khẩu không đúng.' };

  const token = signToken({
    sub: snap.docs[0].id,
    username: u,
    role: 'user',
    hoTen: tk.hoTen,
  });
  return { token, role: 'user', username: u, hoTen: tk.hoTen };
}
