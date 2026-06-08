// Tiện ích chung

/** Chuyển Firestore Timestamp → ISO string để JSON hóa được */
export function sanitize(obj) {
  if (obj === null || obj === undefined) return obj;
  if (typeof obj?.toDate === 'function') return obj.toDate().toISOString();
  if (Array.isArray(obj)) return obj.map(sanitize);
  if (typeof obj === 'object') {
    const out = {};
    for (const [k, v] of Object.entries(obj)) out[k] = sanitize(v);
    return out;
  }
  return obj;
}

/** Lấy pageSize từ query (giới hạn tối đa 200) */
export function getPageSize(query) {
  return Math.min(parseInt(query.pageSize || '50', 10) || 50, 200);
}
