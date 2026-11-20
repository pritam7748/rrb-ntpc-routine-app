import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/study_log.dart';
import '../services/storage_service.dart';

class StudyLogScreen extends StatefulWidget {
  const StudyLogScreen({super.key});

  @override
  State<StudyLogScreen> createState() => _StudyLogScreenState();
}

class _StudyLogScreenState extends State<StudyLogScreen> {
  List<StudyLog> _logs = [];
  String _selectedFilter = 'All';

  final List<String> _subjects = [
    'Mathematics (Maths)',
    'General Intelligence & Reasoning',
    'General Awareness & Current Affairs',
    'General Science (Physics/Chem/Bio)',
    'RRB NTPC Mock Test',
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _logs = StorageService.getStudyLogs();
    });
  }

  void _openAddLogDialog() {
    final formKey = GlobalKey<FormState>();
    String selectedSubject = _subjects[0];
    String topic = '';
    int durationMinutes = 60;
    int questionsSolved = 25;
    String notes = '';
    int confidenceLevel = 4;
    bool needsRevision = true;

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
                          const Text(
                            'আজ কী পড়লেন? (Add Study Log)',
                            style: TextStyle(
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

                      // Subject Selector
                      const Text(
                        'বিষয় (Subject):',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedSubject,
                        dropdownColor: const Color(0xFF1E293B),
                        items: _subjects
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedSubject = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Topic
                      const Text(
                        'টপিক বা অধ্যায় (Topic / Chapter):',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'e.g. Time & Work, Coding-Decoding, Indian Railways GK',
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Please enter topic' : null,
                        onSaved: (val) => topic = val!.trim(),
                      ),
                      const SizedBox(height: 14),

                      // Duration & Questions Solved
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'পড়ার সময় (মিনিট):',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: '60',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    suffixText: 'mins',
                                  ),
                                  validator: (val) =>
                                      int.tryParse(val ?? '') == null ? 'Invalid' : null,
                                  onSaved: (val) => durationMinutes = int.parse(val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MCQ প্র্যাকটিস (সংখ্যা):',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  initialValue: '25',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    suffixText: 'MCQs',
                                  ),
                                  validator: (val) =>
                                      int.tryParse(val ?? '') == null ? 'Invalid' : null,
                                  onSaved: (val) => questionsSolved = int.parse(val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Important notes / formulas
                      const Text(
                        'গুরুত্বপূর্ণ নোট / ফর্মুলা / রিভিশন পয়েন্ট:',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'সূত্র, গুরুত্বপূর্ণ সাল, বা মক টেস্টের ভুলের কারণ...',
                        ),
                        onSaved: (val) => notes = val ?? '',
                      ),
                      const SizedBox(height: 14),

                      // Confidence Level (1-5)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'আত্মবিশ্বাস (Confidence):',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              final starIndex = index + 1;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() => confidenceLevel = starIndex);
                                },
                                child: Icon(
                                  starIndex <= confidenceLevel
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Needs Revision Checkbox
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'রিভিশন প্রয়োজন (Needs Revision)',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        value: needsRevision,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (val) => setModalState(() => needsRevision = val),
                      ),
                      const SizedBox(height: 16),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState!.save();
                              final newLog = StudyLog(
                                id: const Uuid().v4(),
                                date: DateTime.now(),
                                subject: selectedSubject,
                                topic: topic,
                                durationMinutes: durationMinutes,
                                questionsSolved: questionsSolved,
                                notes: notes,
                                confidenceLevel: confidenceLevel,
                                needsRevision: needsRevision,
                                nextRevisionDate: needsRevision
                                    ? DateTime.now().add(const Duration(days: 3))
                                    : null,
                              );
                              await StorageService.addStudyLog(newLog);
                              _loadLogs();
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.save_rounded),
                          label: const Text('সংরক্ষণ করুন (Save Study Log)'),
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

  Color _getSubjectColor(String subject) {
    if (subject.contains('Maths')) return const Color(0xFF6366F1);
    if (subject.contains('Reasoning')) return const Color(0xFFF59E0B);
    if (subject.contains('Science')) return const Color(0xFF10B981);
    if (subject.contains('Awareness') || subject.contains('Current')) {
      return const Color(0xFF06B6D4);
    }
    return const Color(0xFFEC4899);
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _selectedFilter == 'All'
        ? _logs
        : _logs.where((l) => l.subject.contains(_selectedFilter)).toList();

    final totalMinutes = _logs.fold<int>(0, (sum, item) => sum + item.durationMinutes);
    final totalMCQs = _logs.fold<int>(0, (sum, item) => sum + item.questionsSolved);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RRB NTPC Study Journal'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddLogDialog,
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'আজ কী পড়লাম+',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Total Study Hours & MCQs Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'মোট পড়াশোনা',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalMinutes ~/ 60}h ${totalMinutes % 60}m',
                        style: const TextStyle(
                          color: Color(0xFF06B6D4),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 35, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      const Text(
                        'মোট প্র্যাকটিস MCQ',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalMCQs MCQs',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 35, color: const Color(0xFF334155)),
                  Column(
                    children: [
                      const Text(
                        'মোট অধ্যায়',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_logs.length}',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Subject Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['All', 'Maths', 'Reasoning', 'Awareness', 'Science', 'Mock']
                  .map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: const Color(0xFF1E293B),
                    selectedColor: const Color(0xFF6366F1),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF334155),
                    ),
                    onSelected: (val) {
                      setState(() => _selectedFilter = filter);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Log List
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 64,
                          color: const Color(0xFF64748B).withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'আজকের পড়ার এন্ট্রি এখনো যোগ করেননি',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'নিচের "+ আজ কী পড়লাম" বাটনে ক্লিক করে যোগ করুন',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 80),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final item = filteredLogs[index];
                      final subjectColor = _getSubjectColor(item.subject);

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
                                  // Subject Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: subjectColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: subjectColor.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      item.subject,
                                      style: TextStyle(
                                        color: subjectColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item.formattedDate,
                                        style: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 18, color: Color(0xFF94A3B8)),
                                        onPressed: () async {
                                          await StorageService.deleteStudyLog(item.id);
                                          _loadLogs();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.topic,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined,
                                      size: 14, color: Colors.blue.shade300),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.durationText,
                                    style: TextStyle(
                                        color: Colors.blue.shade300, fontSize: 12),
                                  ),
                                  const SizedBox(width: 14),
                                  Icon(Icons.check_circle_outline,
                                      size: 14, color: Colors.green.shade300),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.questionsSolved} MCQs',
                                    style: TextStyle(
                                        color: Colors.green.shade300, fontSize: 12),
                                  ),
                                  const SizedBox(width: 14),
                                  Row(
                                    children: List.generate(
                                      item.confidenceLevel,
                                      (i) => const Icon(Icons.star,
                                          size: 12, color: Colors.amber),
                                    ),
                                  ),
                                ],
                              ),
                              if (item.notes.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    item.notes,
                                    style: const TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
