import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const String adminSupportEmail = 'abdulrasol97@gmail.com';
const String adminSupportPhone = '07813639721';

enum AdminSupportChannelType { phone, email, chat }

class AdminSupportChannel {
  const AdminSupportChannel({
    required this.type,
    required this.value,
    this.enabled = true,
  });

  final AdminSupportChannelType type;
  final String value;
  final bool enabled;
}

class AdminSupportConfig {
  const AdminSupportConfig({
    required this.email,
    required this.phone,
    this.isChatEnabled = false,
  });

  final String email;
  final String phone;
  final bool isChatEnabled;

  List<AdminSupportChannel> get channels => [
    AdminSupportChannel(type: AdminSupportChannelType.phone, value: phone),
    AdminSupportChannel(type: AdminSupportChannelType.email, value: email),
    AdminSupportChannel(
      type: AdminSupportChannelType.chat,
      value: 'admin_chat',
      enabled: isChatEnabled,
    ),
  ];
}

const AdminSupportConfig appAdminSupportConfig = AdminSupportConfig(
  email: adminSupportEmail,
  phone: adminSupportPhone,
  isChatEnabled: false,
);

final inputDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderSide: BorderSide(width: 1),
    borderRadius: BorderRadius.all(Radius.circular(7.0)),
  ),
);
SizedBox horSpace({double space = 12}) {
  return SizedBox(width: space.w);
}

SizedBox verSpace({double space = 12}) {
  return SizedBox(height: space.h);
}
