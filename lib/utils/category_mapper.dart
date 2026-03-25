import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// Maps ML Kit image labels to user-friendly categories.
class CategoryMapper {
  // Category definitions with associated keywords
  static const Map<String, List<String>> _categoryKeywords = {
    'Scenery': [
      'sky', 'cloud', 'mountain', 'landscape', 'sunset', 'sunrise',
      'ocean', 'sea', 'beach', 'lake', 'river', 'waterfall', 'forest',
      'tree', 'nature', 'horizon', 'hill', 'valley', 'field', 'meadow',
      'snow', 'ice', 'desert', 'cliff', 'rock', 'island', 'coast',
      'garden', 'park', 'outdoor', 'scenery', 'view', 'panorama',
      'natural landscape', 'body of water', 'geological phenomenon',
    ],
    'Food': [
      'food', 'dish', 'meal', 'cuisine', 'fruit', 'vegetable',
      'meat', 'bread', 'cake', 'dessert', 'pizza', 'burger', 'salad',
      'rice', 'pasta', 'sushi', 'coffee', 'tea', 'drink', 'beverage',
      'cooking', 'kitchen', 'restaurant', 'breakfast', 'lunch', 'dinner',
      'snack', 'chocolate', 'ice cream', 'egg', 'cheese', 'soup',
      'baked goods', 'fast food', 'recipe', 'ingredient', 'tableware',
      'produce', 'natural foods', 'junk food', 'comfort food',
    ],
    'Traditional & Cultural': [
      'temple', 'church', 'mosque', 'tradition', 'festival', 'ceremony',
      'ritual', 'cultural', 'heritage', 'monument', 'statue', 'shrine',
      'architecture', 'historical', 'ancient', 'costume', 'dance',
      'celebration', 'wedding', 'prayer', 'religious', 'ethnic',
      'folk', 'tribal', 'artisan', 'craft', 'textile', 'ornament',
      'place of worship', 'pagoda', 'palace', 'castle', 'fort',
    ],
    'Animals': [
      'animal', 'dog', 'cat', 'bird', 'fish', 'horse', 'cow',
      'sheep', 'goat', 'chicken', 'duck', 'rabbit', 'deer', 'bear',
      'lion', 'tiger', 'elephant', 'monkey', 'snake', 'turtle',
      'butterfly', 'insect', 'pet', 'wildlife', 'zoo', 'aquarium',
      'mammal', 'reptile', 'amphibian', 'invertebrate', 'vertebrate',
      'organism', 'fauna', 'canine', 'feline', 'primate',
    ],
    'Vehicles & Transport': [
      'car', 'vehicle', 'automobile', 'truck', 'bus', 'motorcycle',
      'bicycle', 'train', 'airplane', 'boat', 'ship', 'helicopter',
      'road', 'highway', 'traffic', 'transport', 'driving', 'parking',
      'wheel', 'tire', 'engine', 'motor vehicle', 'land vehicle',
      'watercraft', 'aircraft',
    ],
    'Sports & Fitness': [
      'sport', 'ball', 'football', 'soccer', 'basketball', 'tennis',
      'cricket', 'baseball', 'golf', 'swimming', 'running', 'cycling',
      'gym', 'fitness', 'exercise', 'yoga', 'hiking', 'climbing',
      'skiing', 'surfing', 'stadium', 'field', 'court', 'athlete',
      'player', 'team sport', 'ball game', 'sports equipment',
    ],
    'Selfies & Portraits': [
      'selfie', 'portrait', 'face', 'smile', 'person', 'people',
      'human', 'man', 'woman', 'child', 'baby', 'family', 'group',
      'crowd', 'social group', 'fun', 'happy', 'facial expression',
    ],
    'Documents & Screenshots': [
      'text', 'document', 'paper', 'book', 'newspaper', 'magazine',
      'screenshot', 'screen', 'display', 'font', 'writing', 'letter',
      'number', 'sign', 'label', 'receipt', 'ticket', 'card',
      'publication', 'media', 'parallel', 'rectangle', 'software',
    ],
    'Art & Design': [
      'art', 'painting', 'drawing', 'illustration', 'design', 'pattern',
      'color', 'abstract', 'creative', 'graphic', 'sketch', 'mural',
      'graffiti', 'sculpture', 'pottery', 'mosaic', 'calligraphy',
      'visual arts', 'modern art', 'fine art',
    ],
    'Buildings & Architecture': [
      'building', 'house', 'home', 'apartment', 'office', 'tower',
      'bridge', 'city', 'urban', 'street', 'skyline', 'skyscraper',
      'window', 'door', 'roof', 'wall', 'floor', 'room', 'interior',
      'exterior', 'construction', 'real estate', 'property',
      'commercial building', 'residential area', 'neighbourhood',
      'metropolitan area', 'condominium', 'facade',
    ],
  };

  /// Map ML Kit labels to our predefined categories.
  static Set<String> mapLabelsToCategories(List<ImageLabel> labels) {
    final Set<String> matchedCategories = {};

    for (final label in labels) {
      final labelText = label.label.toLowerCase();

      for (final entry in _categoryKeywords.entries) {
        for (final keyword in entry.value) {
          if (labelText.contains(keyword) || keyword.contains(labelText)) {
            matchedCategories.add(entry.key);
            break;
          }
        }
      }
    }

    return matchedCategories;
  }

  /// Get icon for a category.
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'Scenery':
        return '🏔️';
      case 'Food':
        return '🍽️';
      case 'Traditional & Cultural':
        return '🏛️';
      case 'Animals':
        return '🐾';
      case 'Vehicles & Transport':
        return '🚗';
      case 'Sports & Fitness':
        return '⚽';
      case 'Selfies & Portraits':
        return '🤳';
      case 'Documents & Screenshots':
        return '📄';
      case 'Art & Design':
        return '🎨';
      case 'Buildings & Architecture':
        return '🏢';
      default:
        return '📁';
    }
  }
}
