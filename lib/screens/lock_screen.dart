import 'dart:math';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/custom_pin_pad.dart';
import 'home_screen.dart';

class LockScreen extends StatefulWidget {
  final bool isInitialSetup;

  const LockScreen({
    super.key,
    this.isInitialSetup = false,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _errorMessage;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Auto trigger biometric if security enabled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isInitialSetup && StorageService.isSecurityEnabled()) {
        _triggerBiometrics();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _triggerBiometrics() async {
    final success = await AuthService.authenticateWithBiometrics();
    if (success && mounted) {
      _unlockApp();
    }
  }

  void _onDigit(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _errorMessage = null;
      });

      if (_pin.length == 4) {
        _verifyOrSetPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyOrSetPin() async {
    if (widget.isInitialSetup || StorageService.getUserPin() == null) {
      // Set new PIN
      await StorageService.setUserPin(_pin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN Successfully Created!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _unlockApp();
      }
    } else {
      // Verify existing PIN
      if (AuthService.verifyPin(_pin)) {
        _unlockApp();
      } else {
        _shakeController.forward(from: 0.0);
        setState(() {
          _errorMessage = 'Incorrect PIN. Try again.';
          _pin = '';
        });
      }
    }
  }

  void _unlockApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const HomeScreen(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPin = StorageService.getUserPin() != null;
    final isSetup = widget.isInitialSetup || !hasPin;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const Spacer(),
              // Header Icon & Lock Animation
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 42,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isSetup ? 'Set Security PIN' : 'Enter Security PIN',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isSetup
                    ? 'Create a 4-digit PIN to protect your RRB NTPC routine & notes'
                    : 'Use your PIN or fingerprint to access your study planner',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 24),

              // Error display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

              // Custom Keypad with Shake Animation on incorrect PIN
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = sin(_shakeController.value * pi * 4) * 12;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: CustomPinPad(
                  currentPin: _pin,
                  maxLength: 4,
                  showBiometric: !isSetup && StorageService.isBiometricEnabled(),
                  onDigitPressed: _onDigit,
                  onDeletePressed: _onDelete,
                  onBiometricPressed: _triggerBiometrics,
                ),
              ),

              const Spacer(),

              // Skip option if first time setup
              if (isSetup)
                TextButton(
                  onPressed: () {
                    StorageService.setSecurityEnabled(false);
                    _unlockApp();
                  },
                  child: const Text(
                    'Skip PIN setup for now',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
