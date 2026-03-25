import 'package:flutter/foundation.dart';
import '../models/photo_item.dart';
import '../models/photo_group.dart';
import '../services/photo_service.dart';
import '../services/face_service.dart';
import '../services/classification_service.dart';

enum ScanStatus { idle, requestingPermission, scanning, detectingFaces, classifying, done, error }

class GalleryProvider extends ChangeNotifier {
  final PhotoService _photoService = PhotoService();
  final FaceService _faceService = FaceService();
  final ClassificationService _classificationService = ClassificationService();

  ScanStatus _status = ScanStatus.idle;
  String _statusMessage = 'Tap to start scanning';
  double _progress = 0.0;
  String? _errorMessage;

  // Getters
  ScanStatus get status => _status;
  String get statusMessage => _statusMessage;
  double get progress => _progress;
  String? get errorMessage => _errorMessage;
  List<PhotoItem> get allPhotos => _photoService.allPhotos;
  List<PhotoGroup> get personGroups => _faceService.personGroups;
  List<PhotoGroup> get categoryGroups => _classificationService.categoryGroups;
  bool get isScanning => _status != ScanStatus.idle && _status != ScanStatus.done && _status != ScanStatus.error;
  bool get isDone => _status == ScanStatus.done;

  /// Start the full scanning pipeline.
  Future<void> startScanning({int? photoLimit}) async {
    try {
      // Step 1: Request permission and load photos
      _status = ScanStatus.requestingPermission;
      _statusMessage = 'Requesting photo access...';
      _progress = 0.0;
      notifyListeners();

      final hasPermission = await _photoService.requestPermissionAndLoad(
        onProgress: (loaded, total) {
          _status = ScanStatus.scanning;
          _statusMessage = 'Loading photos... $loaded / $total';
          _progress = total > 0 ? loaded / total * 0.3 : 0;
          notifyListeners();
        },
      );

      if (!hasPermission) {
        _status = ScanStatus.error;
        _errorMessage = 'Photo access denied. Please grant permission in Settings.';
        _statusMessage = 'Permission denied';
        notifyListeners();
        return;
      }

      if (_photoService.allPhotos.isEmpty) {
        _status = ScanStatus.done;
        _statusMessage = 'No photos found on device';
        _progress = 1.0;
        notifyListeners();
        return;
      }

      final photosToProcess = _photoService.getPhotosForProcessing(
        limit: photoLimit, // Process all photos if no limit specified
      );

      // Step 2: Detect faces
      _status = ScanStatus.detectingFaces;
      _statusMessage = 'Detecting faces...';
      _progress = 0.3;
      notifyListeners();

      await _faceService.processPhotos(
        photosToProcess,
        onProgress: (processed, total) {
          _statusMessage = 'Detecting faces... $processed / $total';
          _progress = 0.3 + (processed / total * 0.35);
          notifyListeners();
        },
      );

      // Step 3: Classify images
      _status = ScanStatus.classifying;
      _statusMessage = 'Classifying images...';
      _progress = 0.65;
      notifyListeners();

      await _classificationService.processPhotos(
        photosToProcess,
        onProgress: (processed, total) {
          _statusMessage = 'Classifying... $processed / $total';
          _progress = 0.65 + (processed / total * 0.35);
          notifyListeners();
        },
      );

      // Done
      _status = ScanStatus.done;
      _statusMessage = 'Scan complete!';
      _progress = 1.0;
      notifyListeners();
    } catch (e) {
      _status = ScanStatus.error;
      _errorMessage = e.toString();
      _statusMessage = 'Error occurred';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _faceService.dispose();
    _classificationService.dispose();
    super.dispose();
  }
}
