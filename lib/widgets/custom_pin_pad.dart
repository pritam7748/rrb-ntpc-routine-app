import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPinPad extends StatelessWidget {
  final String currentPin;
  final int maxLength;
  final Function(String) onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const CustomPinPad({
    super.key,
    required this.currentPin,
    this.maxLength = 4,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PIN Indicators (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLength, (index) {
            final isFilled = index < currentPin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: isFilled ? 18 : 14,
              height: isFilled ? 18 : 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? const Color(0xFF6366F1)
                    : Colors.transparent,
                border: Border.all(
                  color: isFilled
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF64748B),
                  width: 2,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            );
          }),
        ),
        const SizedBox(height: 36),

        // 3x4 Keypad
        Column(
          children: [
            _buildRow(['1', '2', '3']),
            const SizedBox(height: 18),
            _buildRow(['4', '5', '6']),
            const SizedBox(height: 18),
            _buildRow(['7', '8', '9']),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Biometric icon button
                if (showBiometric && onBiometricPressed != null)
                  _buildSpecialButton(
                    icon: Icons.fingerprint,
                    color: const Color(0xFF06B6D4),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onBiometricPressed!();
                    },
                  )
                else
                  const SizedBox(width: 72, height: 72),

                _buildDigitButton('0'),

                // Backspace button
                _buildSpecialButton(
                  icon: Icons.backspace_outlined,
                  color: const Color(0xFF94A3B8),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onDeletePressed();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildDigitButton(d)).toList(),
    );
  }

  Widget _buildDigitButton(String digit) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onDigitPressed(digit);
      },
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF334155)),
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
