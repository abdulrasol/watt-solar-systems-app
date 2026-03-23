import 'package:flutter/material.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Animated pill chip row for voltage/option selection.
class VoltageChips extends StatelessWidget {
  const VoltageChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<double> options;
  final double selected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((v) {
        final isSelected = selected == v;
        return GestureDetector(
          onTap: () => onSelected(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              '${v.toString().replaceAll('.0', '')}V',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
