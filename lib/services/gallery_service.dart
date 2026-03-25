import 'dart:io';
import 'package:flutter/services.dart';
import '../models/photo_item.dart';

/// Service to open images in the device's native gallery app.
class GalleryService {
  static const _channel = MethodChannel('com.smartgallery/gallery');

  /// Open the image in the device's default gallery/photos app.
  static Future<bool> revealInGallery(PhotoItem photo) async {
    try {
      final file = await photo.file;
      if (file == null) return false;

      // Use platform channel to open in gallery
      final result = await _channel.invokeMethod<bool>(
        'openInGallery',
        {'path': file.path, 'id': photo.id},
      );
      return result ?? false;
    } on PlatformException catch (_) {
      // Fallback: try to open with open_filex
      return _fallbackOpen(photo);
    } catch (_) {
      return _fallbackOpen(photo);
    }
  }

  static Future<bool> _fallbackOpen(PhotoItem photo) async {
    try {
      final file = await photo.file;
      if (file == null) return false;

      // Use open_filex as fallback
      // Import is dynamic to avoid hard dependency
      final result = await Process.run('am', [
        'start',
        '-a', 'android.intent.action.VIEW',
        '-d', 'file://${file.path}',
        '-t', 'image/*',
      ]);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}
