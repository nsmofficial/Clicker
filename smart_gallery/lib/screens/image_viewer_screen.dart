import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../models/photo_item.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<PhotoItem> photos;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image PageView
          GestureDetector(
            onTap: () {
              setState(() => _showControls = !_showControls);
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return _FullScreenImage(photo: widget.photos[index]);
              },
            ),
          ),

          // Top bar with back button and info
          if (_showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          '${_currentIndex + 1} / ${widget.photos.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the row
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Bottom bar with Reveal in Gallery button
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Photo date
                        Text(
                          _formatDate(widget.photos[_currentIndex].createDate),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Reveal in Gallery button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _revealInGallery(context),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text(
                              'Reveal in Gallery',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _revealInGallery(BuildContext context) async {
    final photo = widget.photos[_currentIndex];
    try {
      final file = await photo.file;
      if (file == null) {
        if (context.mounted) {
          _showSnackbar(context, 'Could not access the photo file');
        }
        return;
      }

      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done && context.mounted) {
        // Try alternative: content URI approach
        final uri = await photo.asset.getMediaUrl();
        if (uri != null) {
          await OpenFilex.open(uri);
        } else {
          _showSnackbar(context, 'Could not open in gallery app');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, 'Error opening gallery: ${e.toString()}');
      }
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final PhotoItem photo;

  const _FullScreenImage({required this.photo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: photo.file,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Hero(
            tag: 'photo_${photo.id}',
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(
                  snapshot.data!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
    );
  }
}
