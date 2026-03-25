import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import '../models/photo_item.dart';

/// Service to open images in the device's native gallery app.
class GalleryService {
  static const _channel = MethodChannel('com.smartgallery/gallery');

  /// Open the image in the device's default gallery/photos app.
  static Future<bool> revealInGallery(PhotoItem photo) async {
    try {
      final file = await photo.file;
      if (file == null) return false;

      // Try platform channel first (Android native intent)
      try {
        final result = await _channel.invokeMethod<bool>(
          'openInGallery',
          {'path': file.path, 'id': photo.id},
        );
        if (result == true) return true;
      } on PlatformException catch (_) {
        // Platform channel not available, fall through to OpenFilex
      } on MissingPluginException catch (_) {
        // Platform channel not registered, fall through to OpenFilex
      }

      // Fallback: use open_filex which works cross-platform
      final result = await OpenFilex.open(file.path);
      return result.type == ResultType.done;
    } catch (_) {
      return false;
    }
  }
}
