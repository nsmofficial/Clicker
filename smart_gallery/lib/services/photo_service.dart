import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/photo_item.dart';

class PhotoService {
  static final PhotoService _instance = PhotoService._internal();
  factory PhotoService() => _instance;
  PhotoService._internal();

  final List<PhotoItem> _allPhotos = [];
  bool _isLoaded = false;

  List<PhotoItem> get allPhotos => _allPhotos;
  bool get isLoaded => _isLoaded;

  /// Request permissions and load all photos from device.
  Future<bool> requestPermissionAndLoad({
    Function(int loaded, int total)? onProgress,
  }) async {
    // Request photo permission
    final PermissionState permission =
        await PhotoManager.requestPermissionExtend();

    if (!permission.isAuth) {
      // Try requesting through permission_handler as fallback
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        // On Android 13+, try media images permission
        final mediaStatus = await Permission.mediaLibrary.request();
        if (!mediaStatus.isGranted) {
          return false;
        }
      }
    }

    await _loadAllPhotos(onProgress: onProgress);
    return true;
  }

  /// Load all image assets from the device.
  Future<void> _loadAllPhotos({
    Function(int loaded, int total)? onProgress,
  }) async {
    _allPhotos.length = 0; // Clear the list

    // Get all image albums
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(
            minWidth: 100,
            minHeight: 100,
          ),
        ),
        orders: [
          const OrderOption(
            type: OrderOptionType.createDate,
            asc: false,
          ),
        ],
      ),
    );

    if (albums.isEmpty) {
      _isLoaded = true;
      return;
    }

    // Find "Recent" or "All Photos" album which contains everything
    AssetPathEntity? allPhotosAlbum;
    for (final album in albums) {
      if (album.isAll) {
        allPhotosAlbum = album;
        break;
      }
    }

    allPhotosAlbum ??= albums.first;

    final int totalCount = await allPhotosAlbum.assetCountAsync;
    if (totalCount == 0) {
      _isLoaded = true;
      return;
    }

    // Load in batches for better performance
    const int pageSize = 100;
    int currentPage = 0;
    int loaded = 0;

    while (loaded < totalCount) {
      final List<AssetEntity> assets = await allPhotosAlbum.getAssetListPaged(
        page: currentPage,
        size: pageSize,
      );

      if (assets.isEmpty) break;

      for (final asset in assets) {
        _allPhotos.add(PhotoItem(asset: asset));
      }

      loaded += assets.length;
      currentPage++;

      onProgress?.call(loaded, totalCount);
    }

    _isLoaded = true;
  }

  /// Get a subset of photos for processing (to avoid overwhelming ML processing).
  List<PhotoItem> getPhotosForProcessing({int? limit}) {
    if (limit == null || limit >= _allPhotos.length) {
      return List.from(_allPhotos);
    }
    return _allPhotos.sublist(0, limit);
  }
}
