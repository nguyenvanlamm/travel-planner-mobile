import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/travel_models.dart';
import '../../../services/api_client.dart';
import '../../../services/storage.dart';
import '../../history/screens/history_screen.dart';
import 'plan_result_screen.dart';

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key});

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departureCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _specialCtrl = TextEditingController();

  DateTime _startDate = DateTime.now();
  int _days = 3, _adults = 2, _children = 0;
  String _pace = 'vừa phải';
  String? _hotelLevel, _transportation;
  final Set<String> _interests = {};
  bool _loading = false;

  List<String> _destinations = [];
  List<SavedPlan> _history = [];

  static const _paces = ['thoải mái', 'vừa phải', 'nhanh'];
  static const _interestOptions = [
    'văn hóa', 'ẩm thực', 'thiên nhiên', 'mua sắm', 'giải trí', 'lịch sử'
  ];
  static const _budgetPresets = [3000000, 5000000, 10000000, 20000000];
  static const _loadingMessages = [
    'Đang phân tích yêu cầu của bạn…',
    'Đang tìm phương tiện di chuyển…',
    'Đang chọn khách sạn được đánh giá tốt…',
    'Đang sắp xếp lịch trình từng ngày…',
    'Đang gom góp quán ngon địa phương…',
    'Đang tính toán chi phí…',
    'Sắp xong rồi, chờ chút nhé…',
  ];
  int _msgIndex = 0;
  Timer? _msgTimer;

  @override
  void initState() {
    super.initState();
    ApiClient.fetchDestinations().then((d) {
      if (mounted) setState(() => _destinations = d);
    });
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final h = await PlanStorage.loadHistoryOrEmpty();
    if (mounted) setState(() => _history = h);
  }

  Future<void> _openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
    await _loadHistory();
  }

  @override
  void dispose() {
    _msgTimer?.cancel();
    _departureCtrl.dispose();
    _destinationCtrl.dispose();
    _cuisineCtrl.dispose();
    _budgetCtrl.dispose();
    _specialCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final input = TravelInput(
      departure: _departureCtrl.text.trim(),
      destination: _destinationCtrl.text.trim(),
      days: _days,
      adults: _adults,
      children: _children,
      budget: int.tryParse(_budgetCtrl.text.replaceAll(RegExp(r'\D'), '')),
      hotelLevel: _hotelLevel,
      transportation: _transportation,
      interests: _interests.toList(),
      pace: _pace,
      cuisine: _cuisineCtrl.text.trim(),
      specialRequirements: _specialCtrl.text.trim(),
      startDate: DateFormat('yyyy-MM-dd').format(_startDate),
    );

    setState(() {
      _loading = true;
      _msgIndex = 0;
    });
    _msgTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (mounted) {
        setState(() => _msgIndex = (_msgIndex + 1) % _loadingMessages.length);
      }
    });

    try {
      final plan = await ApiClient.createPlan(input);
      await PlanStorage.save(plan, input);
      await _loadHistory();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PlanResultScreen(plan: plan),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Chưa lập được kế hoạch: ${e.toString().replaceFirst('Exception: ', '')}'),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 6),
      ));
    } finally {
      _msgTimer?.cancel();
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final coral = isDark ? AppColors.dCoral : AppColors.coral;
    final teal = isDark ? AppColors.dTealDeep : AppColors.tealDeep;

    return Scaffold(
      body: SafeArea(
        child: _loading ? _buildLoading(theme) : _buildForm(theme, coral, teal),
      ),
    );
  }

  Widget _buildLoading(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _FlyingPlane(),
            const SizedBox(height: 28),
            Text(
              _loadingMessages[_msgIndex],
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thường mất 1–2 phút (lần đầu có thể lâu hơn\nvì máy chủ miễn phí cần khởi động)',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, Color coral, Color teal) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('✈  TRAVEL PLANNER',
                    style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary, letterSpacing: 3)),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                color: theme.colorScheme.primary,
                tooltip: 'Kế hoạch đã lưu',
                onPressed: _openHistory,
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: theme.textTheme.displaySmall,
              children: [
                const TextSpan(text: 'Chuyến đi trong mơ,\n'),
                TextSpan(
                  text: 'lên kế hoạch trong một phút',
                  style: GoogleFonts.fraunces(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: coral,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_history.isNotEmpty) ...[
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(Icons.bookmark_border, color: teal),
                title: Text('${_history.length} kế hoạch đã lưu',
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 15)),
                subtitle: Text(_history.first.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openHistory,
              ),
            ),
            const SizedBox(height: 20),
          ],

          _sectionTitle('Hành trình', teal),
          TextFormField(
            controller: _departureCtrl,
            decoration: const InputDecoration(
                labelText: 'Điểm xuất phát *', hintText: 'VD: Hà Nội'),
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Nhập điểm xuất phát' : null,
          ),
          const SizedBox(height: 14),
          _destinationField(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _dateField(theme)),
              const SizedBox(width: 12),
              Expanded(
                child: _Stepper(
                  label: 'Số ngày',
                  value: _days,
                  min: 1,
                  max: 30,
                  onChanged: (v) => setState(() => _days = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _sectionTitle('Thành viên & nhịp độ', teal),
          Row(
            children: [
              Expanded(
                child: _Stepper(
                  label: 'Người lớn',
                  value: _adults,
                  min: 1,
                  max: 20,
                  onChanged: (v) => setState(() => _adults = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Stepper(
                  label: 'Trẻ em',
                  value: _children,
                  min: 0,
                  max: 20,
                  onChanged: (v) => setState(() => _children = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: _paces
                .map((p) => ButtonSegment(
                    value: p,
                    label: Text(p[0].toUpperCase() + p.substring(1),
                        style: const TextStyle(fontSize: 13))))
                .toList(),
            selected: {_pace},
            onSelectionChanged: (s) => setState(() => _pace = s.first),
          ),
          const SizedBox(height: 24),

          _sectionTitle('Tùy chọn thêm', teal),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _hotelLevel,
                  decoration: const InputDecoration(labelText: 'Khách sạn'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Mặc định')),
                    DropdownMenuItem(value: '2 sao', child: Text('2 sao')),
                    DropdownMenuItem(value: '3 sao', child: Text('3 sao')),
                    DropdownMenuItem(value: '4 sao', child: Text('4 sao')),
                    DropdownMenuItem(value: '5 sao', child: Text('5 sao')),
                  ],
                  onChanged: (v) => setState(() => _hotelLevel = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _transportation,
                  decoration: const InputDecoration(labelText: 'Phương tiện'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Mặc định')),
                    DropdownMenuItem(value: 'Máy bay', child: Text('Máy bay')),
                    DropdownMenuItem(value: 'Xe khách', child: Text('Xe khách')),
                    DropdownMenuItem(value: 'Tàu', child: Text('Tàu')),
                    DropdownMenuItem(value: 'Ô tô', child: Text('Ô tô')),
                  ],
                  onChanged: (v) => setState(() => _transportation = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _cuisineCtrl,
            decoration: const InputDecoration(
                labelText: 'Ẩm thực yêu thích',
                hintText: 'VD: hải sản, đồ nướng, chay…'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _budgetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Ngân sách (VND)',
                hintText: 'Bỏ trống nếu không giới hạn'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _budgetPresets.map((amount) {
              final label = '${amount ~/ 1000000} triệu';
              final selected = _budgetCtrl.text == amount.toString();
              return FilterChip(
                label: Text(label),
                selected: selected,
                showCheckmark: false,
                labelStyle: TextStyle(
                    color: selected
                        ? AppColors.paper
                        : theme.textTheme.bodyMedium?.color),
                onSelected: (_) => setState(() =>
                    _budgetCtrl.text = selected ? '' : amount.toString()),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text('Sở thích — chọn bao nhiêu tùy bạn',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _interestOptions.map((opt) {
              final selected = _interests.contains(opt);
              return FilterChip(
                label: Text(opt[0].toUpperCase() + opt.substring(1)),
                selected: selected,
                showCheckmark: false,
                labelStyle: TextStyle(
                    color: selected
                        ? AppColors.paper
                        : theme.textTheme.bodyMedium?.color),
                onSelected: (_) => setState(() =>
                    selected ? _interests.remove(opt) : _interests.add(opt)),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _specialCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
                labelText: 'Yêu cầu đặc biệt',
                hintText: 'VD: đi với người già, dị ứng thực phẩm…'),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _submit,
            child: const Text('Lập kế hoạch du lịch  →'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: GoogleFonts.fraunces(
                fontSize: 18, fontWeight: FontWeight.w600, color: color)),
      );

  Widget _destinationField() {
    return Autocomplete<String>(
      optionsBuilder: (t) {
        if (t.text.isEmpty) return _destinations;
        final q = t.text.toLowerCase();
        return _destinations.where((d) => d.toLowerCase().contains(q));
      },
      onSelected: (v) => _destinationCtrl.text = v,
      fieldViewBuilder: (context, ctrl, focus, onSubmit) {
        ctrl.text = _destinationCtrl.text;
        ctrl.addListener(() => _destinationCtrl.text = ctrl.text);
        return TextFormField(
          controller: ctrl,
          focusNode: focus,
          decoration: const InputDecoration(
              labelText: 'Điểm đến *', hintText: 'VD: Đà Nẵng, Tokyo…'),
          validator: (v) => (v ?? '').trim().isEmpty ? 'Nhập điểm đến' : null,
        );
      },
    );
  }

  Widget _dateField(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _startDate = picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Ngày bắt đầu'),
        child: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text('$value',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            visualDensity: VisualDensity.compact,
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _FlyingPlane extends StatefulWidget {
  const _FlyingPlane();

  @override
  State<_FlyingPlane> createState() => _FlyingPlaneState();
}

class _FlyingPlaneState extends State<_FlyingPlane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 60,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: t * 220,
                bottom: 6 + 14 * (1 - (2 * t - 1) * (2 * t - 1)),
                child: const Text('✈️', style: TextStyle(fontSize: 26)),
              ),
            ],
          );
        },
      ),
    );
  }
}
