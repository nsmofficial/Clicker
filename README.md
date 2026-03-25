# Smart Gallery

AI-powered photo gallery app that automatically groups your photos by **people** (face detection & clustering) and **categories** (scenery, food, traditional, animals, etc.) — all processed on-device, completely free.

## Features

- **Photo Scanning** — Scans all images on your device using `photo_manager`
- **Face Grouping** — Detects faces using Google ML Kit Face Detection, extracts geometric features from landmarks/contours, and clusters similar faces together
- **Category Grouping** — Classifies images using Google ML Kit Image Labeling into categories: Scenery, Food, Traditional & Cultural, Animals, Vehicles, Sports, Art, Buildings, and more
- **Image Viewer** — Full-screen pinch-to-zoom viewer with swipe navigation
- **Reveal in Gallery** — Opens the selected photo in your device's native gallery app
- **Material 3 UI** — Clean, modern interface with dark mode support

## Tech Stack (All Free & Open Source)

| Library | Purpose |
|---------|---------|
| `photo_manager` | Access device photos |
| `google_mlkit_face_detection` | On-device face detection with landmarks & contours |
| `google_mlkit_image_labeling` | On-device image classification |
| `provider` | State management |
| `open_filex` | Open files in external apps |
| `permission_handler` | Runtime permission handling |

## Setup Instructions

### Prerequisites
- Flutter SDK 3.16+ installed
- Android Studio or Xcode
- A physical device (ML Kit works best on real devices)

### Steps

1. **Create a new Flutter project** (if you haven't already):
   ```bash
   flutter create smart_gallery
   ```

2. **Replace the generated files** with the files from this project:
   - Copy `lib/` folder entirely
   - Copy `pubspec.yaml`
   - Merge Android manifest permissions into your `android/app/src/main/AndroidManifest.xml`
   - Merge iOS permissions into your `ios/Runner/Info.plist`
   - Copy `android/app/src/main/kotlin/.../MainActivity.kt`
   - Copy `android/app/src/main/res/xml/file_paths.xml`
   - Update `ios/Podfile` with the minimum iOS version (15.5)

3. **Install dependencies:**
   ```bash
   cd smart_gallery
   flutter pub get
   ```

4. **Android specific:**
   - Ensure `minSdk` is at least `21` in `android/app/build.gradle`
   - Ensure `compileSdk` is at least `34`

5. **iOS specific:**
   ```bash
   cd ios && pod install && cd ..
   ```

6. **Run the app:**
   ```bash
   flutter run
   ```

## How It Works

### Face Grouping Pipeline
1. Each photo is processed through ML Kit Face Detection (accurate mode)
2. Facial landmarks (eyes, nose, mouth, ears, cheeks) and contours are extracted
3. Positions are normalized relative to the face bounding box to create a feature vector
4. Agglomerative clustering groups faces with similar geometric features
5. Photos are grouped by detected person

### Image Classification Pipeline
1. Each photo is processed through ML Kit Image Labeling
2. Returned labels are matched against a keyword dictionary for each category
3. Photos can appear in multiple categories if multiple labels match
4. Categories include: Scenery, Food, Traditional & Cultural, Animals, Vehicles & Transport, Sports & Fitness, Selfies & Portraits, Documents & Screenshots, Art & Design, Buildings & Architecture

### Reveal in Gallery
- On Android: Uses a platform channel with `FileProvider` to create a content URI and launches an `ACTION_VIEW` intent
- Falls back to `open_filex` for cross-platform compatibility

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   ├── photo_item.dart                # Photo data model
│   ├── photo_group.dart               # Group data model
│   └── face_data.dart                 # Face feature data model
├── services/
│   ├── photo_service.dart             # Device photo scanning
│   ├── face_service.dart              # Face detection & grouping
│   ├── classification_service.dart    # Image categorization
│   └── gallery_service.dart           # Native gallery opener
├── providers/
│   └── gallery_provider.dart          # App state management
├── screens/
│   ├── home_screen.dart               # Main screen with tabs
│   ├── group_detail_screen.dart       # Photo grid for a group
│   └── image_viewer_screen.dart       # Full-screen viewer
├── widgets/
│   ├── group_grid_tile.dart           # Group card widget
│   └── scanning_view.dart             # Scanning progress UI
└── utils/
    ├── category_mapper.dart           # Label-to-category mapping
    └── face_clustering.dart           # Agglomerative clustering
```

## Performance Notes

- The app processes up to **500 photos** by default to keep scanning time reasonable
- You can adjust this limit in `gallery_provider.dart` → `startScanning(photoLimit:)`
- ML Kit runs entirely on-device — no internet required, no data leaves your phone
- Thumbnail caching improves scrolling performance

## License

This project uses only free, open-source libraries. No API keys or paid services required.
