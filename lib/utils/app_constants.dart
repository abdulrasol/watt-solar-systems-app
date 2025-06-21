import 'package:flutter/material.dart';
import 'package:get/get.dart';

String appSlug = 'appSlug'.tr;

final inputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderSide: BorderSide(width: 1),
    borderRadius: BorderRadius.all(Radius.circular(7.0)),
  ),
);
SizedBox horSpace({double space = 12}) {
  return SizedBox(width: space);
}

SizedBox verSpace({double space = 12}) {
  return SizedBox(height: space);
}
