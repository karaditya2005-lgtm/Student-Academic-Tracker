// lib/models/performance_model.dart

class SubjectResult {
  final String subject;
  final double marksObtained;
  final double totalMarks;

  SubjectResult({
    required this.subject,
    required this.marksObtained,
    required this.totalMarks,
  });

  double get percentage => (marksObtained / totalMarks) * 100;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    if (percentage >= 40) return 'D';
    return 'F';
  }

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'marksObtained': marksObtained,
        'totalMarks': totalMarks,
      };

  factory SubjectResult.fromJson(Map<String, dynamic> json) => SubjectResult(
        subject: json['subject'],
        marksObtained: (json['marksObtained'] as num).toDouble(),
        totalMarks: (json['totalMarks'] as num).toDouble(),
      );
}

class PerformanceData {
  final List<SubjectResult> results;
  final double studyHoursPerDay;
  final double attendancePercent;
  final String examType;
  final DateTime recordedAt;

  PerformanceData({
    required this.results,
    required this.studyHoursPerDay,
    required this.attendancePercent,
    required this.examType,
    required this.recordedAt,
  });

  double get overallPercentage {
    if (results.isEmpty) return 0;
    double total = results.fold(0, (sum, r) => sum + r.marksObtained);
    double max = results.fold(0, (sum, r) => sum + r.totalMarks);
    return (total / max) * 100;
  }

  String get performanceLevel {
    final p = overallPercentage;
    if (p >= 85) return 'Excellent 🌟';
    if (p >= 70) return 'Good 👍';
    if (p >= 55) return 'Average 📚';
    if (p >= 40) return 'Below Average ⚠️';
    return 'Needs Improvement ❗';
  }

  String get suggestion {
    final p = overallPercentage;
    final hours = studyHoursPerDay;
    final att = attendancePercent;

    if (att < 75) return 'Your attendance is critically low. Attend more classes to improve learning.';
    if (hours < 2 && p < 60) return 'Increase daily study hours to at least 3-4 hours for better results.';
    if (p >= 85 && att >= 90) return 'Outstanding performance! Keep up the excellent work and stay consistent.';
    if (p >= 70) return 'Good performance! Focus on weak subjects and aim for more than 85%.';
    if (hours >= 4 && p < 60) return 'Despite good study hours, results are low. Try different study techniques or seek help.';
    return 'Work on improving attendance and increase focused study time daily.';
  }

  Map<String, dynamic> toJson() => {
        'results': results.map((r) => r.toJson()).toList(),
        'studyHoursPerDay': studyHoursPerDay,
        'attendancePercent': attendancePercent,
        'examType': examType,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory PerformanceData.fromJson(Map<String, dynamic> json) => PerformanceData(
        results: (json['results'] as List).map((r) => SubjectResult.fromJson(r)).toList(),
        studyHoursPerDay: (json['studyHoursPerDay'] as num).toDouble(),
        attendancePercent: (json['attendancePercent'] as num).toDouble(),
        examType: json['examType'],
        recordedAt: DateTime.parse(json['recordedAt']),
      );
}
