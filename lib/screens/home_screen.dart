import 'package:flutter/material.dart';
import '../models/routine_item.dart';
import '../models/study_log.dart';
import '../services/alarm_service.dart';
import '../services/storage_service.dart';
import '../widgets/ntpc_countdown_card.dart';
import '../widgets/study_stat_card.dart';
import 'routine_screen.dart';
import 'study_log_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardTab(),
      const RoutineScreen(),
      const StudyLogScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          border: Border(top: BorderSide(color: Color(0xFF334155), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFF6366F1).withOpacity(0.25),
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF6366F1)),
              label: 'ড্যাশবোর্ড',
            ),
            NavigationDestination(
              icon: Icon(Icons.alarm_outlined),
              selectedIcon: Icon(Icons.alarm_rounded, color: Color(0xFF6366F1)),
              label: 'রুটিন ও অ্যালার্ম',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded, color: Color(0xFF6366F1)),
              label: 'আজ কী পড়লাম',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF6366F1)),
              label: 'সেটিংস',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List<RoutineItem> _routines = [];
  List<StudyLog> _logs = [];
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _routines = StorageService.getRoutines();
      _logs = StorageService.getStudyLogs();
      _streak = StorageService.getStreakCount();
    });
  }

  RoutineItem? get _nextRoutine {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final enabled = _routines.where((r) => r.isEnabled).toList();
    if (enabled.isEmpty) return null;

    // Find next today
    enabled.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    for (final r in enabled) {
      if ((r.hour * 60 + r.minute) >= nowMinutes) {
        return r;
      }
    }
    return enabled.first;
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutesToday = _logs.fold<int>(0, (sum, e) => sum + e.durationMinutes);
    final totalMCQsToday = _logs.fold<int>(0, (sum, e) => sum + e.questionsSolved);
    final activeRoutinesCount = _routines.where((r) => r.isEnabled).length;
    final next = _nextRoutine;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_railway_filled, color: Color(0xFF06B6D4), size: 22),
            SizedBox(width: 8),
            Text('RRB NTPC Planner'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Motivational Banner & Streak Card
            NtpcCountdownCard(streakDays: _streak),
            const SizedBox(height: 18),

            // Next Routine Highlight Card
            if (next != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.access_alarm_rounded,
                        color: Color(0xFF6366F1),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'পরবর্তী রুটিন (Next Upcoming)',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            next.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Time: ${next.formattedTime} (${next.category})',
                            style: const TextStyle(
                              color: Color(0xFF06B6D4),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_circle_fill_rounded,
                          color: Color(0xFFEF4444), size: 32),
                      tooltip: 'Trigger Alarm Now',
                      onPressed: () {
                        AlarmService.startAlarmRinging(
                          title: next.title,
                          category: next.category,
                        );
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            // Statistics Grid (Study Hours, MCQs, Routines)
            Row(
              children: [
                Expanded(
                  child: StudyStatCard(
                    title: 'আজকের পড়া',
                    value: '${totalMinutesToday ~/ 60}h ${totalMinutesToday % 60}m',
                    subtitle: 'Study Time',
                    icon: Icons.timer,
                    accentColor: const Color(0xFF06B6D4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StudyStatCard(
                    title: 'প্র্যাকটিস MCQ',
                    value: '$totalMCQsToday',
                    subtitle: 'Questions',
                    icon: Icons.assignment_turned_in,
                    accentColor: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StudyStatCard(
                    title: 'অ্যাক্টিভ অ্যালার্ম',
                    value: '$activeRoutinesCount',
                    subtitle: 'Routines',
                    icon: Icons.alarm,
                    accentColor: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StudyStatCard(
                    title: 'টপিক স্টোর',
                    value: '${_logs.length}',
                    subtitle: 'Topics Saved',
                    icon: Icons.bookmarks_rounded,
                    accentColor: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Recent Study Entries Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'সাম্প্রতিক পড়ার হিস্ট্রি',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to StudyLog tab
                    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                    homeState?.setState(() => homeState._currentIndex = 2);
                  },
                  child: const Text('সব দেখুন (View All)'),
                ),
              ],
            ),

            if (_logs.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Center(
                  child: Text(
                    'আজকের পড়ার কোনো তথ্য এখনো যোগ করেননি।\n"আজ কী পড়লাম" ট্যাবে গিয়ে সহজে যোগ করুন!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              )
            else
              ..._logs.take(3).map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                      child: const Icon(Icons.book, color: Color(0xFF6366F1), size: 18),
                    ),
                    title: Text(
                      item.topic,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${item.subject} • ${item.durationText} • ${item.questionsSolved} MCQs',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    trailing: Text(
                      item.formattedDate.split(',').last.trim(),
                      style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
