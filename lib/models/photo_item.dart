import 'dart:io';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';

class PhotoItem {
  final AssetEntity asset;
  final String id;
  final DateTime createDate;
  File? _file;
  Uint8List? _thumbnail;

  PhotoItem({
    required this.asset,
  })  : id = asset.id,
        createDate = asset.createDateTime;

  Future<File?> get file async {
    _file ??= await asset.file;
    return _file;
  }

  Future<Uint8List?> get thumbnail async {
    _thumbnail ??= await asset.thumbnailDataWithSize(
      const ThumbnailSize(300, 300),
      quality: 80,
    );
    return _thumbnail;
  }

  String get filePath => asset.relativePath ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is PhotoItem && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
