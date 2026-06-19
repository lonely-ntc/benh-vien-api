import crypto from 'crypto';

/**
 * Lưu trữ token và dữ liệu đã chọn trong bộ nhớ
 * Trong production nên dùng Redis hoặc database
 */
class TokenStore {
  constructor() {
    this.store = new Map();
    // Tự động xóa token sau 24 giờ
    this.TTL = 24 * 60 * 60 * 1000; // 24 hours
  }

  /**
   * Tạo token mới và lưu dữ liệu
   * @param {Object} data - { benhNhanIds: [], benhTNIds: [] }
   * @returns {string} token
   */
  create(data) {
    const token = crypto.randomBytes(32).toString('hex');
    const expiresAt = Date.now() + this.TTL;
    
    this.store.set(token, {
      data,
      createdAt: Date.now(),
      expiresAt,
    });

    // Tự động xóa sau TTL
    setTimeout(() => {
      this.store.delete(token);
    }, this.TTL);

    return token;
  }

  /**
   * Lấy dữ liệu từ token
   * @param {string} token
   * @returns {Object|null} data hoặc null nếu không tồn tại/hết hạn
   */
  get(token) {
    const entry = this.store.get(token);
    if (!entry) return null;

    // Kiểm tra hết hạn
    if (Date.now() > entry.expiresAt) {
      this.store.delete(token);
      return null;
    }

    return entry.data;
  }

  /**
   * Xóa token
   * @param {string} token
   * @returns {boolean} true nếu xóa thành công
   */
  delete(token) {
    return this.store.delete(token);
  }

  /**
   * Lấy thông tin token (bao gồm metadata)
   * @param {string} token
   * @returns {Object|null}
   */
  getInfo(token) {
    const entry = this.store.get(token);
    if (!entry) return null;

    if (Date.now() > entry.expiresAt) {
      this.store.delete(token);
      return null;
    }

    return {
      data: entry.data,
      createdAt: new Date(entry.createdAt).toISOString(),
      expiresAt: new Date(entry.expiresAt).toISOString(),
      isValid: true,
    };
  }

  /**
   * Lấy số lượng token đang lưu
   * @returns {number}
   */
  size() {
    return this.store.size;
  }
}

// Singleton instance
export const tokenStore = new TokenStore();
