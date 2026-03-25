import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/photo_item.dart';
import '../models/photo_group.dart';
import '../utils/category_mapper.dart';

class ClassificationService {
  static final ClassificationService _instance =
      ClassificationService._internal();
  factory ClassificationService() => _instance;
  ClassificationService._internal();

  late final ImageLabeler _imageLabeler;
  bool _isInitialized = false;

  final List<PhotoGroup> _categoryGroups = [];

  List<PhotoGroup> get categoryGroups => _categoryGroups;

  void initialize() {
    if (_isInitialized) return;

    _imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
    _isInitialized = true;
  }

  /// Process photos and classify them into categories.
  Future<void> processPhotos(
    List<PhotoItem> photos, {
    Function(int processed, int total)? onProgress,
  }) async {
    initialize();

    // Map: category name -> list of PhotoItems
    final Map<String, List<PhotoItem>> categoryMap = {};

    for (int i = 0; i < photos.length; i++) {
      try {
        final file = await photos[i].file;
        if (file == null) continue;

        final labels = await _classifyImage(file);
        final categories = CategoryMapper.mapLabelsToCategories(labels);

        for (final category in categories) {
          categoryMap.putIfAbsent(category, () => []);
          categoryMap[category]!.add(photos[i]);
        }

        // If no category was matched, put in "Other"
        if (categories.isEmpty) {
          categoryMap.putIfAbsent('Other', () => []);
          categoryMap['Other']!.add(photos[i]);
        }
      } catch (e) {
        // Skip photos that fail
        continue;
      }

      onProgress?.call(i + 1, photos.length);
    }

    // Convert to PhotoGroups
    _categoryGroups.clear();
    int index = 1;
    for (final entry in categoryMap.entries) {
      if (entry.value.isEmpty) continue;

      _categoryGroups.add(PhotoGroup(
        id: 'category_$index',
        name: entry.key,
        type: GroupType.category,
        photos: entry.value,
      ));
      index++;
    }

    // Sort by photo count descending
    _categoryGroups.sort((a, b) => b.photoCount.compareTo(a.photoCount));
  }

  /// Classify an image using ML Kit Image Labeling.
  Future<List<ImageLabel>> _classifyImage(File file) async {
    final inputImage = InputImage.fromFile(file);
    return await _imageLabeler.processImage(inputImage);
  }

  void dispose() {
    if (_isInitialized) {
      _imageLabeler.close();
    }
  }
}
