import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../models/travel_models.dart';

class PlanResultScreen extends StatelessWidget {
  final TravelPlan plan;
  const PlanResultScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final coral = isDark ? AppColors.dCoral : AppColors.coral;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kế hoạch của bạn',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _OverviewCard(text: plan.tongQuan),
          _section(context, 'DI CHUYỂN', 'Vé di chuyển'),
          ...plan.veDiChuyen.map((t) => _TicketCard(item: t, coral: coral)),
          _section(context, 'LƯU TRÚ', 'Khách sạn gợi ý'),
          ...plan.khachSan.map((h) => _HotelCard(item: h)),
          _section(context, 'HÀNH TRÌNH', 'Lịch trình từng ngày'),
          ...plan.lichTrinh.map((d) => _DayCard(day: d, coral: coral)),
          _section(context, 'ẨM THỰC', 'Nhà hàng & quán ngon'),
          ...plan.nhaHang.map((r) => _RestaurantCard(item: r)),
          _section(context, 'KHÁM PHÁ', 'Điểm tham quan'),
          ...plan.diemThamQuan.map((a) => _AttractionCard(item: a)),
          _section(context, 'NGÂN SÁCH', 'Tổng chi phí'),
          _CostCard(cost: plan.tongChiPhi, coral: coral),
          if (plan.meo.isNotEmpty) ...[
            _section(context, 'LƯU Ý', 'Mẹo cho chuyến đi'),
            _TipsCard(tips: plan.meo),
          ],
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String overline, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(overline,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  fontSize: 11)),
          Text(title, style: theme.textTheme.headlineSmall),
        ],
      ),
    );
  }
}

Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _openMaps(String query) =>
    _openUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');

String _stars(double rating) {
  final full = rating.round().clamp(0, 5);
  return '★' * full + '☆' * (5 - full);
}

class _OverviewCard extends StatelessWidget {
  final String text;
  const _OverviewCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tealDeep, AppColors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TỔNG QUAN CHUYẾN ĐI',
              style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFFA8D4C8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5)),
          const SizedBox(height: 8),
          Text(text.replaceAll('**', ''),
              style: GoogleFonts.beVietnamPro(
                  color: const Color(0xFFF5F1E6), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TransportItem item;
  final Color coral;
  const _TicketCard({required this.item, required this.coral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: coral, width: 5)),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.loai} — ${item.hang}',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('🕐 ${item.thoiGian}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(item.gia,
                      style: TextStyle(
                          color: coral,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
                if (item.link != null)
                  TextButton(
                    onPressed: () => _openUrl(item.link!),
                    child: const Text('Đặt vé →'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final HotelItem item;
  const _HotelCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.ten, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => _openMaps('${item.ten} ${item.diaChi}'),
              child: Text('📍 ${item.diaChi}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted)),
            ),
            const SizedBox(height: 6),
            Text(
                '${_stars(item.rating)} ${item.rating} · ${item.reviewCount} đánh giá',
                style: TextStyle(
                    color: isDark ? const Color(0xFFE0B95F) : AppColors.gold,
                    fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item.giaPerDem} / đêm',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700)),
                if (item.link != null && item.link!.isNotEmpty)
                  TextButton(
                    onPressed: () => _openUrl(item.link!),
                    child: const Text('Đặt phòng →'),
                  ),
              ],
            ),
            if (item.tienNghi.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.tienNghi
                    .take(5)
                    .map((t) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.dTealTint
                                : AppColors.tealTint,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(t,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.dTealDeep
                                      : AppColors.tealDeep)),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DayPlan day;
  final Color coral;
  const _DayCard({required this.day, required this.coral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final periods = <(String, List<Activity>)>[
      ('🌅 Buổi sáng', day.buoiSang),
      ('🌞 Buổi trưa', day.buoiTrua),
      ('🌇 Buổi chiều', day.buoiChieu),
      ('🌙 Buổi tối', day.buoiToi),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: coral,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('NGÀY ${day.ngay}',
                      style: const TextStyle(
                          color: AppColors.paper,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(day.tieuDe,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final (label, acts) in periods)
              if (acts.isNotEmpty) ...[
                Text(label,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        fontSize: 11)),
                const SizedBox(height: 4),
                ...acts.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 1),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.dTealTint
                                  : AppColors.tealTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(a.gio,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.brightness == Brightness.dark
                                        ? AppColors.dTealDeep
                                        : AppColors.tealDeep)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(a.moTa,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 13.5))),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final RestaurantItem item;
  const _RestaurantCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child:
                        Text(item.tenQuan, style: theme.textTheme.titleMedium)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dTealTint : AppColors.tealTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Ngày ${item.ngay} · ${item.bua}',
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.dTealDeep
                              : AppColors.tealDeep)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${item.monDacTrung} — ${item.gia}',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5)),
            const SizedBox(height: 4),
            item.rating > 0
                ? Text('${_stars(item.rating)} ${item.rating}',
                    style: TextStyle(
                        color:
                            isDark ? const Color(0xFFE0B95F) : AppColors.gold,
                        fontSize: 13))
                : Text('Chưa có dữ liệu đánh giá',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 4),
            InkWell(
              onTap: () => _openMaps('${item.tenQuan} ${item.diaChi}'),
              child: Text('📍 ${item.diaChi}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttractionCard extends StatelessWidget {
  final AttractionItem item;
  const _AttractionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Text(item.diem, style: theme.textTheme.titleMedium)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dTealTint : AppColors.tealTint,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(item.loai,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.dTealDeep
                              : AppColors.tealDeep)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('🎟 ${item.giaVe} · 🕐 ${item.thoiGian}',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.5)),
            if (item.ghiChu.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.ghiChu, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 4),
            InkWell(
              onTap: () => _openMaps('${item.diem} ${item.diaChi}'),
              child: Text('📍 ${item.diaChi}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final CostBreakdown cost;
  final Color coral;
  const _CostCard({required this.cost, required this.coral});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <(String, String, bool)>[
      ('Vé di chuyển', cost.veDiChuyen, false),
      ('Khách sạn', cost.khachSan, false),
      ('Ăn uống', cost.anUong, false),
      ('Di chuyển nội thành', cost.diChuyenNoiThanh, false),
      ('Vé tham quan', cost.veThamQuan, false),
      ('Chi phí phát sinh', cost.chiPhiPhatSinh, false),
      ('Tổng', cost.tong, true),
      if (cost.nganSach != null) ('Ngân sách của bạn', cost.nganSach!, false),
      if (cost.chenhLech != null) ('Chênh lệch', cost.chenhLech!, false),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: rows
              .map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(r.$1,
                              style: r.$3
                                  ? GoogleFonts.fraunces(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: coral)
                                  : theme.textTheme.bodyMedium),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(r.$2,
                              textAlign: TextAlign.right,
                              style: r.$3
                                  ? GoogleFonts.fraunces(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: coral)
                                  : theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  final List<String> tips;
  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2718) : const Color(0xFFFDF8E7),
        border: Border.all(
            color: isDark ? const Color(0xFF4D4426) : const Color(0xFFECDFAE)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips
            .map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✦ ',
                          style: TextStyle(
                              color: isDark
                                  ? const Color(0xFFE0B95F)
                                  : AppColors.gold)),
                      Expanded(
                          child: Text(t, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}
