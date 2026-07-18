class TravelInput {
  String departure;
  String destination;
  int days;
  int adults;
  int children;
  int? budget;
  String? hotelLevel;
  String? transportation;
  List<String> interests;
  String pace;
  String? cuisine;
  String? specialRequirements;
  String startDate; // yyyy-MM-dd

  TravelInput({
    this.departure = '',
    this.destination = '',
    this.days = 3,
    this.adults = 2,
    this.children = 0,
    this.budget,
    this.hotelLevel,
    this.transportation,
    List<String>? interests,
    this.pace = 'vừa phải',
    this.cuisine,
    this.specialRequirements,
    required this.startDate,
  }) : interests = interests ?? [];

  Map<String, dynamic> toJson() => {
        'departure': departure,
        'destination': destination,
        'days': days,
        'adults': adults,
        'children': children,
        'budget': budget,
        'hotel_level': hotelLevel,
        'transportation': transportation,
        'interests': interests.isEmpty ? null : interests,
        'pace': pace,
        'cuisine': (cuisine ?? '').isEmpty ? null : cuisine,
        'special_requirements':
            (specialRequirements ?? '').isEmpty ? null : specialRequirements,
        'start_date': startDate,
      };
}

class TransportItem {
  final String loai, hang, thoiGian, gia;
  final String? link;
  TransportItem.fromJson(Map<String, dynamic> j)
      : loai = j['loai'] ?? '',
        hang = j['hang'] ?? '',
        thoiGian = j['thoi_gian'] ?? '',
        gia = j['gia'] ?? '',
        link = j['link'];
}

class HotelItem {
  final String ten, diaChi, giaPerDem;
  final double rating;
  final int reviewCount;
  final List<String> tienNghi;
  final String? link;
  HotelItem.fromJson(Map<String, dynamic> j)
      : ten = j['ten'] ?? '',
        diaChi = j['dia_chi'] ?? '',
        giaPerDem = j['gia_per_dem'] ?? '',
        rating = (j['rating'] ?? 0).toDouble(),
        reviewCount = j['review_count'] ?? 0,
        tienNghi = List<String>.from(j['tien_nghi'] ?? []),
        link = j['link'];
}

class Activity {
  final String gio, moTa;
  Activity.fromJson(Map<String, dynamic> j)
      : gio = j['gio'] ?? '',
        moTa = j['mo_ta'] ?? '';
}

class DayPlan {
  final int ngay;
  final String tieuDe;
  final List<Activity> buoiSang, buoiTrua, buoiChieu, buoiToi;
  DayPlan.fromJson(Map<String, dynamic> j)
      : ngay = j['ngay'] ?? 0,
        tieuDe = j['tieu_de'] ?? '',
        buoiSang = _acts(j['buoi_sang']),
        buoiTrua = _acts(j['buoi_trua']),
        buoiChieu = _acts(j['buoi_chieu']),
        buoiToi = _acts(j['buoi_toi']);

  static List<Activity> _acts(dynamic list) =>
      (list as List? ?? []).map((e) => Activity.fromJson(e)).toList();
}

class RestaurantItem {
  final int ngay;
  final String bua, tenQuan, diaChi, monDacTrung, gia;
  final double rating;
  RestaurantItem.fromJson(Map<String, dynamic> j)
      : ngay = j['ngay'] ?? 0,
        bua = j['bua'] ?? '',
        tenQuan = j['ten_quan'] ?? '',
        diaChi = j['dia_chi'] ?? '',
        monDacTrung = j['mon_dac_trung'] ?? '',
        gia = j['gia'] ?? '',
        rating = (j['rating'] ?? 0).toDouble();
}

class AttractionItem {
  final String diem, loai, diaChi, giaVe, thoiGian, ghiChu;
  AttractionItem.fromJson(Map<String, dynamic> j)
      : diem = j['diem'] ?? '',
        loai = j['loai'] ?? '',
        diaChi = j['dia_chi'] ?? '',
        giaVe = j['gia_ve'] ?? '',
        thoiGian = j['thoi_gian'] ?? '',
        ghiChu = j['ghi_chu'] ?? '';
}

class CostBreakdown {
  final String veDiChuyen, khachSan, anUong, diChuyenNoiThanh, veThamQuan,
      chiPhiPhatSinh, tong;
  final String? nganSach, chenhLech;
  CostBreakdown.fromJson(Map<String, dynamic> j)
      : veDiChuyen = j['ve_di_chuyen'] ?? '',
        khachSan = j['khach_san'] ?? '',
        anUong = j['an_uong'] ?? '',
        diChuyenNoiThanh = j['di_chuyen_noi_thanh'] ?? '',
        veThamQuan = j['ve_tham_quan'] ?? '',
        chiPhiPhatSinh = j['chi_phi_phat_sinh'] ?? '',
        tong = j['tong'] ?? '',
        nganSach = j['ngan_sach'],
        chenhLech = j['chenh_lech'];
}

class TravelPlan {
  final String tongQuan;
  final List<TransportItem> veDiChuyen;
  final List<HotelItem> khachSan;
  final List<DayPlan> lichTrinh;
  final List<RestaurantItem> nhaHang;
  final List<AttractionItem> diemThamQuan;
  final CostBreakdown tongChiPhi;
  final List<String> meo;
  final Map<String, dynamic> raw;

  TravelPlan.fromJson(Map<String, dynamic> j)
      : tongQuan = j['tong_quan'] ?? '',
        veDiChuyen = (j['ve_di_chuyen'] as List? ?? [])
            .map((e) => TransportItem.fromJson(e))
            .toList(),
        khachSan = (j['khach_san'] as List? ?? [])
            .map((e) => HotelItem.fromJson(e))
            .toList(),
        lichTrinh = (j['lich_trinh'] as List? ?? [])
            .map((e) => DayPlan.fromJson(e))
            .toList(),
        nhaHang = (j['nha_hang'] as List? ?? [])
            .map((e) => RestaurantItem.fromJson(e))
            .toList(),
        diemThamQuan = (j['diem_tham_quan'] as List? ?? [])
            .map((e) => AttractionItem.fromJson(e))
            .toList(),
        tongChiPhi = CostBreakdown.fromJson(j['tong_chi_phi'] ?? {}),
        meo = List<String>.from(j['meo'] ?? []),
        raw = j;
}
