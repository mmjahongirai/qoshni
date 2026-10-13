import 'package:flutter/foundation.dart';
import 'package:qoshni/features/home/presentation/data/mock_business_id.dart';

/// In-memory saved businesses for the MVP (not persisted across restarts).
class FavoritesController extends ChangeNotifier {
  final List<MockBusinessId> _favoriteIds = [];

  List<MockBusinessId> get favoriteIds => List<MockBusinessId>.unmodifiable(_favoriteIds);

  bool isFavorite(MockBusinessId id) => _favoriteIds.contains(id);

  void toggleFavorite(MockBusinessId id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  void removeFavorite(MockBusinessId id) {
    if (_favoriteIds.remove(id)) {
      notifyListeners();
    }
  }
}
