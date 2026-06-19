/**
 * migrate_ids.js
 * Migrate dữ liệu Firestore: chuyển các trường danh mục từ string tên
 * sang Map {id, name} để khớp chuẩn API.
 *
 * Chạy: node migrate_ids.js
 * (từ thư mục api-server/)
 */

import 'dotenv/config';
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getFirestore, FieldValue }      from 'firebase-admin/firestore';
import { readFileSync, existsSync }      from 'fs';
import { resolve, dirname }              from 'path';
import { fileURLToPath }                 from 'url';

// ── Khởi tạo Firebase ────────────────────────────────────────────────────────
if (getApps().length === 0) {
  const __dir = dirname(fileURLToPath(import.meta.url));
  const saPath = resolve(__dir, 'service-account.json');
  if (!existsSync(saPath)) {
    console.error('❌  Không tìm thấy service-account.json'); process.exit(1);
  }
  initializeApp({ credential: cert(JSON.parse(readFileSync(saPath, 'utf8'))) });
}
const db = getFirestore();

// ── Danh mục chuẩn — {tên: {id, name}} ─────────────────────────────────────

const mkMap = (arr) => {
  const m = {};
  arr.forEach(({ Id, Name }) => { m[Name.toLowerCase().trim()] = { id: Id, name: Name }; });
  return m;
};

const GIOI_TINH = mkMap([{ Id: 262, Name: 'Nữ' }, { Id: 263, Name: 'Nam' }]);

const CO_KHONG = mkMap([
  { Id: 11134, Name: 'Có' }, { Id: 11135, Name: 'Không' }, { Id: 11137, Name: 'Không rõ' },
]);

const DAN_TOC = mkMap([
  { Id: 15, Name: 'Kinh' }, { Id: 16, Name: 'Tày' }, { Id: 17, Name: 'Thái' },
  { Id: 18, Name: 'Hoa' }, { Id: 19, Name: 'Khme' }, { Id: 20, Name: 'Mường' },
  { Id: 21, Name: 'Nùng' }, { Id: 22, Name: 'Hán' }, { Id: 23, Name: 'Dao' },
  { Id: 24, Name: 'Gia rai' }, { Id: 25, Name: 'Cao lan' }, { Id: 26, Name: 'Ê đê' },
  { Id: 27, Name: 'Ba na' }, { Id: 28, Name: 'Xơ đăng' }, { Id: 29, Name: 'Sán Chay' },
  { Id: 30, Name: 'Cơ ho' }, { Id: 31, Name: 'Chăm' }, { Id: 32, Name: 'Sán chỉ' },
  { Id: 33, Name: 'Hrê' }, { Id: 34, Name: 'M nông' }, { Id: 35, Name: 'Raglai' },
  { Id: 36, Name: 'Xtiêng' }, { Id: 37, Name: 'Bru (Khùa)' }, { Id: 38, Name: 'Thổ' },
  { Id: 39, Name: 'Giấy' }, { Id: 40, Name: 'Cơ Tu' }, { Id: 41, Name: 'Giẻ Triêng' },
  { Id: 42, Name: 'Mạ' }, { Id: 43, Name: 'Khơ mú' }, { Id: 44, Name: 'Co (Cùa)' },
  { Id: 45, Name: 'Tà ôi' }, { Id: 46, Name: 'Chơ-ro' }, { Id: 47, Name: 'Kháng' },
  { Id: 48, Name: 'Xinh mun' }, { Id: 49, Name: 'Hà nhì' }, { Id: 50, Name: 'Chu ru' },
  { Id: 51, Name: 'Lào' }, { Id: 52, Name: 'La chí' }, { Id: 53, Name: 'La ha' },
  { Id: 54, Name: 'Phù lá' }, { Id: 55, Name: 'La hụ' }, { Id: 56, Name: 'Lự' },
  { Id: 57, Name: 'Lô Lô' }, { Id: 58, Name: 'Cà Doòng' }, { Id: 59, Name: 'Mảng' },
  { Id: 60, Name: 'Pà thẻn' }, { Id: 61, Name: 'Cờ lao' }, { Id: 62, Name: 'Cống' },
  { Id: 63, Name: 'Bố Y' }, { Id: 64, Name: 'Si la' }, { Id: 65, Name: 'Pu piéo' },
  { Id: 66, Name: 'Brâu' }, { Id: 67, Name: 'Ơ đu' }, { Id: 68, Name: 'Rơ măm' },
  { Id: 1037, Name: 'Mông' }, { Id: 1038, Name: 'Sán dìu' },
  { Id: 1040, Name: 'Khác trong nước' }, { Id: 1033, Name: 'Nước ngoài' },
  // Alias tên cũ
  { Id: 19, Name: 'Khmer' }, { Id: 19, Name: 'Khơ me' },
  { Id: 1040, Name: 'Khác' },  // "Khác" dân tộc → Khác trong nước
]);

