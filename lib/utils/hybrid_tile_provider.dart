import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;

/// Custom tile provider that uses local assets for zoom <= 15
/// and OpenStreetMap network tiles for zoom > 15
class HybridTileProvider extends TileProvider {
  final int maxLocalZoom;
  final AssetTileProvider assetProvider;

  HybridTileProvider({this.maxLocalZoom = 15})
      : assetProvider = AssetTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final zoom = coordinates.z.toInt();

    // Use local assets for zoom levels <= maxLocalZoom
    if (zoom <= maxLocalZoom) {
      // Use asset tiles
      final assetPath = 'assets/tiles/$zoom/${coordinates.x}/${coordinates.y}.png';
      return AssetImage(assetPath);
    } else {
      // Use OpenStreetMap network tiles for higher zoom levels
      final url = 'https://tile.openstreetmap.org/$zoom/${coordinates.x}/${coordinates.y}.png';
      return NetworkImage(url);
    }
  }
}
