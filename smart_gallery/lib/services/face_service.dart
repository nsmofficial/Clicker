import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/photo_item.dart';
import '../models/face_data.dart';
import '../models/photo_group.dart';
import '../utils/face_clustering.dart';

class FaceService {
  static final FaceService _instance = FaceService._internal();
  factory FaceService() => _instance;
  FaceService._internal();

  late final FaceDetector _faceDetector;
  bool _isInitialized = false;

  final List<FaceData> _allFaceData = [];
  final List<PhotoGroup> _personGroups = [];

  List<PhotoGroup> get personGroups => _personGroups;

  void initialize() {
    if (_isInitialized) return;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: true,
        enableTracking: false,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.1,
      ),
    );
    _isInitialized = true;
  }

  /// Process photos to detect faces and extract features.
  Future<void> processPhotos(
    List<PhotoItem> photos, {
    Function(int processed, int total)? onProgress,
  }) async {
    initialize();
    _allFaceData.clear();

    for (int i = 0; i < photos.length; i++) {
      try {
        final file = await photos[i].file;
        if (file == null) continue;

        final faces = await _detectFaces(file);

        for (final face in faces) {
          final featureVector = _extractFeatureVector(face, file);
          if (featureVector != null) {
            _allFaceData.add(FaceData(
              photoId: photos[i].id,
              featureVector: featureVector,
              boundingBox: [
                face.boundingBox.left,
                face.boundingBox.top,
                face.boundingBox.width,
                face.boundingBox.height,
              ],
            ));
          }
        }
      } catch (e) {
        // Skip photos that fail processing
        continue;
      }

      onProgress?.call(i + 1, photos.length);
    }

    // Cluster faces into person groups
    _clusterFaces(photos);
  }

  /// Detect faces in an image file.
  Future<List<Face>> _detectFaces(File file) async {
    final inputImage = InputImage.fromFile(file);
    return await _faceDetector.processImage(inputImage);
  }

  /// Extract a feature vector from face landmarks and contours.
  /// This creates a geometric feature vector from relative landmark positions.
  List<double>? _extractFeatureVector(Face face, File file) {
    final List<double> features = [];

    // Use face bounding box ratios
    final bbox = face.boundingBox;
    final aspectRatio = bbox.width / (bbox.height == 0 ? 1 : bbox.height);
    features.add(aspectRatio);

    // Extract landmark-based features (normalized by face bounding box)
    final landmarkTypes = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
      FaceLandmarkType.bottomMouth,
      FaceLandmarkType.leftEar,
      FaceLandmarkType.rightEar,
      FaceLandmarkType.leftCheek,
      FaceLandmarkType.rightCheek,
    ];

    for (final type in landmarkTypes) {
      final landmark = face.landmarks[type];
      if (landmark != null) {
        // Normalize position relative to bounding box
        final normX =
            (landmark.position.x - bbox.left) / (bbox.width == 0 ? 1 : bbox.width);
        final normY =
            (landmark.position.y - bbox.top) / (bbox.height == 0 ? 1 : bbox.height);
        features.add(normX);
        features.add(normY);
      } else {
        features.add(0.0);
        features.add(0.0);
      }
    }

    // Add contour-based features for more accuracy
    final contourTypes = [
      FaceContourType.face,
      FaceContourType.leftEye,
      FaceContourType.rightEye,
      FaceContourType.noseBridge,
      FaceContourType.noseBottom,
      FaceContourType.upperLipTop,
      FaceContourType.upperLipBottom,
      FaceContourType.lowerLipTop,
      FaceContourType.lowerLipBottom,
    ];

    for (final type in contourTypes) {
      final contour = face.contours[type];
      if (contour != null && contour.points.isNotEmpty) {
        // Use statistical measures of contour points
        double sumX = 0, sumY = 0;
        double minX = double.infinity, maxX = -double.infinity;
        double minY = double.infinity, maxY = -double.infinity;

        for (final point in contour.points) {
          final normX =
              (point.x - bbox.left) / (bbox.width == 0 ? 1 : bbox.width);
          final normY =
              (point.y - bbox.top) / (bbox.height == 0 ? 1 : bbox.height);
          sumX += normX;
          sumY += normY;
          if (normX < minX) minX = normX;
          if (normX > maxX) maxX = normX;
          if (normY < minY) minY = normY;
          if (normY > maxY) maxY = normY;
        }

        final avgX = sumX / contour.points.length;
        final avgY = sumY / contour.points.length;
        features.addAll([avgX, avgY, maxX - minX, maxY - minY]);
      } else {
        features.addAll([0.0, 0.0, 0.0, 0.0]);
      }
    }

    // Note: We intentionally exclude volatile features like smile probability,
    // eye openness, and head angles as they change per photo and hurt
    // same-person matching accuracy. Only geometric/structural features are used.

    if (features.length < 5) return null; // Not enough data

    return features;
  }

  /// Cluster detected faces into person groups.
  void _clusterFaces(List<PhotoItem> allPhotos) {
    _personGroups.clear();

    if (_allFaceData.isEmpty) return;

    // Run clustering with threshold tuned for geometric features only
    final clustering = FaceClustering(
      threshold: 0.25, // Tighter threshold for better precision with structural features
    );
    final clusters = clustering.cluster(_allFaceData);

    // Create photo groups from clusters
    final photoMap = {for (final p in allPhotos) p.id: p};

    int personIndex = 1;
    for (final cluster in clusters) {
      if (cluster.isEmpty) continue;

      final group = PhotoGroup(
        id: 'person_$personIndex',
        name: 'Person $personIndex',
        type: GroupType.person,
      );

      // Add unique photos to this person's group
      final addedPhotoIds = <String>{};
      for (final faceData in cluster) {
        if (!addedPhotoIds.contains(faceData.photoId)) {
          final photo = photoMap[faceData.photoId];
          if (photo != null) {
            group.addPhoto(photo);
            addedPhotoIds.add(faceData.photoId);
          }
        }
      }

      if (group.photos.isNotEmpty) {
        _personGroups.add(group);
        personIndex++;
      }
    }

    // Sort groups by number of photos (most photos first)
    _personGroups.sort((a, b) => b.photoCount.compareTo(a.photoCount));
  }

  void dispose() {
    if (_isInitialized) {
      _faceDetector.close();
    }
  }
}
