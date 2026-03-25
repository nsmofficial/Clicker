import 'dart:typed_data';
import 'photo_item.dart';

enum GroupType { person, category }

class PhotoGroup {
  final String id;
  final String name;
  final GroupType type;
  final List<PhotoItem> photos;
  Uint8List? coverThumbnail;

  PhotoGroup({
    required this.id,
    required this.name,
    required this.type,
    List<PhotoItem>? photos,
    this.coverThumbnail,
  }) : photos = photos ?? [];

  int get photoCount => photos.length;

  void addPhoto(PhotoItem photo) {
    if (!photos.contains(photo)) {
      photos.add(photo);
    }
  }

  Future<Uint8List?> getCoverThumbnail() async {
    if (coverThumbnail != null) return coverThumbnail;
    if (photos.isNotEmpty) {
      coverThumbnail = await photos.first.thumbnail;
    }
    return coverThumbnail;
  }
}
