// lib/screens/dashboard_tab.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:student_app/screens/auth_service.dart';
import 'package:student_app/screens/performance_model.dart';
import 'package:student_app/screens/theme.dart' show AppTheme;
import 'package:student_app/screens/user_model.dart';

import 'login_screen.dart';

class DashboardTab extends StatefulWidget {
  final UserModel user;
  const DashboardTab({super.key, required this.user});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List<PerformanceData> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await AuthService.getPerformanceHistory(widget.user.uid);
    setState(() {
      _history = h;
      _loading = false;
    });
  }

  PerformanceData? get _latest => _history.isEmpty ? null : _history.last;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_loading)
                    const Center(child: CircularProgressIndicator()),
                  if (!_loading) ...[
                    _welcomeCard(),
                    const SizedBox(height: 16),
                    if (_latest != null) ...[
                      _overallCard(),
                      const SizedBox(height: 16),
                      _statsRow(),
                      const SizedBox(height: 16),
                      _subjectChart(),
                      const SizedBox(height: 16),
                      _suggestionCard(),
                      const SizedBox(height: 16),
                      _historySection(),
                    ] else
                      _emptyState(),
                  ],
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      expandedHeight: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(widget.user.avatarInitials,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13))),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student Dashboard',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text(widget.user.studentClass,
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
          onPressed: () async {
            await AuthService.logout();
            if (mounted)
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
          },
        ),
      ],
    );
  }

  Widget _welcomeCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primary, Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting,',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 13)),
                Text(widget.user.name.split(' ').first,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(widget.user.school,
                    style: GoogleFonts.poppins(
                        color: Colors.white60, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.auto_awesome_rounded,
              color: Colors.white30, size: 60),
        ],
      ),
    );
  }

  Widget _overallCard() {
    final perf = _latest!;
    final pct = perf.overallPercentage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Performance',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorForPct(pct).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(perf.examType,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _colorForPct(pct),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: pct / 100,
                      strokeWidth: 10,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation(_colorForPct(pct)),
                    ),
                    Center(
                      child: Text('${pct.toStringAsFixed(1)}%',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppTheme.textPrimary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(perf.performanceLevel,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                        'Last updated: ${DateFormat('MMM d, yyyy').format(perf.recordedAt)}',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow() {
    final perf = _latest!;
    return Row(
      children: [
        Expanded(
            child: _statCard('Study Hours', '${perf.studyHoursPerDay}h/day',
                Icons.access_time_rounded, AppTheme.secondary)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard(
                'Attendance',
                '${perf.attendancePercent.toStringAsFixed(0)}%',
                Icons.event_available_rounded,
                perf.attendancePercent >= 75
                    ? AppTheme.secondary
                    : AppTheme.danger)),
        const SizedBox(width: 12),
        Expanded(
            child: _statCard('Subjects', '${perf.results.length}',
                Icons.book_rounded, AppTheme.primary)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _subjectChart() {
    final results = _latest!.results;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject-wise Performance',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        final idx = v.toInt();
                        if (idx >= results.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                              results[idx].subject.length > 4
                                  ? results[idx].subject.substring(0, 4)
                                  : results[idx].subject,
                              style: GoogleFonts.poppins(
                                  fontSize: 9, color: AppTheme.textSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25),
                borderData: FlBorderData(show: false),
                barGroups: results.asMap().entries.map((e) {
                  final pct = e.value.percentage;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                          toY: pct,
                          color: _colorForPct(pct),
                          width: 18,
                          borderRadius: BorderRadius.circular(6))
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...results.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: _colorForPct(r.percentage),
                            borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(r.subject,
                            style: GoogleFonts.poppins(fontSize: 12))),
                    Text(
                        '${r.marksObtained.toStringAsFixed(0)}/${r.totalMarks.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: _colorForPct(r.percentage).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(r.grade,
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _colorForPct(r.percentage))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _suggestionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded,
              color: AppTheme.secondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Study Suggestion',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.secondary)),
                const SizedBox(height: 4),
                Text(_latest!.suggestion,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _historySection() {
    if (_history.length <= 1) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Previous Records',
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 10),
        ..._history.reversed.skip(1).take(3).map((p) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.examType,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(DateFormat('MMM d, yyyy').format(p.recordedAt),
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Text('${p.overallPercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: _colorForPct(p.overallPercentage))),
                ],
              ),
            )),
      ],
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          const Icon(Icons.assignment_outlined,
              size: 60, color: AppTheme.border),
          const SizedBox(height: 16),
          Text('No Data Yet',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text(
              'Go to the Performance tab to add your results, study hours, and attendance.',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Color _colorForPct(double pct) {
    if (pct >= 75) return AppTheme.secondary;
    if (pct >= 50) return AppTheme.accent;
    return AppTheme.danger;
  }
}
