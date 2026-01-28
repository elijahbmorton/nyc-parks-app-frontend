import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nyc_parks/models/park.dart';
import 'package:nyc_parks/services/map_services.dart';
import 'package:nyc_parks/styles/colors.dart';
import 'package:nyc_parks/utils/constants.dart';

class ParksProvider extends ChangeNotifier {
  List<Park> _parks = [];
  Park _activePark = Park();
  LatLng? _pendingMapZoom;

  List<Park> get parks => _parks;
  Park get activePark => _activePark;
  LatLng? get pendingMapZoom => _pendingMapZoom;

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
      double fillOpacity = 0.2;
      double borderWidth = 1.5;

      // Pink for favorites (takes priority)
      if (favoriteParkIds.contains(park.GlobalID)) {
        color = AppColors.favorite;
        fillOpacity = 0.35;
        borderWidth = 2.0;
      }
      // Bright blue for reviewed/visited
      else if (highlightedParkIds.contains(park.GlobalID)) {
        color = AppColors.visitedPark;
        fillOpacity = 0.4; // Higher opacity for better visibility
        borderWidth = 2.0; // Thicker border
      }

      return polygonsFromWktMultiPolygon(
        park,
        fillColor: color.withValues(alpha: fillOpacity),
        borderColor: color,
        borderStrokeWidth: borderWidth,
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

  void setPendingMapZoom(LatLng? location) {
    _pendingMapZoom = location;
    notifyListeners();
  }

  void clearPendingMapZoom() {
    _pendingMapZoom = null;
    notifyListeners();
  }
}