const DIEU_TRI = mkMap([
  { Id: 11143, Name: 'Thở oxy' }, { Id: 11144, Name: 'Thở NCPAP' },
  { Id: 11145, Name: 'Thở máy' }, { Id: 11146, Name: 'IVIG' },
  { Id: 11203, Name: 'Không hỗ trợ hô hấp' },
  // Alias tên cũ (DieuTri dùng string không có id)
  { Id: 11203, Name: 'Ngoại trú' }, { Id: 11143, Name: 'Nội trú' },
  { Id: 11203, Name: 'Theo dõi' }, { Id: 11203, Name: 'Cấp cứu' },
  { Id: 11203, Name: 'Phẫu thuật' },  // "Phẫu thuật" → Không hỗ trợ hô hấp
]);

const HINH_THUC_DIEU_TRI = mkMap([
  { Id: 11128, Name: 'Điều trị nội trú' }, { Id: 11129, Name: 'Điều trị ngoại trú' },
  { Id: 11130, Name: 'Ra viện' }, { Id: 11131, Name: 'Tử vong' },
  { Id: 11132, Name: 'Chuyển viện' }, { Id: 11133, Name: 'Tình trạng khác' },
  { Id: 11544, Name: 'Nặng xin về' },
  // Alias tên cũ từ danhMucRoutes cũ
  { Id: 11129, Name: 'Ngoại trú' }, { Id: 11128, Name: 'Nội trú' },
  { Id: 11133, Name: 'Phẫu thuật' }, { Id: 11133, Name: 'Vật lý trị liệu' },
  { Id: 11133, Name: 'Hóa trị' }, { Id: 11133, Name: 'Kết hợp' },
  { Id: 11133, Name: 'Dùng thuốc' }, { Id: 11133, Name: 'Xạ trị' },
  { Id: 11133, Name: 'Khác' },
]);

