import 'dart:math';
import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../widgets/animated_pulse_ring.dart';
import 'study_log_screen.dart';

class AlarmRingingScreen extends StatefulWidget {
  final String title;
  final String category;
  final int? alarmId; // ✅ যুক্ত করা হয়েছে

  const AlarmRingingScreen({
    super.key,
    required this.title,
    required this.category,
    this.alarmId, // ✅ যুক্ত করা হয়েছে
  });

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  late int num1;
  late int num2;
  late int solution;
  final TextEditingController _mathAnswerController = TextEditingController();
  bool _showMathChallenge = false;
  String? _mathError;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);

    _generateMathChallenge();
  }

  void _generateMathChallenge() {
    final rand = Random();
    num1 = rand.nextInt(20) + 10;
    num2 = rand.nextInt(20) + 5;
    solution = num1 + num2;
  }

  @override
  void dispose() {
    _bellController.dispose();
    _mathAnswerController.dispose();
    super.dispose();
  }

  Future<void> _dismissAlarm({bool openStudyLog = false}) async {
    // ✅ নির্দিষ্ট অ্যালার্মটি সাথে সাথে ব্যাকগ্রাউন্ড সার্ভিসসহ বন্ধ হবে
    await AlarmService.stopAlarm(widget.alarmId);
    if (mounted) {
      if (openStudyLog) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const StudyLogScreen(),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _checkMathAnswer() {
    final val = int.tryParse(_mathAnswerController.text.trim());
    if (val == solution) {
      _dismissAlarm(openStudyLog: true);
    } else {
      setState(() {
        _mathError = 'ভুল উত্তর! আবার চেষ্টা করুন ($num1 + $num2 = ?)';
        _mathAnswerController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hourDisplay = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minDisplay = now.minute.toString().padLeft(2, '0');
    final amPm = now.hour >= 12 ? 'PM' : 'AM';

    return PopScope(
      canPop: false, // Cannot bypass back button without dismissing
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF0F172A), Color(0xFF31102A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // App Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'PERSISTENT ALARM IS RINGING',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Big Clock Display
                  Text(
                    '$hourDisplay:$minDisplay',
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    amPm,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),

                  const Spacer(),

                  // Pulsing Animated Bell
                  AnimatedPulseRing(
                    pulseColor: const Color(0xFFEF4444),
                    maxRadius: 110,
                    child: AnimatedBuilder(
                      animation: _bellController,
                      builder: (context, child) {
                        final angle = (_bellController.value - 0.5) * 0.4;
                        return Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFEF4444), Color(0xFF991B1B)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(),

                  // Routine Information
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.category.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF06B6D4),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'অ্যালার্ম বন্ধ না করা পর্যন্ত বাজতেই থাকবে!',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Math Challenge or Direct Stop
                  if (_showMathChallenge) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Solve RRB NTPC Math: $num1 + $num2 = ?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _mathAnswerController,
                                  keyboardType: TextInputType.number,
                                  autofocus: true,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Answer',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _checkMathAnswer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                          if (_mathError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _mathError!,
                                style: const TextStyle(
                                    color: Color(0xFFEF4444), fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      // Direct Dismiss
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _dismissAlarm(openStudyLog: false),
                          icon: const Icon(Icons.alarm_off_rounded, color: Colors.white),
                          label: const Text('বন্ধ করুন (Dismiss)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Wake up & Open Study Log
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _dismissAlarm(openStudyLog: true),
                          icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
                          label: const Text('পড়তে বসুন (Study)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Wake Up Brain Math Challenge Toggle
                  if (!_showMathChallenge)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showMathChallenge = true;
                        });
                      },
                      icon: const Icon(Icons.calculate_outlined,
                          color: Color(0xFF94A3B8), size: 16),
                      label: const Text(
                        'Wake-up Math Challenge',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
