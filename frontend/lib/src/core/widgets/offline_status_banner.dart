import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/services/network_status_service.dart';

class OfflineStatusBanner extends StatelessWidget {
  const OfflineStatusBanner({super.key, this.padding, this.message});

  final EdgeInsetsGeometry? padding;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final status = getIt<NetworkStatusService>();
    return ListenableBuilder(
      listenable: status,
      builder: (context, _) {
        if (!status.isOffline) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4D6),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE9B949)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.wifi_off_rounded, color: Color(0xFF8A5A00)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    message ??
                        status.lastMessage ??
                        'You are offline. Calculator tools still work, but live data may be unavailable.',
                    style: TextStyle(
                      color: const Color(0xFF6A4700),
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