const CHAN_DOAN_BENH = mkMap([
  { Id: 1, Name: 'Bại liệt' }, { Id: 2, Name: 'Bạch hầu' },
  { Id: 3, Name: 'Bệnh do liên cầu lợn ở người' }, { Id: 4, Name: 'Cúm A(H5N1)' },
  { Id: 5, Name: 'Cúm A(H7N9)' }, { Id: 6, Name: 'Dịch hạch' },
  { Id: 7, Name: 'Ê-bô-la (Ebolla)' }, { Id: 8, Name: 'Lát-sa (Lassa)' },
  { Id: 9, Name: 'Mác-bớt (Marburg)' }, { Id: 10, Name: 'Rubella (Rubeon)' },
  { Id: 11, Name: 'Sốt Tây sông Nin' }, { Id: 12, Name: 'Sốt vàng' },
  { Id: 13, Name: 'Sốt xuất huyết Dengue' }, { Id: 14, Name: 'Sởi' },
  { Id: 15, Name: 'Tả' }, { Id: 16, Name: 'Tay - chân - miệng' },
  { Id: 17, Name: 'Than' }, { Id: 18, Name: 'Viêm đường hô hấp Trung đông do corona vi rút (MERS-CoV)' },
  { Id: 19, Name: 'Nhiễm trùng do não mô cầu' }, { Id: 20, Name: 'Zika' },
  { Id: 21, Name: 'Covid-19' }, { Id: 23, Name: 'Mpox' },
  { Id: 24, Name: 'Bệnh truyền nhiễm nguy hiểm mới nổi và bệnh mới phát sinh chưa rõ tác nhân gây bệnh' },
  { Id: 25, Name: 'Dại' }, { Id: 26, Name: 'Ho gà' },
  { Id: 27, Name: 'Liệt mềm cấp nghi bại liệt' }, { Id: 28, Name: 'Lao phổi' },
  { Id: 29, Name: 'Sốt rét' }, { Id: 34, Name: 'Thương hàn' },
  { Id: 35, Name: 'Uốn ván sơ sinh' }, { Id: 36, Name: 'Uốn ván khác' },
  { Id: 38, Name: 'Viêm gan vi rút A' }, { Id: 39, Name: 'Viêm gan vi rút B' },
  { Id: 40, Name: 'Viêm gan vi rút C' }, { Id: 41, Name: 'Viêm não Nhật Bản' },
  { Id: 42, Name: 'Viêm não vi rút khác' }, { Id: 45, Name: 'Xoắn khuẩn vàng da (Leptospira)' },
  { Id: 46, Name: 'Bệnh do vi rút Adeno' }, { Id: 50, Name: 'Cúm' },
  { Id: 51, Name: 'Lỵ amíp' }, { Id: 52, Name: 'Lỵ trực trùng' },
  { Id: 53, Name: 'Quai bị' }, { Id: 54, Name: 'Thủy đậu' },
  { Id: 55, Name: 'Tiêu chảy' }, { Id: 56, Name: 'Viêm gan vi rút khác (hoặc không có định típ vi rút)' },
  { Id: 57, Name: 'Thay đổi chẩn đoán, bệnh không có trong danh mục' },
  { Id: 58, Name: 'Chikungunya' }, { Id: 59, Name: 'Bệnh do vi rút Nipah' },
  // Alias tên cũ
  { Id: 13, Name: 'Sốt xuất huyết' }, { Id: 16, Name: 'Tay chân miệng' },
  { Id: 39, Name: 'Viêm gan B' }, { Id: 40, Name: 'Viêm gan C' },
  { Id: 21, Name: 'COVID-19' }, { Id: 28, Name: 'Lao' },
  { Id: 23, Name: 'HIV/AIDS' }, // HIV/AIDS dùng id ChanDoan phổ biến
  // Tên không khớp chính xác → fallback sang mục gần nhất
  { Id: 57, Name: 'Xơ gan' },       // Xơ gan là bệnh nền, không phải bệnh TN → Thay đổi chẩn đoán
  { Id: 57, Name: 'Gãy xương' },
  { Id: 57, Name: 'Viêm phổi' },
  { Id: 57, Name: 'Tiểu đường type 2' },
  { Id: 57, Name: 'Nhồi máu cơ tim' },
  { Id: 57, Name: 'Đột quỵ' },
  { Id: 57, Name: 'Ung thư phổi' },
  { Id: 57, Name: 'Sỏi thận' },
  { Id: 57, Name: 'Viêm ruột thừa' },
  { Id: 57, Name: 'Hen suyễn' },
  { Id: 57, Name: 'COPD' },
  { Id: 57, Name: 'Suy tim' },
  { Id: 57, Name: 'Tăng huyết áp' },
  { Id: 57, Name: 'Lao phổi' },
  { Id: 57, Name: 'Không' },  // "Không" bệnh TN → Thay đổi chẩn đoán
]);

