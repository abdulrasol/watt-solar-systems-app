import 'package:flutter/material.dart';

class ResponsiveRowColumn extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double triggerWidth; // Width below which we switch to column

  const ResponsiveRowColumn({super.key, required this.children, this.spacing = 16.0, this.runSpacing = 16.0, this.triggerWidth = 600});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= triggerWidth) {
          // Desktop: Row with Expanded children if possible, or just flexible
          // Usually form fields in a row are Expanded.
          // Let's assume equal distribution for this helper.
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(width: spacing), Expanded(child: children[i])],
            ],
          );
        } else {
          // Mobile: Column
          return Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: runSpacing), children[i]],
            ],
          );
        }
      },
    );
  }
}
