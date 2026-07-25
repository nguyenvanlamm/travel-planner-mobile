import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../services/storage.dart';
import '../../plan/screens/plan_result_screen.dart';

/// Lịch sử các kế hoạch đã tạo — xem lại hoặc xóa bớt.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SavedPlan>? _plans;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await PlanStorage.loadHistory();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete(SavedPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa kế hoạch?',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
        content: Text('"${plan.title}" sẽ bị xóa khỏi lịch sử.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await PlanStorage.remove(plan.id);
      if (!mounted) return;
      setState(() => _plans = [..._plans!]..removeWhere((p) => p.id == plan.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa "${plan.title}"')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red.shade700,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Kế hoạch đã lưu',
            style: GoogleFonts.fraunces(fontWeight: FontWeight.w600)),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SafeArea(child: _buildBody(theme)),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) return _buildLoading(theme);
    if (_error != null) return _buildError();
    if (_plans!.isEmpty) return _buildEmpty();

    final isDark = theme.brightness == Brightness.dark;
    final coral = isDark ? AppColors.dCoral : AppColors.coral;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _plans!.length,
        itemBuilder: (_, i) => _HistoryCard(
          plan: _plans![i],
          coral: coral,
          onOpen: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PlanResultScreen(plan: _plans![i].plan),
          )),
          onDelete: () => _delete(_plans![i]),
        ),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Đang tải kế hoạch đã lưu…', style: theme.textTheme.bodySmall),
          ],
        ),
      );

  Widget _buildError() => _StateMessage(
        emoji: '⚠️',
        title: 'Không tải được lịch sử',
        message: _error!,
        action: FilledButton(onPressed: _load, child: const Text('Thử lại')),
      );

  Widget _buildEmpty() => _StateMessage(
        emoji: '🧭',
        title: 'Chưa có kế hoạch nào',
        message:
            'Mỗi kế hoạch bạn tạo sẽ tự động được lưu lại ở đây để xem lại sau.',
        action: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Lập kế hoạch đầu tiên  →'),
        ),
      );
}

class _StateMessage extends StatelessWidget {
  final String emoji, title, message;
  final Widget action;
  const _StateMessage({
    required this.emoji,
    required this.title,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 24),
            action,
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SavedPlan plan;
  final Color coral;
  final VoidCallback onOpen, onDelete;
  const _HistoryCard({
    required this.plan,
    required this.coral,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.destination.isEmpty ? plan.title : plan.destination,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text('🗓  ${formatPlanDates(plan)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontSize: 13.5)),
                    const SizedBox(height: 2),
                    Text('🕐  Đã lưu ${formatSavedAt(plan.createdAt)}',
                        style: theme.textTheme.bodySmall),
                    if (plan.departure != null &&
                        plan.departure!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('✈️  Từ ${plan.departure}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: coral,
                tooltip: 'Xóa kế hoạch',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "12/08 – 15/08/2026 · 4 ngày", rút gọn dần khi thiếu dữ liệu.
String formatPlanDates(SavedPlan plan) {
  final start = plan.startDateTime;
  final end = plan.endDate;
  final daysLabel = plan.days == null ? null : '${plan.days} ngày';

  if (start == null) return daysLabel ?? 'Chưa rõ ngày đi';

  final startText = DateFormat('dd/MM').format(start);
  final range = end == null
      ? DateFormat('dd/MM/yyyy').format(start)
      : '$startText – ${DateFormat('dd/MM/yyyy').format(end)}';
  return daysLabel == null ? range : '$range · $daysLabel';
}

/// Thời điểm lưu, dạng tương đối cho những kế hoạch gần đây.
String formatSavedAt(DateTime? createdAt, {DateTime? now}) {
  if (createdAt == null) return 'không rõ thời điểm';
  final diff = (now ?? DateTime.now()).difference(createdAt);
  if (diff.isNegative || diff.inMinutes < 1) return 'vừa xong';
  if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
  if (diff.inHours < 24) return '${diff.inHours} giờ trước';
  if (diff.inDays < 7) return '${diff.inDays} ngày trước';
  return 'ngày ${DateFormat('dd/MM/yyyy').format(createdAt)}';
}