const PHAN_DO_BENH = mkMap([
  { Id: 1, Name: 'Sốt xuất huyết Dengue' },
  { Id: 2, Name: 'Sốt xuất huyết Dengue có dấu hiệu cảnh báo' },
  { Id: 3, Name: 'Sốt xuất huyết Dengue nặng' },
  { Id: 4, Name: 'Độ 1' }, { Id: 5, Name: 'Độ 2a' }, { Id: 6, Name: 'Độ 2b' },
  { Id: 7, Name: 'Độ 3' }, { Id: 8, Name: 'Độ 4' },
  // Alias tên cũ
  { Id: 4, Name: 'Nhẹ' }, { Id: 5, Name: 'Trung bình' },
  { Id: 7, Name: 'Nặng' }, { Id: 8, Name: 'Nguy kịch' },
]);

const PHAN_LOAI_CHAN_DOAN = mkMap([
  { Id: 11545, Name: 'Có thể' }, { Id: 11546, Name: 'Nghi ngờ (lâm sàng)' },
  { Id: 11547, Name: 'Xác định phòng xét nghiệm' },
  // Alias tên cũ
  { Id: 11547, Name: 'Xác định' }, { Id: 11546, Name: 'Nghi ngờ' },
  { Id: 11545, Name: 'Có thể' }, { Id: 11547, Name: 'Loại trừ' },
]);

const LOAI_BENH_PHAM = mkMap([
  { Id: 11548, Name: 'Máu' }, { Id: 11549, Name: 'Phân' },
  { Id: 11550, Name: 'Dịch ngoáy họng' }, { Id: 11551, Name: 'Dịch tỵ hầu' },
  { Id: 11552, Name: 'Dịch sang thương da' }, { Id: 11553, Name: 'Dịch não tủy' },
  { Id: 11554, Name: 'Nước tiểu' },
  // Alias tên cũ
  { Id: 11550, Name: 'Dịch họng' }, { Id: 11551, Name: 'Dịch mũi' },
  { Id: 11549, Name: 'Đàm' },  // Đàm ~ Phân trong danh mục cũ, map sang Phân
  // LoaiXN cũ (PCR, Test nhanh...) → map sang loại bệnh phẩm tương ứng
  { Id: 11548, Name: 'PCR' },
  { Id: 11548, Name: 'Test nhanh kháng nguyên' },
  { Id: 11548, Name: 'Huyết học' },
  { Id: 11548, Name: 'Sinh hóa' },
  { Id: 11548, Name: 'Vi sinh' },
  { Id: 11548, Name: 'Giải phẫu bệnh' },
  { Id: 11548, Name: 'CT scan' },
  { Id: 11548, Name: 'X-quang' },
  { Id: 11548, Name: 'Siêu âm' },
  { Id: 11548, Name: 'MRI' },
  { Id: 11548, Name: 'Khác' },
]);

const KET_QUA_XN = mkMap([
  { Id: 11140, Name: 'Dương tính' }, { Id: 11141, Name: 'Âm tính' },
  { Id: 11142, Name: 'Chưa có kết quả' },
  // Alias tên cũ
  { Id: 11142, Name: 'Nghi ngờ' }, { Id: 11142, Name: 'Chờ kết quả' },
]);

const TINH_TRANG_TIEM = mkMap([
  { Id: 11134, Name: 'Có' }, { Id: 11135, Name: 'Không' }, { Id: 11137, Name: 'Không rõ' },
  // Alias tên cũ
  { Id: 11134, Name: 'Tiêm 1 mũi' }, { Id: 11134, Name: 'Tiêm 2 mũi' },
  { Id: 11134, Name: 'Tiêm 3 mũi' }, { Id: 11134, Name: 'Tiêm nhắc lại' },
  { Id: 11135, Name: 'Chưa tiêm' },
]);

