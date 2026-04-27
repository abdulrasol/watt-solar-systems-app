import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_work/presentation/providers/company_work_provider.dart';
import 'package:solar_hub/src/services/toast_service.dart';

class CompanyWorkImagePicker extends ConsumerWidget {
  const CompanyWorkImagePicker({super.key});

  Future<void> _pickImages(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        final file = await picker.pickImage(
          source: source,
          maxWidth: 1400,
          maxHeight: 1400,
          imageQuality: 85,
        );
        if (file != null && context.mounted) {
          ref.read(companyWorkFormNotifierProvider.notifier).addImages([
            File(file.path),
          ]);
        }
      } else {
        final files = await picker.pickMultiImage(
          maxWidth: 1400,
          maxHeight: 1400,
          imageQuality: 85,
        );
        if (files.isNotEmpty && context.mounted) {
          ref
              .read(companyWorkFormNotifierProvider.notifier)
              .addImages(files.map((file) => File(file.path)).toList());
        }
      }
    } catch (_) {
      if (!context.mounted) return;
      ToastService.error(
        context,
        AppLocalizations.of(context)!.error,
        AppLocalizations.of(context)!.company_work_image_pick_failed,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(companyWorkFormNotifierProvider);
    final notifier = ref.read(companyWorkFormNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.company_work_images,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showSourceSheet(context, ref),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(l10n.add_image),
            ),
          ],
        ),
        if (state.existingImages.isEmpty && state.selectedImages.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.16)),
              color: Colors.grey.withValues(alpha: 0.04),
            ),
            child: Column(
              children: [
                Icon(Icons.image_outlined, size: 40.sp, color: Colors.grey),
                SizedBox(height: 10.h),
                Text(
                  l10n.company_work_images_empty,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              ...state.existingImages.map(
                (image) => _ImageTile(
                  key: ValueKey('existing-${image.id}'),
                  label: l10n.company_work_existing_image,
                  onDelete: () => notifier.removeExistingImage(image),
                  child: CachedNetworkImage(
                    imageUrl: image.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ...state.selectedImages.map(
                (image) => _ImageTile(
                  key: ValueKey(image.path),
                  label: l10n.company_work_new_image,
                  onDelete: () => notifier.removeSelectedImage(image),
                  child: Image.file(image, fit: BoxFit.cover),
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showSourceSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.company_work_pick_from_gallery),
              onTap: () {
                Navigator.pop(context);
                _pickImages(context, ref, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.company_work_pick_from_camera),
              onTap: () {
                Navigator.pop(context);
                _pickImages(context, ref, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    super.key,
    required this.child,
    required this.label,
    required this.onDelete,
  });

  final Widget child;
  final String label;
  final FutureOr<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 106.w,
          height: 106.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                child,
                Positioned(
                  left: 6.w,
                  right: 6.w,
                  bottom: 6.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 6.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: GestureDetector(
            onTap: () async {
              await onDelete();
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(4.r),
              child: Icon(Icons.close, size: 16.sp, color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
