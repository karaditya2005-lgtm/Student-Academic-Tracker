// lib/screens/input_performance_tab.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:student_app/screens/auth_service.dart' show AuthService;
import 'package:student_app/screens/performance_model.dart'
    show SubjectResult, PerformanceData;
import 'package:student_app/screens/theme.dart';
import 'package:student_app/screens/user_model.dart';

class InputPerformanceTab extends StatefulWidget {
  final UserModel user;
  final VoidCallback onSaved;
  const InputPerformanceTab(
      {super.key, required this.user, required this.onSaved});

  @override
  State<InputPerformanceTab> createState() => _InputPerformanceTabState();
}

class _InputPerformanceTabState extends State<InputPerformanceTab> {
  final _formKey = GlobalKey<FormState>();
  String _examType = 'Unit Test';
  double _studyHours = 3;
  double _attendance = 85;
  bool _saving = false;

  final List<Map<String, dynamic>> _subjects = [
    {
      'name': TextEditingController(text: 'Mathematics'),
      'obtained': TextEditingController(),
      'total': TextEditingController(text: '100')
    },
    {
      'name': TextEditingController(text: 'Science'),
      'obtained': TextEditingController(),
      'total': TextEditingController(text: '100')
    },
    {
      'name': TextEditingController(text: 'English'),
      'obtained': TextEditingController(),
      'total': TextEditingController(text: '100')
    },
  ];

  final _examTypes = [
    'Unit Test',
    'Mid Term',
    'Final Exam',
    'Half Yearly',
    'Annual'
  ];

  void _addSubject() {
    setState(() => _subjects.add({
          'name': TextEditingController(),
          'obtained': TextEditingController(),
          'total': TextEditingController(text: '100'),
        }));
  }

  void _removeSubject(int i) {
    if (_subjects.length <= 1) return;
    setState(() => _subjects.removeAt(i));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final results = _subjects
        .map((s) => SubjectResult(
              subject: s['name'].text.trim(),
              marksObtained: double.tryParse(s['obtained'].text) ?? 0,
              totalMarks: double.tryParse(s['total'].text) ?? 100,
            ))
        .toList();

    final data = PerformanceData(
      results: results,
      studyHoursPerDay: _studyHours,
      attendancePercent: _attendance,
      examType: _examType,
      recordedAt: DateTime.now(),
    );

    await AuthService.savePerformance(widget.user.uid, data);
    setState(() => _saving = false);
    widget.onSaved();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white),
        const SizedBox(width: 8),
        Text('Performance saved!',
            style: GoogleFonts.poppins(color: Colors.white)),
      ]),
      backgroundColor: AppTheme.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Add Performance'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _examTypeSection(),
              const SizedBox(height: 20),
              _studyAttendanceSection(),
              const SizedBox(height: 20),
              _subjectsSection(),
              const SizedBox(height: 24),
              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save & Analyse'),
                    ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _examTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Exam Type'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: _examTypes.map((t) {
            final sel = t == _examType;
            return GestureDetector(
              onTap: () => setState(() => _examType = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: sel ? AppTheme.primary : AppTheme.border),
                ),
                child: Text(t,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: sel ? Colors.white : AppTheme.textSecondary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _studyAttendanceSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Daily Study Hours: ${_studyHours.toStringAsFixed(1)}h'),
          Slider(
            value: _studyHours,
            min: 0.5,
            max: 12,
            divisions: 23,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _studyHours = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0.5h',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary)),
              Text('12h',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          _label('Attendance: ${_attendance.toStringAsFixed(0)}%'),
          Slider(
            value: _attendance,
            min: 0,
            max: 100,
            divisions: 100,
            activeColor:
                _attendance >= 75 ? AppTheme.secondary : AppTheme.danger,
            onChanged: (v) => setState(() => _attendance = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      (_attendance >= 75 ? AppTheme.secondary : AppTheme.danger)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(_attendance < 75 ? 'Low attendance!' : 'Good',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _attendance >= 75
                            ? AppTheme.secondary
                            : AppTheme.danger,
                        fontWeight: FontWeight.w600)),
              ),
              Text('100%',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _label('Subject Results'),
            TextButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add_rounded, size: 16),
              label:
                  Text('Add Subject', style: GoogleFonts.poppins(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._subjects.asMap().entries.map((e) => _subjectRow(e.key, e.value)),
      ],
    );
  }

  Widget _subjectRow(int i, Map<String, dynamic> sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: sub['name'],
                  decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.book_outlined,
                          color: AppTheme.textSecondary)),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 8),
              if (_subjects.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded,
                      color: AppTheme.danger),
                  onPressed: () => _removeSubject(i),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: sub['obtained'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Marks Obtained',
                      prefixIcon: Icon(Icons.star_outline_rounded,
                          color: AppTheme.textSecondary)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: sub['total'],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Total Marks',
                      prefixIcon: Icon(Icons.flag_outlined,
                          color: AppTheme.textSecondary)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary));
  }
}