const TINH = mkMap([
  { Id: 1, Name: 'Thành phố Hà Nội' }, { Id: 3, Name: 'Tỉnh Cao Bằng' },
  { Id: 5, Name: 'Tỉnh Tuyên Quang' }, { Id: 6, Name: 'Tỉnh Lào Cai' },
  { Id: 7, Name: 'Tỉnh Điện Biên' }, { Id: 8, Name: 'Tỉnh Lai Châu' },
  { Id: 9, Name: 'Tỉnh Sơn La' }, { Id: 12, Name: 'Tỉnh Thái Nguyên' },
  { Id: 13, Name: 'Tỉnh Lạng Sơn' }, { Id: 14, Name: 'Tỉnh Quảng Ninh' },
  { Id: 16, Name: 'Tỉnh Phú Thọ' }, { Id: 18, Name: 'Tỉnh Bắc Ninh' },
  { Id: 20, Name: 'Thành phố Hải Phòng' }, { Id: 21, Name: 'Tỉnh Hưng Yên' },
  { Id: 25, Name: 'Tỉnh Ninh Bình' }, { Id: 26, Name: 'Tỉnh Thanh Hóa' },
  { Id: 27, Name: 'Tỉnh Nghệ An' }, { Id: 28, Name: 'Tỉnh Hà Tĩnh' },
  { Id: 30, Name: 'Tỉnh Quảng Trị' }, { Id: 31, Name: 'Thành phố Huế' },
  { Id: 32, Name: 'Thành phố Đà Nẵng' }, { Id: 34, Name: 'Tỉnh Quảng Ngãi' },
  { Id: 37, Name: 'Tỉnh Khánh Hòa' }, { Id: 41, Name: 'Tỉnh Gia Lai' },
  { Id: 42, Name: 'Tỉnh Đắk Lắk' }, { Id: 44, Name: 'Tỉnh Lâm Đồng' },
  { Id: 46, Name: 'Tỉnh Tây Ninh' }, { Id: 48, Name: 'Tỉnh Đồng Nai' },
  { Id: 50, Name: 'Thành Phố Hồ Chí Minh' }, { Id: 55, Name: 'Tỉnh Vĩnh Long' },
  { Id: 56, Name: 'Tỉnh Đồng Tháp' }, { Id: 57, Name: 'Tỉnh An Giang' },
  { Id: 59, Name: 'Thành phố Cần Thơ' }, { Id: 63, Name: 'Tỉnh Cà Mau' },
  // Alias tên ngắn (dữ liệu cũ lưu tên ngắn không có "Tỉnh/Thành phố")
  { Id: 1,  Name: 'Hà Nội' }, { Id: 20, Name: 'Hải Phòng' },
  { Id: 32, Name: 'Đà Nẵng' }, { Id: 50, Name: 'TP. Hồ Chí Minh' },
  { Id: 50, Name: 'Hồ Chí Minh' }, { Id: 50, Name: 'TP HCM' },
  { Id: 59, Name: 'Cần Thơ' }, { Id: 27, Name: 'Nghệ An' },
  { Id: 26, Name: 'Thanh Hóa' }, { Id: 37, Name: 'Khánh Hòa' },
  { Id: 48, Name: 'Đồng Nai' }, { Id: 46, Name: 'Tây Ninh' },
  // Tỉnh thành không có trong danh sách API gốc — map sang tỉnh gần nhất
  { Id: 50, Name: 'Bình Dương' },   // không có Id riêng → fallback HCM
  { Id: 50, Name: 'Long An' },
  { Id: 50, Name: 'Tiền Giang' },
  { Id: 56, Name: 'Đồng Tháp' },
  { Id: 44, Name: 'Lâm Đồng' },
  { Id: 44, Name: 'Tỉnh Lâm Đồng' },
  { Id: 50, Name: 'Bà Rịa - Vũng Tàu' }, // fallback HCM
  { Id: 50, Name: 'Bà Rịa-Vũng Tàu' },
  { Id: 34, Name: 'Quảng Nam' },  // Id 34 = Quảng Ngãi lân cận
]);

