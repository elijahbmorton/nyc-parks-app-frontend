
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter_node_auth/models/park.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapService {
  Future<List<Park>> loadParks() async {
    // Load CSV from assets
    final csvString = await rootBundle.loadString('assets/Parks_Properties_20251226.csv');

    final rows = const CsvToListConverter(
      fieldDelimiter: ',',
      textDelimiter: '"',
      eol: '\n',
    ).convert(csvString);

    // TODO: Make this use all the fields
    List<Park> parks = [];
    for (final row in rows) {
      Park park = await Park.fromCSV(row);
      parks.add(park);
    }
    parks.removeAt(0);
    return parks;
  }
}

/// Parses a WKT MULTIPOLYGON string (lon lat order) into flutter_map Polygons.
///
/// Example input:
/// MULTIPOLYGON (((-73.9 40.7, -73.8 40.7, ...)), ((...)), ...)
///
/// Notes:
/// - WKT uses (x y) = (lon lat). This converts to LatLng(lat, lon).
/// - Rings are auto-closed if not already closed.
/// - Holes (inner rings) are added via `holePointsList` when present.
List<Polygon> polygonsFromWktMultiPolygon(
  Park park, {
  Color? fillColor,
  Color? borderColor,
  double borderStrokeWidth = 1.0,
  bool isFilled = true,
}) {
  var wkt = park.multipolygon;
  if (wkt == null) return <Polygon>[];
  var s = wkt.trim();
  if (s.isEmpty) return <Polygon>[];

  // Handle optional SRID prefix: "SRID=4326;MULTIPOLYGON ..."
  final sridIdx = s.indexOf(';');
  if (sridIdx != -1 && s.substring(0, sridIdx).toUpperCase().startsWith('SRID=')) {
    s = s.substring(sridIdx + 1).trim();
  }

  final upper = s.toUpperCase();
  if (!upper.startsWith('MULTIPOLYGON')) return <Polygon>[];

  final firstParen = s.indexOf('(');
  if (firstParen == -1) return <Polygon>[];

  final body = s.substring(firstParen); // starts with '('
  final polygonChunks = _extractParenGroupsAtDepth(body, targetDepth: 2);
  // Each chunk is the inside of ((...)) for one polygon: "(ring),(hole),..."

  final result = <Polygon>[];

  for (final polyChunk in polygonChunks) {
    final ringChunks = _extractParenGroupsAtDepth(polyChunk, targetDepth: 1);
    if (ringChunks.isEmpty) continue;

    final rings = <List<LatLng>>[];
    for (final ringChunk in ringChunks) {
      final pts = _parseLonLatRing(ringChunk);
      if (pts.length >= 3) {
        rings.add(_ensureClosed(pts));
      }
    }
    if (rings.isEmpty) continue;

    final outer = rings.first;
    final holes = rings.length > 1 ? rings.sublist(1) : <List<LatLng>>[];

    result.add(
      Polygon(
        points: outer,
        // If your flutter_map version doesn't have this parameter,
        // remove it and you can ignore holes or handle them differently.
        holePointsList: holes.isEmpty ? null : holes,
        color: isFilled ? (fillColor ?? Colors.green.withOpacity(0.25)) : Colors.transparent,
        borderColor: borderColor ?? Colors.green,
        borderStrokeWidth: borderStrokeWidth,
        //label: park.SIGNNAME
        hitValue: park.GlobalID ?? '',
      ),
    );
  }

  return result;
}

/// Extracts parenthesis groups at a specific depth, returning the INSIDE text.
///
/// Example:
/// body: "(((a)),((b)))"
/// targetDepth=2 returns: ["(a)", "(b)"] (depending on structure)
List<String> _extractParenGroupsAtDepth(String input, {required int targetDepth}) {
  final out = <String>[];
  int depth = 0;
  int? start;

  for (int i = 0; i < input.length; i++) {
    final c = input[i];
    if (c == '(') {
      depth++;
      if (depth == targetDepth) {
        start = i + 1; // content starts after this '('
      }
    } else if (c == ')') {
      if (depth == targetDepth && start != null) {
        out.add(input.substring(start, i));
        start = null;
      }
      depth--;
      if (depth < 0) depth = 0; // defensive
    }
  }

  return out;
}

/// Parses a ring text like:
/// "-73.9 40.7, -73.8 40.7, ..."
List<LatLng> _parseLonLatRing(String ringText) {
  final pts = <LatLng>[];

  // Split on commas between coordinate pairs
  final parts = ringText.split(',');
  for (final raw in parts) {
    final t = raw.trim();
    if (t.isEmpty) continue;

    // Split by whitespace (handles multiple spaces)
    final pieces = t.split(RegExp(r'\s+'));
    if (pieces.length < 2) continue;

    final lon = double.tryParse(pieces[0]);
    final lat = double.tryParse(pieces[1]);
    if (lat == null || lon == null) continue;

    pts.add(LatLng(lat, lon));
  }

  return pts;
}

List<LatLng> _ensureClosed(List<LatLng> pts) {
  if (pts.isEmpty) return pts;
  final first = pts.first;
  final last = pts.last;

  // "Close" the ring if needed
  if (first.latitude != last.latitude || first.longitude != last.longitude) {
    return <LatLng>[...pts, first];
  }
  return pts;
}
