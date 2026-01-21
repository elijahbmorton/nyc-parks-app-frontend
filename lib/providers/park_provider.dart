import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:nyc_parks/models/park.dart';
import 'package:nyc_parks/services/map_services.dart';
import 'package:nyc_parks/styles/colors.dart';
import 'package:nyc_parks/utils/constants.dart';

class ParksProvider extends ChangeNotifier {
  List<Park> _parks = [];
  Park _activePark = Park();

  List<Park> get parks => _parks;
  Park get activePark => _activePark;

  void setParks(List<Park> parks) {
    _parks = parks;
    notifyListeners();
  }

  List<Polygon<Object>> getParksAsPolygons({
    List<String> highlightedParkIds = const [],
    List<String> favoriteParkIds = const [],
  }) {
    return parks.expand((park) {
      Color color = AppColors.primary;
      
      // Pink for favorites (takes priority)
      if (favoriteParkIds.contains(park.GlobalID)) {
        color = AppColors.favorite;
      }
      // Blue for reviewed/highlighted
      else if (highlightedParkIds.contains(park.GlobalID)) {
        color = AppColors.accent;
      }
      
      return polygonsFromWktMultiPolygon(
        park,
        fillColor: color.withValues(alpha: 0.2),
        borderColor: color,
        borderStrokeWidth: 1.5,
      );
    }).toList();
  }

  Park parkFromGlobalId(String id) {
    // TODO: make parks a map for O(1)
    for (final park in parks) {
      if (park.GlobalID == id) {
        return park;
      }
    }
    return Park();
  }

  void setActivePark(Park activePark) {
    _activePark = activePark;
    notifyListeners();
  }

  void setActiveParkFromGlobalId(String id) {
    setActivePark(parkFromGlobalId(id));
  }
}