// ── Helper: chuyển string/Map → Map {id,name} ────────────────────────────────

/**
 * lookup(value, lookupMap)
 * - Nếu value đã là Map {id, name} → giữ nguyên
 * - Nếu value là string tên → tìm trong lookupMap
 * - Nếu value là int id → tìm id trong lookupMap
 * - Trả null nếu không nhận ra
 */
function lookup(value, lookupMap) {
  if (value == null) return null;

  // Đã là Map {id, name} → kiểm tra và giữ nguyên
  if (typeof value === 'object' && !Array.isArray(value)) {
    if (value.id != null && value.name != null) return value; // đã migrate
    return null;
  }

  // Là string tên → tìm theo tên (lowercase)
  if (typeof value === 'string') {
    const key = value.toLowerCase().trim();
    return lookupMap[key] ?? null;
  }

  // Là số id → tìm trong values của map
  if (typeof value === 'number') {
    return Object.values(lookupMap).find(v => v.id === value) ?? null;
  }

  return null;
}

// ── Migrate một document benhNhan ────────────────────────────────────────────

function migrateBenhNhan(data) {
  const updates = {};
  let changed = false;

  const tryUpdate = (field, val, mapObj) => {
    if (val == null) return;
    // Nếu đã là Map {id, name} → skip
    if (typeof val === 'object' && val.id != null && val.name != null) return;
    const resolved = lookup(val, mapObj);
    if (resolved) { updates[field] = resolved; changed = true; }
    else { console.log(`    ⚠️  Không tìm được ID cho ${field}="${JSON.stringify(val)}"`); }
  };

  tryUpdate('gioiTinh',           data.gioiTinh,           GIOI_TINH);
  tryUpdate('danToc',             data.danToc,             DAN_TOC);
  tryUpdate('tinh',               data.tinh,               TINH);
  tryUpdate('benhNen',            data.benhNen,            buildBenhNenMap());
  tryUpdate('benhTruyenNhiem',    data.benhTruyenNhiem,    CHAN_DOAN_BENH);
  tryUpdate('tinhTrangTiemChung', data.tinhTrangTiemChung, TINH_TRANG_TIEM);
  tryUpdate('coKhong',            data.coKhong,            CO_KHONG);
  tryUpdate('dieuTri',            data.dieuTri,            DIEU_TRI);
  tryUpdate('hinhThucDieuTri',    data.hinhThucDieuTri,    HINH_THUC_DIEU_TRI);
  tryUpdate('chanDoanBenh',       data.chanDoanBenh,       CHAN_DOAN_BENH);
  tryUpdate('phanLoaiChanDoan',   data.phanLoaiChanDoan,   PHAN_LOAI_CHAN_DOAN);
  tryUpdate('phanDoBenh',         data.phanDoBenh,         PHAN_DO_BENH);
  tryUpdate('loaiBenhPham',       data.loaiBenhPham,       LOAI_BENH_PHAM);
  tryUpdate('loaiXetNghiem',      data.loaiXetNghiem,      LOAI_BENH_PHAM);
  tryUpdate('ketQuaXetNghiem',    data.ketQuaXetNghiem,    KET_QUA_XN);

  return changed ? updates : null;
}

// ── Migrate một document benhTruyenNhiem ────────────────────────────────────

