import crypto from 'crypto';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'benhvien_jwt_secret_change_this';

/**
 * Lưu trữ và mã hóa dữ liệu bệnh nhân thành token
 * Data Token được mã hóa bằng JWT Secret
 */
class TokenStore {
  constructor() {
    this.TTL = 24 * 60 * 60 * 1000; // 24 hours
  }

  /**
   * Tạo Data Token chứa toàn bộ dữ liệu đã được mã hóa
   * @param {Object} data - { benhNhanData: [], benhTNData: [], ... }
   * @returns {string} encrypted data token
   */
  create(data) {
    const payload = {
      data,
      createdAt: Date.now(),
      expiresAt: Date.now() + this.TTL,
      tokenId: crypto.randomBytes(16).toString('hex'),
    };

    // Mã hóa toàn bộ data thành JWT token
    const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
    
    console.log('🔐 Created encrypted data token:', {
      tokenId: payload.tokenId,
      dataSize: JSON.stringify(data).length,
      expiresIn: '24h'
    });

    return token;
  }

  /**
   * Giải mã Data Token và lấy dữ liệu
   * @param {string} token - Encrypted data token
   * @returns {Object|null} data hoặc null nếu không hợp lệ/hết hạn
   */
  get(token) {
    try {
      // Giải mã JWT token
      const decoded = jwt.verify(token, JWT_SECRET);
      
      // Kiểm tra hết hạn
      if (Date.now() > decoded.expiresAt) {
        console.log('⚠️  Data token expired:', decoded.tokenId);
        return null;
      }

      console.log('✅ Decoded data token:', {
        tokenId: decoded.tokenId,
        createdAt: new Date(decoded.createdAt).toISOString(),
      });

      return decoded.data;
    } catch (err) {
      console.error('❌ Failed to decode data token:', err.message);
      return null;
    }
  }

  /**
   * Xóa token (không cần thiết với JWT - tự hết hạn)
   * @param {string} token
   * @returns {boolean}
   */
  delete(token) {
    // JWT tokens tự hết hạn, không cần xóa thủ công
    console.log('ℹ️  Data token will auto-expire (JWT-based)');
    return true;
  }

  /**
   * Lấy thông tin token
   * @param {string} token
   * @returns {Object|null}
   */
  getInfo(token) {
    try {
      const decoded = jwt.verify(token, JWT_SECRET);
      
      if (Date.now() > decoded.expiresAt) {
        return null;
      }

      return {
        tokenId: decoded.tokenId,
        createdAt: new Date(decoded.createdAt).toISOString(),
        expiresAt: new Date(decoded.expiresAt).toISOString(),
        isValid: true,
        dataSize: JSON.stringify(decoded.data).length,
      };
    } catch (err) {
      return null;
    }
  }
}

// Singleton instance
export const tokenStore = new TokenStore();
