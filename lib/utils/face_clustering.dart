import '../models/face_data.dart';

/// Simple agglomerative clustering for face grouping.
/// Groups faces based on feature vector similarity.
class FaceClustering {
  final double threshold;

  FaceClustering({this.threshold = 0.35});

  /// Cluster face data into groups of similar faces (same person).
  /// Returns a list of clusters, each cluster is a list of FaceData.
  List<List<FaceData>> cluster(List<FaceData> faces) {
    if (faces.isEmpty) return [];
    if (faces.length == 1) return [faces];

    // Initialize: each face is its own cluster
    List<List<FaceData>> clusters = faces.map((f) => [f]).toList();

    bool merged = true;

    while (merged) {
      merged = false;
      double minDist = double.infinity;
      int mergeI = -1;
      int mergeJ = -1;

      // Find the two closest clusters
      for (int i = 0; i < clusters.length; i++) {
        for (int j = i + 1; j < clusters.length; j++) {
          final dist = _averageLinkageDistance(clusters[i], clusters[j]);
          if (dist < minDist) {
            minDist = dist;
            mergeI = i;
            mergeJ = j;
          }
        }
      }

      // Merge if below threshold
      if (minDist < threshold && mergeI >= 0 && mergeJ >= 0) {
        clusters[mergeI].addAll(clusters[mergeJ]);
        clusters.removeAt(mergeJ);
        merged = true;
      }
    }

    // Filter out singleton clusters with low confidence
    // (faces that appear only once might be false positives)
    return clusters.where((c) => c.length >= 1).toList();
  }

  /// Average linkage: average distance between all pairs across two clusters.
  double _averageLinkageDistance(List<FaceData> a, List<FaceData> b) {
    if (a.isEmpty || b.isEmpty) return double.infinity;

    double totalDist = 0;
    int count = 0;

    for (final faceA in a) {
      for (final faceB in b) {
        // Use 1 - cosine_similarity as distance
        final similarity = faceA.cosineSimilarity(faceB);
        totalDist += (1.0 - similarity);
        count++;
      }
    }

    return count > 0 ? totalDist / count : double.infinity;
  }
}
