import 'package:flutter/foundation.dart';
import 'package:qoshni/features/search/domain/qoshni_search_location.dart';

/// Shared map focus for list/map parity (single explicit focus point).
class QoshniSearchMapFocusController extends ChangeNotifier {
  String? title;
  QoshniSearchLocation? location;

  bool get hasFocus => location != null;

  void focusOn({
    required String resultTitle,
    required QoshniSearchLocation searchLocation,
  }) {
    title = resultTitle;
    location = searchLocation;
    notifyListeners();
  }

  void clear() {
    title = null;
    location = null;
    notifyListeners();
  }
}
