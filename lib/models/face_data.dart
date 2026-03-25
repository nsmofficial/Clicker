import 'dart:math';

/// Stores extracted face feature data for clustering.
class FaceData {
  final String photoId;
  final List<double> featureVector;
  final List<double> boundingBox; // [left, top, width, height] normalized
  int? clusterId;

  FaceData({
    required this.photoId,
    required this.featureVector,
    required this.boundingBox,
    this.clusterId,
  });

  /// Compute euclidean distance between two face feature vectors.
  double distanceTo(FaceData other) {
    if (featureVector.length != other.featureVector.length) {
      return double.infinity;
    }
    double sum = 0;
    for (int i = 0; i < featureVector.length; i++) {
      final diff = featureVector[i] - other.featureVector[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }

  /// Compute cosine similarity between two face feature vectors.
  double cosineSimilarity(FaceData other) {
    if (featureVector.length != other.featureVector.length) return 0;

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < featureVector.length; i++) {
      dotProduct += featureVector[i] * other.featureVector[i];
      normA += featureVector[i] * featureVector[i];
      normB += other.featureVector[i] * other.featureVector[i];
    }

    if (normA == 0 || normB == 0) return 0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