function migrateBTN(data) {
  const updates = {};
  let changed = false;

  const tryUpdate = (field, val, mapObj) => {
    if (val == null) return;
    if (typeof val === 'object' && val.id != null && val.name != null) return;
    const resolved = lookup(val, mapObj);
    if (resolved) { updates[field] = resolved; changed = true; }
    else { console.log(`    ⚠️  Không tìm được ID cho ${field}="${JSON.stringify(val)}"`); }
  };

  tryUpdate('gioiTinh',         data.gioiTinh,         GIOI_TINH);
  tryUpdate('danTocId',         data.danTocId,         DAN_TOC);
  tryUpdate('coThai',           data.coThai,           CO_KHONG);
  tryUpdate('cityIdHoc',        data.cityIdHoc,        TINH);
  tryUpdate('cityId',           data.cityId,           TINH);
  tryUpdate('coSoDieuTri',      data.coSoDieuTri,      buildCoSoMap());
  tryUpdate('cityIdCSDT',       data.cityIdCSDT,       TINH);
  tryUpdate('hinhThucDieuTri',  data.hinhThucDieuTri,  HINH_THUC_DIEU_TRI);
  tryUpdate('chanDoanBenh',     data.chanDoanBenh,     CHAN_DOAN_BENH);
  tryUpdate('phanDoBenh',       data.phanDoBenh,       PHAN_DO_BENH);
  tryUpdate('thongTinDieuTri',  data.thongTinDieuTri,  DIEU_TRI);
  tryUpdate('benhNenKemTheoId', data.benhNenKemTheoId, buildBenhNenMap());
  tryUpdate('phanLoaiChanDoan', data.phanLoaiChanDoan, PHAN_LOAI_CHAN_DOAN);
  tryUpdate('layMauXN',         data.layMauXN,         CO_KHONG);
  tryUpdate('loaiBenhPham',     data.loaiBenhPham,     LOAI_BENH_PHAM);
  tryUpdate('loaiXN',           data.loaiXN,           LOAI_BENH_PHAM);
  tryUpdate('ketQuaXN',         data.ketQuaXN,         KET_QUA_XN);
  tryUpdate('tinhTrangTiem',    data.tinhTrangTiem,    TINH_TRANG_TIEM);

  return changed ? updates : null;
}

// ── BenhNen (rút gọn) ────────────────────────────────────────────────────────
function buildBenhNenMap() {
  return mkMap([
    { Id: 11323, Name: 'Tăng huyết áp vô căn (nguyên phát)' },
    { Id: 11282, Name: 'Bệnh đái tháo đường type 1' },
    { Id: 11485, Name: 'Đái tháo đường phụ thuộc insuline' },
    { Id: 11486, Name: 'Đái tháo đường không phụ thuộc insuline' },
    { Id: 11345, Name: 'Suy tim' }, { Id: 11327, Name: 'Bệnh phổi tắc nghẽn mạn tính' },
    { Id: 11357, Name: 'Hen phế quản' }, { Id: 11371, Name: 'Xơ gan' },
    { Id: 11402, Name: 'Bệnh thận mạn' }, { Id: 11223, Name: 'HIV/AIDS' },
    { Id: 11496, Name: 'Lao (các loại)' }, { Id: 11475, Name: 'Hội chứng Down' },
    { Id: 11488, Name: 'Bại não' }, { Id: 11316, Name: 'Động kinh' },
    { Id: 11386, Name: 'Lupus ban đỏ hệ thống' }, { Id: 11318, Name: 'Hội chứng Guillain Barre' },
    { Id: 11561, Name: 'Không có bệnh nền' },
    // Thêm các tên cũ có thể đã lưu
    { Id: 11323, Name: 'Tăng huyết áp' }, { Id: 11282, Name: 'Tiểu đường' },
    { Id: 11345, Name: 'Tim mạch' }, { Id: 11327, Name: 'COPD' },
    { Id: 11357, Name: 'Hen suyễn' }, { Id: 11371, Name: 'Xơ gan' },
    { Id: 11402, Name: 'Thận mãn' }, { Id: 11223, Name: 'HIV/AIDS' },
    { Id: 11496, Name: 'Lao' }, { Id: 11561, Name: 'Không' },
    { Id: 11518, Name: 'Ung thư' }, { Id: 11518, Name: 'Ung thư *' },
    { Id: 11561, Name: 'Khác' }, // "Khác" → Không có bệnh nền
  ]);
}

