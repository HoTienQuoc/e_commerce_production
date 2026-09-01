import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/theme/theme.dart';
import 'package:frontend_admin/core/utils/web_image_utils.dart';

class ProductImagePicker extends StatelessWidget {
  final Function(List<Uint8List>, List<String>, List<bool>) onImagesSelected;

  const ProductImagePicker({super.key, required this.onImagesSelected});

  static Future<void> pickImagesStatic(
    Function(List<Uint8List>, List<String>, List<bool>) onImagesSelected,
  ) async {
    try {
      final result = await FilePicker.pickFiles(type: FileType.image);

      if (result.isNotEmpty) {
        final newImageFiles = <Uint8List>[];
        final newImageUrls = <String>[];
        final newIsPrimaryFlags = <bool>[];

        for (var file in result) {
          try {
            final bytes = await file.readAsBytes();

            if (!WebImageUtils.validateImageSize(bytes)) {
              debugPrint('Image size exceeds the 2MB limit');
              continue;
            }

            final mimeType = 'image/${file.extension?.toLowerCase() ?? 'jpeg'}';
            final dataUrl = WebImageUtils.encodeToDataUrl(bytes, mimeType);

            // First valid image becomes primary.
            newIsPrimaryFlags.add(newImageFiles.isEmpty);
            newImageFiles.add(bytes);
            newImageUrls.add(dataUrl);
          } catch (e) {
            debugPrint('Error reading image ${file.name}: $e');
          }
        }

        if (newImageFiles.isNotEmpty) {
          onImagesSelected(newImageFiles, newImageUrls, newIsPrimaryFlags);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> pickImages() async {
    await ProductImagePicker.pickImagesStatic(onImagesSelected);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: pickImages,
      icon: Icon(Icons.add_photo_alternate, color: AppTheme.accentBlue),
      label: Text(
        'Add Image',
        style: AppTheme.bodyMedium().copyWith(color: AppTheme.accentBlue),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.accentBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        ),
      ),
    );
  }
}
