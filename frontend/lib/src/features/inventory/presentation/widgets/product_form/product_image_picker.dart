import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/inventory/presentation/providers/product_form_provider.dart';

class ProductImagePicker extends ConsumerWidget {
  const ProductImagePicker({super.key});

  Future<void> _pickImages(BuildContext context, WidgetRef ref, ImageSource source) async {
    try {
      final picker = ImagePicker();
      if (source == ImageSource.camera) {
        final pickedFile = await picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024);
        if (pickedFile != null) {
          ref.read(productFormNotifierProvider.notifier).addImages([File(pickedFile.path)]);
        }
      } else {
        final pickedFiles = await picker.pickMultiImage(maxWidth: 1024, maxHeight: 1024);
        if (pickedFiles.isNotEmpty) {
          ref.read(productFormNotifierProvider.notifier).addImages(pickedFiles.map((f) => File(f.path)).toList());
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick images')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(productFormNotifierProvider);
    final notifier = ref.read(productFormNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.productImages, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add_a_photo),
              label: Text(l10n.add_image),
              onPressed: () => _showPickerOptions(context, ref),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 120.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...state.existingImages.map((url) => _buildImageThumbnail(
                context, 
                CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
                onDelete: () => notifier.removeExistingImage(url),
              )),
              ...state.selectedImages.map((file) => _buildImageThumbnail(
                context, 
                Image.file(file, fit: BoxFit.cover),
                onDelete: () => notifier.removeSelectedImage(file),
              )),
              if (state.existingImages.isEmpty && state.selectedImages.isEmpty)
                Container(
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Icons.image_outlined, size: 40.r, color: Colors.grey),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(BuildContext context, Widget image, {required VoidCallback onDelete}) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(12.r), child: image)),
          Positioned(
            top: 4.r,
            right: 4.r,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.close, size: 16.r, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(context, ref, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
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
