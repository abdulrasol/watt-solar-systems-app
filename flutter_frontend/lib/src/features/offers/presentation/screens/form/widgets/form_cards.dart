import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/widgets/form_sections.dart';

class PriceCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget field;

  const PriceCard({
    super.key,
    required this.title,
    required this.description,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return FormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 14.h),
          field,
        ],
      ),
    );
  }
}

class NotesCard extends StatelessWidget {
  final String title;
  final String description;
  final Widget field;

  const NotesCard({
    super.key,
    required this.title,
    required this.description,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return FormSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
          SizedBox(height: 14.h),
          field,
        ],
      ),
    );
  }
}
