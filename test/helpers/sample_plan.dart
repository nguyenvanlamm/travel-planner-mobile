import 'package:travel_planner/models/travel_models.dart';

/// JSON kế hoạch tối thiểu, đủ để dựng [TravelPlan] trong test.
Map<String, dynamic> samplePlanJson({String overview = 'Chuyến đi thử'}) => {
  'tong_quan': overview,
  've_di_chuyen': [],
  'khach_san': [],
  'lich_trinh': [],
  'nha_hang': [],
  'diem_tham_quan': [],
  'tong_chi_phi': {'tong': '10.000.000đ'},
  'meo': [],
};

TravelPlan samplePlan({String overview = 'Chuyến đi thử'}) =>
    TravelPlan.fromJson(samplePlanJson(overview: overview));

TravelInput sampleInput({
  String destination = 'Đà Nẵng',
  String departure = 'Hà Nội',
  int days = 4,
  String startDate = '2026-08-12',
}) => TravelInput(
  departure: departure,
  destination: destination,
  days: days,
  startDate: startDate,
);
