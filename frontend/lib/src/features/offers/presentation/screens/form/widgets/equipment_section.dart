import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/widgets/form_sections.dart';

class EquipmentSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Widget> fields;
  final Widget? topChild;
  final Widget noteField;
  final Widget? totalTile;
  final int fieldsPerRow;

  const EquipmentSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.fields,
    this.topChild,
    required this.noteField,
    this.totalTile,
    this.fieldsPerRow = 2,
  });

  @override
  Widget build(BuildContext context) {
    return FormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormSectionTitle(
            title: title,
            subtitle: subtitle,
            icon: icon,
            accent: accent,
          ),
          if (topChild != null) ...[SizedBox(height: 16.h), topChild!],
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final perRow = fieldsPerRow < 1 ? 1 : fieldsPerRow;
              final spacing = 12.w;
              final itemWidth =
                  (constraints.maxWidth - (spacing * (perRow - 1))) / perRow;

              return Wrap(
                spacing: spacing,
                runSpacing: 12.h,
                children: [
                  for (final field in fields)
                    SizedBox(width: itemWidth, child: field),
                ],
              );
            },
          ),
          if (totalTile != null) ...[SizedBox(height: 12.h), totalTile!],
          SizedBox(height: 12.h),
          noteField,
        ],
      ),
    );
  }
}
