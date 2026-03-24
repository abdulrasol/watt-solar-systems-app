import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final inputDecoration = InputDecoration(
  border: OutlineInputBorder(borderSide: BorderSide(width: 1), borderRadius: BorderRadius.all(Radius.circular(7.0))),
);
SizedBox horSpace({double space = 12}) {
  return SizedBox(width: space.w);
}

SizedBox verSpace({double space = 12}) {
  return SizedBox(height: space.h);
}
