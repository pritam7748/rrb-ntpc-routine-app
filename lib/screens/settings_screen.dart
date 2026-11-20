import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'lock_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _securityEnabled = false;
  bool _biometricEnabled = true;
  final AudioPlayer _previewPlayer = AudioPlayer();
  bool _isPlayingPreview = false;

  @override
  void initState() {
    super.initState();
    _securityEnabled = StorageService.isSecurityEnabled();
    _biometricEnabled = StorageService.isBiometricEnabled();
  }

  @override
  void dispose() {
    _previewPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleSoundPreview() async {
    if (_isPlayingPreview) {
      await _previewPlayer.stop();
      setState(() => _isPlayingPreview = false);
    } else {
      setState(() => _isPlayingPreview = true);
      await _previewPlayer.play(AssetSource('audio/rrb_alarm.wav'));
      _previewPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingPreview = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Security Section
          const Text(
            'নিরাপত্তা ও প্রাইভেসি (SECURITY)',
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.security, color: Color(0xFF6366F1)),
                  title: const Text('App Lock (PIN Security)'),
                  subtitle: const Text('অ্যাপ খোলার সময় ৪-ডিজিট পিন লক চাইবে'),
                  value: _securityEnabled,
                  activeColor: const Color(0xFF6366F1),
                  onChanged: (val) async {
                    if (val && StorageService.getUserPin() == null) {
                      // Navigate to setup PIN
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LockScreen(isInitialSetup: true),
                        ),
                      );
                    } else {
                      await StorageService.setSecurityEnabled(val);
                      setState(() => _securityEnabled = val);
                    }
                  },
                ),
                const Divider(height: 1, color: Color(0xFF334155)),
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint, color: Color(0xFF06B6D4)),
                  title: const Text('Fingerprint / Biometric'),
                  subtitle: const Text('আঙ্গুলের ছাপ দিয়ে এক ক্লিকে আনলক'),
                  value: _biometricEnabled,
                  activeColor: const Color(0xFF06B6D4),
                  onChanged: (val) async {
                    await StorageService.setBiometricEnabled(val);
                    setState(() => _biometricEnabled = val);
                  },
                ),
                const Divider(height: 1, color: Color(0xFF334155)),
                ListTile(
                  leading: const Icon(Icons.pin, color: Colors.amber),
                  title: const Text('Change Security PIN'),
                  subtitle: const Text('নতুন ৪-সংখ্যার পাসকোড সেট করুন'),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LockScreen(isInitialSetup: true),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Alarm & Sound Section
          const Text(
            'অ্যালার্ম ও সাউন্ড (CUSTOM ALARM TONE)',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.music_note_rounded, color: Color(0xFFEF4444)),
                  title: const Text('App Custom Alarm Sound'),
                  subtitle: const Text('উচ্চ-ক্ষমতাসম্পন্ন কাস্টম অ্যালার্ম সুর (RRB Wake-up)'),
                  trailing: ElevatedButton.icon(
                    onPressed: _toggleSoundPreview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isPlayingPreview
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: Icon(
                      _isPlayingPreview ? Icons.stop : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(_isPlayingPreview ? 'Stop' : 'Play'),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFF334155)),
                const ListTile(
                  leading: Icon(Icons.alarm_on, color: Colors.green),
                  title: Text('Continuous Ringing'),
                  subtitle: Text('স্বাভাবিক নোটিফিকেশনের মত নয়, বন্ধ না করা পর্যন্ত বাজবে'),
                  trailing: Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          const Text(
            'অ্যাপ ইনফো (ABOUT APP)',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.train, color: Color(0xFF06B6D4), size: 24),
                      SizedBox(width: 10),
                      Text(
                        'RRB NTPC Routine & Study App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Version: 1.0.0 (GitHub Actions CI/CD Built)\nCreated specially for Indian Railways NTPC Aspirants.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_done, color: Color(0xFF10B981), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'GitHub Actions দিয়ে সরাসরি ক্লাউডে অটোম্যাটিক APK বিল্ড হয়।',
                            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
