import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/colors.dart';


class ProductImagePicker extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onChanged;
  final double height;

  const ProductImagePicker({
    super.key,
    required this.imagePath,
    required this.onChanged,
    this.height = 160,
  });

  Future<void> _pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 16),
          const Text('Product Photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ListTile(
            leading:
                Icon(Icons.camera_alt_rounded, color: AppColors.goldDark),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: AppColors.blue),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          if (imagePath != null)
            ListTile(
              leading:
                  const Icon(Icons.delete_rounded, color: AppColors.red),
              title: const Text('Remove'),
              onTap: () {
                Navigator.pop(ctx);
                onChanged(null);
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (picked != null) onChanged(picked.path);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.goldDark.withOpacity(0.4), width: 1.5),
        ),
        child: imagePath != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(imagePath!),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.crop_rounded,
                              color: AppColors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Tap to change / crop',
                              style: TextStyle(
                                  color: AppColors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.goldDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.add_photo_alternate_rounded,
                        color: AppColors.goldDark, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    imagePath == null
                        ? 'Add Product Photo'
                        : 'Change Product Photo',
                    style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text('PNG, JPG up to 10MB',
                      style:
                          TextStyle(color: AppColors.grey, fontSize: 11)),
                ],
              ),
      ),
    );
  }
}