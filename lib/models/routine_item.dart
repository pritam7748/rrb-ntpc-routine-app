class RoutineItem {
  final String id;
  String title;
  String category;
  int hour;
  int minute;
  bool isEnabled;
  bool isPersistentAlarm;
  List<int> repeatDays; // 1 = Mon, 7 = Sun
  int colorHex;

  RoutineItem({
    required this.id,
    required this.title,
    required this.category,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.isPersistentAlarm = true,
    required this.repeatDays,
    this.colorHex = 0xFF6366F1,
  });

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMin = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMin $period';
  }

  String get daysSummary {
    if (repeatDays.length == 7) return 'Every day';
    if (repeatDays.isEmpty) return 'Once';
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((d) => dayNames[d - 1]).join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'hour': hour,
        'minute': minute,
        'isEnabled': isEnabled,
        'isPersistentAlarm': isPersistentAlarm,
        'repeatDays': repeatDays,
        'colorHex': colorHex,
      };

  factory RoutineItem.fromJson(Map<String, dynamic> json) => RoutineItem(
        id: json['id'] as String,
        title: json['title'] as String,
        category: json['category'] as String? ?? 'General Routine',
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        isEnabled: json['isEnabled'] as bool? ?? true,
        isPersistentAlarm: json['isPersistentAlarm'] as bool? ?? true,
        repeatDays: (json['repeatDays'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [1, 2, 3, 4, 5, 6, 7],
        colorHex: json['colorHex'] as int? ?? 0xFF6366F1,
      );
}
