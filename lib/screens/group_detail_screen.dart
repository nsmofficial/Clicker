import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/photo_group.dart';
import '../models/photo_item.dart';
import 'image_viewer_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final PhotoGroup group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${group.photoCount} photos',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: group.photos.isEmpty
          ? const Center(child: Text('No photos in this group'))
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: group.photos.length,
              itemBuilder: (context, index) {
                return _PhotoThumbnail(
                  photo: group.photos[index],
                  onTap: () => _openViewer(context, index),
                );
              },
            ),
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
          photos: group.photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  final PhotoItem photo;
  final VoidCallback onTap;

  const _PhotoThumbnail({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FutureBuilder<Uint8List?>(
        future: photo.thumbnail,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Hero(
              tag: 'photo_${photo.id}',
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            );
          }
          return Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
