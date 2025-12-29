import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_node_auth/models/park.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/services/map_services.dart';

class ParksProvider extends ChangeNotifier {
  List<Park> _parks = [];
  Park _activePark = Park();

  List<Park> get parks => _parks;
  Park get activePark => _activePark;

  void setParks(List<Park> parks) {
    _parks = parks;
    notifyListeners();
  }

  List<Polygon<Object>> getParksAsPolygons() {
    return parks.expand((park) {
      return polygonsFromWktMultiPolygon(
        park,
        fillColor: Colors.blue.withOpacity(0.20),
        borderColor: Colors.blueAccent,
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