function buildCoSoMap() {
  return mkMap([
    { Id: 10100, Name: 'Bệnh viện Bệnh Nhiệt Đới' },
    { Id: 10101, Name: 'Bệnh viện Nhi Đồng 1' },
    { Id: 10102, Name: 'Bệnh viện Nhi Đồng 2' },
    { Id: 10103, Name: 'Bệnh viện Nhi Đồng Thành phố' },
    { Id: 10184, Name: 'Bệnh viện Chợ Rẫy' },
    { Id: 10187, Name: 'Bệnh viện ĐH Y Dược TP.HCM' },
    { Id: 10099, Name: 'Bệnh viện Sài Gòn' },
    { Id: 10105, Name: 'Bệnh viện Từ Dũ' },
    { Id: 10106, Name: 'Bệnh viện Hùng Vương' },
    { Id: 10098, Name: 'Bệnh viện Nhân Dân 115' },
    { Id: 10130, Name: 'Bệnh viện Vinmec Central Park' },
    { Id: 10133, Name: 'Bệnh viện FV' },
    { Id: 25683, Name: 'Bệnh viện hoặc Phòng Khám khác' },
    { Id: 25683, Name: 'Bệnh Viện hoặc Phòng Khám khác' },
    // Alias tên ngắn
    { Id: 10101, Name: 'BV Nhi Đồng 1' },
    { Id: 10102, Name: 'BV Nhi Đồng 2' },
    { Id: 10184, Name: 'BV Chợ Rẫy' },
    { Id: 10187, Name: 'BV ĐH Y Dược TP.HCM' },
    { Id: 10098, Name: 'BV 115' },
    { Id: 10106, Name: 'BV Hùng Vương' },
    { Id: 10105, Name: 'BV Từ Dũ' },
    { Id: 10130, Name: 'BV Vinmec' },
    { Id: 10133, Name: 'BV FV' },
    { Id: 25683, Name: 'BV Bạch Mai' },  // Bạch Mai ở HN → fallback
    { Id: 25683, Name: 'BV Hùng Vương' },
    // Catch-all
    { Id: 25683, Name: 'Khác' },
  ]);
}

// ── Runner ────────────────────────────────────────────────────────────────────

async function migrateCollection(colName, migrateFn) {
  console.log(`\n📂  Đang migrate collection: ${colName}`);
  const snap = await db.collection(colName).get();
  console.log(`    Tổng docs: ${snap.size}`);

  let updated = 0, skipped = 0, failed = 0;
  const BATCH_SIZE = 400;
  let batch = db.batch();
  let batchCount = 0;

  for (const doc of snap.docs) {
    const data = doc.data();
    const updates = migrateFn(data);

    if (!updates) { skipped++; continue; }

    updates.ngayCapNhat = new Date().toISOString();
    batch.update(doc.ref, updates);
    batchCount++;
    updated++;

    if (batchCount >= BATCH_SIZE) {
      await batch.commit();
      console.log(`    ✅  Batch commit ${batchCount} docs`);
      batch = db.batch();
      batchCount = 0;
    }
  }

  if (batchCount > 0) {
    await batch.commit();
    console.log(`    ✅  Batch commit ${batchCount} docs`);
  }

  console.log(`    📊  Kết quả: updated=${updated}  skipped=${skipped}  failed=${failed}`);
}

async function main() {
  console.log('🚀  Bắt đầu migrate Firestore...\n');
  try {
    await migrateCollection('benhNhan',       migrateBenhNhan);
    await migrateCollection('benhTruyenNhiem', migrateBTN);
    console.log('\n✅  Migrate hoàn tất!');
  } catch (err) {
    console.error('\n❌  Lỗi migrate:', err);
    process.exit(1);
  }
  process.exit(0);
}

main();
