import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/routine_item.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<RoutineItem> _routines = [];

  final List<String> _categories = [
    'Mathematics',
    'Reasoning',
    'General Awareness',
    'General Science',
    'Mock Test',
    'General Routine',
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  void _loadRoutines() {
    setState(() {
      _routines = StorageService.getRoutines();
    });
  }

  void _openAddRoutineSheet([RoutineItem? existingItem]) {
    final formKey = GlobalKey<FormState>();
    String title = existingItem?.title ?? '';
    String category = existingItem?.category ?? _categories[0];
    TimeOfDay selectedTime = existingItem != null
        ? TimeOfDay(hour: existingItem.hour, minute: existingItem.minute)
        : const TimeOfDay(hour: 7, minute: 0);
    bool isPersistentAlarm = existingItem?.isPersistentAlarm ?? true;
    List<int> repeatDays = existingItem != null
        ? List.from(existingItem.repeatDays)
        : [1, 2, 3, 4, 5, 6, 7];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingItem == null
                                ? 'নতুন রুটিন যোগ করুন (Add Routine)'
                                : 'রুটিন এডিট করুন (Edit Routine)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFF334155)),
                      const SizedBox(height: 12),

                      // Title
                      const Text(
                        'রুটিনের নাম (Routine Title):',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: title,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Maths Speed Test, Morning General Awareness',
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Enter routine title' : null,
                        onSaved: (val) => title = val!.trim(),
                      ),
                      const SizedBox(height: 14),

                      // Category
                      const Text(
                        'ক্যাটেগরি (Category):',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: category,
                        dropdownColor: const Color(0xFF1E293B),
                        items: _categories
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => category = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'রিমাইন্ডার সময় (Time):',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                          InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setModalState(() => selectedTime = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0xFF6366F1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      color: Color(0xFF6366F1), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedTime.format(context),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Persistent Alarm Switch
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isPersistentAlarm
                              ? const Color(0xFFEF4444).withOpacity(0.12)
                              : const Color(0xFF334155).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPersistentAlarm
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF475569),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'অ্যালার্ম মোড (Persistent Alarm)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: const Text(
                            'অ্যাপের কাস্টম সাউন্ডে বাজবে, বন্ধ না করা পর্যন্ত বাজতেই থাকবে',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                          value: isPersistentAlarm,
                          activeColor: const Color(0xFFEF4444),
                          onChanged: (val) {
                            setModalState(() => isPersistentAlarm = val);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Repeat Days
                      const Text(
                        'দিন নির্বাচন করুন (Repeat Days):',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDayChip('M', 1, repeatDays, setModalState),
                          _buildDayChip('T', 2, repeatDays, setModalState),
                          _buildDayChip('W', 3, repeatDays, setModalState),
                          _buildDayChip('T', 4, repeatDays, setModalState),
                          _buildDayChip('F', 5, repeatDays, setModalState),
                          _buildDayChip('S', 6, repeatDays, setModalState),
                          _buildDayChip('S', 7, repeatDays, setModalState),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              final item = RoutineItem(
                                id: existingItem?.id ?? const Uuid().v4(),
                                title: title,
                                category: category,
                                hour: selectedTime.hour,
                                minute: selectedTime.minute,
                                isPersistentAlarm: isPersistentAlarm,
                                repeatDays: repeatDays,
                                isEnabled: true,
                              );
                              if (existingItem == null) {
                                await StorageService.addRoutine(item);
                              } else {
                                await StorageService.updateRoutine(item);
                              }
                              await AlarmService.scheduleRoutine(item);
                              _loadRoutines();
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: Text(existingItem == null
                              ? 'রুটিন সেভ করুন'
                              : 'আপডেট করুন'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayChip(
      String label, int dayNum, List<int> days, StateSetter setModalState) {
    final isSelected = days.contains(dayNum);
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (isSelected) {
            if (days.length > 1) days.remove(dayNum);
          } else {
            days.add(dayNum);
          }
        });
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF334155),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Mathematics':
        return const Color(0xFF6366F1);
      case 'Reasoning':
        return const Color(0xFFF59E0B);
      case 'General Awareness':
        return const Color(0xFF06B6D4);
      case 'General Science':
        return const Color(0xFF10B981);
      case 'Mock Test':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Study Routines'),
        actions: [
          // Instant Alarm Test Button
          TextButton.icon(
            onPressed: () {
              AlarmService.startAlarmRinging(
                title: 'Mathematics Practice Session',
                category: 'RRB NTPC Study Routine',
              );
            },
            icon: const Icon(Icons.alarm_on, color: Color(0xFFEF4444), size: 18),
            label: const Text(
              'Test Alarm',
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRoutineSheet(),
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.alarm_add_rounded, color: Colors.white),
        label: const Text(
          'নতুন রুটিন+',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _routines.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_off_rounded,
                    size: 64,
                    color: const Color(0xFF64748B).withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'কোনো রুটিন পাওয়া যায়নি',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 12, bottom: 80),
              itemCount: _routines.length,
              itemBuilder: (context, index) {
                final item = _routines[index];
                final catColor = _getCategoryColor(item.category);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Time & Category
                            Row(
                              children: [
                                Text(
                                  item.formattedTime,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: catColor.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      color: catColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Switch
                            Switch(
                              value: item.isEnabled,
                              activeColor: const Color(0xFF6366F1),
                              onChanged: (val) async {
                                item.isEnabled = val;
                                await StorageService.updateRoutine(item);
                                if (val) {
                                  await AlarmService.scheduleRoutine(item);
                                }
                                _loadRoutines();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (item.isPersistentAlarm) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.volume_up,
                                            size: 12, color: Color(0xFFEF4444)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Persistent Alarm',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  item.daysSummary,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      size: 18, color: Color(0xFF94A3B8)),
                                  onPressed: () => _openAddRoutineSheet(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Color(0xFF94A3B8)),
                                  onPressed: () async {
                                    await StorageService.deleteRoutine(item.id);
                                    _loadRoutines();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
