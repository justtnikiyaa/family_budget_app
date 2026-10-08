import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Custom numeric keypad widget for amount input
/// Part of Amarasinghe A.L.O.A implementation
class CustomNumericKeypad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const CustomNumericKeypad({
    super.key,
    required this.onNumberTap,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 8),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 8),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 8),
          _buildKeypadRow(['.', '0', '⌫']),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String key) {
    final isBackspace = key == '⌫';
    final isClear = key == 'C';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: isBackspace || isClear 
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () {
              if (isBackspace) {
                onBackspace();
              } else if (isClear) {
                onClear();
              } else {
                onNumberTap(key);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                key,
                style: TextStyle(
                  fontSize: isBackspace ? 24 : 22,
                  fontWeight: FontWeight.w600,
                  color: isBackspace || isClear 
                      ? AppColors.primary 
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
