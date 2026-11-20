import 'package:intl/intl.dart';

class StudyLog {
  final String id;
  final DateTime date;
  String subject;
  String topic;
  int durationMinutes;
  int questionsSolved;
  String notes;
  int confidenceLevel; // 1-5
  bool needsRevision;
  DateTime? nextRevisionDate;

  StudyLog({
    required this.id,
    required this.date,
    required this.subject,
    required this.topic,
    required this.durationMinutes,
    required this.questionsSolved,
    this.notes = '',
    this.confidenceLevel = 3,
    this.needsRevision = false,
    this.nextRevisionDate,
  });

  String get formattedDate {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  String get durationText {
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    if (hours > 0 && mins > 0) return '${hours}h ${mins}m';
    if (hours > 0) return '${hours} hours';
    return '$mins mins';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'subject': subject,
        'topic': topic,
        'durationMinutes': durationMinutes,
        'questionsSolved': questionsSolved,
        'notes': notes,
        'confidenceLevel': confidenceLevel,
        'needsRevision': needsRevision,
        'nextRevisionDate': nextRevisionDate?.toIso8601String(),
      };

  factory StudyLog.fromJson(Map<String, dynamic> json) => StudyLog(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        subject: json['subject'] as String,
        topic: json['topic'] as String,
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        questionsSolved: json['questionsSolved'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
        confidenceLevel: json['confidenceLevel'] as int? ?? 3,
        needsRevision: json['needsRevision'] as bool? ?? false,
        nextRevisionDate: json['nextRevisionDate'] != null
            ? DateTime.parse(json['nextRevisionDate'] as String)
            : null,
      );
}
