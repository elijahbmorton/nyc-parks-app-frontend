import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nyc_parks/utils/constants.dart';

String boroughFromCode(String? code) {
  switch (code?.toUpperCase()) {
    case 'B':
      return 'Brooklyn';
    case 'M':
      return 'Manhattan';
    case 'X':
      return 'Bronx';
    case 'R':
      return 'Staten Island';
    case 'Q':
      return 'Queens';
    default:
      return code ?? '';
  }
}

class Park {	
  // TODO: figure out which are actually required
  // Right now they're all nullable
  final String? ACQUISITIONDATE;
  final String? ACRES;
  final String? ADDRESS;
  final String? BOROUGH;
  final String? CLASS;
  final String? COMMUNITYBOARD;
  final String? COUNCILDISTRICT;
  final String? DEPARTMENT;
  final String? GISOBJID;
  final String? GISPROPNUM;
  final String? GlobalID;
  final String? JURISDICTION;
  final String? LOCATION;
  final String? NAME311;
  final String? NYS_ASSEMBLY;
  final String? NYS_SENATE;
  final String? OBJECTID;
  final String? OMPPROPID;
  final String? PARENTID;
  final String? PERMIT;
  final String? PERMITDISTRICT;
  final String? PERMITPARENT;
  final String? PIP_RATABLE;
  final String? PRECINCT;
  final String? RETIRED;
  final String? SIGNNAME;
  final String? SUBCATEGORY;
  final String? TYPECATEGORY;
  final String? US_CONGRESS;
  final String? WATERFRONT;
  final String? ZIPCODE;
  final String? multipolygon;

  /// Returns the full borough name from the single-character code
  String get boroughName => boroughFromCode(BOROUGH);

  /// Calculates the center point of the park by averaging all polygon coordinates
  LatLng? getCenterPoint() {
    if (multipolygon == null || multipolygon!.isEmpty) return null;

    try {
      final coords = <LatLng>[];
      var wkt = multipolygon!.trim();

      // Handle optional SRID prefix
      final sridIdx = wkt.indexOf(';');
      if (sridIdx != -1 && wkt.substring(0, sridIdx).toUpperCase().startsWith('SRID=')) {
        wkt = wkt.substring(sridIdx + 1).trim();
      }

      // Extract coordinate pairs from the WKT string
      final regex = RegExp(r'(-?\d+\.?\d*)\s+(-?\d+\.?\d*)');
      final matches = regex.allMatches(wkt);

      for (final match in matches) {
        final lon = double.tryParse(match.group(1) ?? '');
        final lat = double.tryParse(match.group(2) ?? '');
        if (lon != null && lat != null) {
          coords.add(LatLng(lat, lon));
        }
      }

      if (coords.isEmpty) return null;

      // Calculate average
      double sumLat = 0;
      double sumLon = 0;
      for (final coord in coords) {
        sumLat += coord.latitude;
        sumLon += coord.longitude;
      }

      return LatLng(sumLat / coords.length, sumLon / coords.length);
    } catch (e) {
      return null;
    }
  }

  Park({
    this.ACQUISITIONDATE,
    this.ACRES,
    this.ADDRESS,
    this.BOROUGH,
    this.CLASS,
    this.COMMUNITYBOARD,
    this.COUNCILDISTRICT,
    this.DEPARTMENT,
    this.GISOBJID,
    this.GISPROPNUM,
    this.GlobalID,
    this.JURISDICTION,
    this.LOCATION,
    this.NAME311,
    this.NYS_ASSEMBLY,
    this.NYS_SENATE,
    this.OBJECTID,
    this.OMPPROPID,
    this.PARENTID,
    this.PERMIT,
    this.PERMITDISTRICT,
    this.PERMITPARENT,
    this.PIP_RATABLE,
    this.PRECINCT,
    this.RETIRED,
    this.SIGNNAME,
    this.SUBCATEGORY,
    this.TYPECATEGORY,
    this.US_CONGRESS,
    this.WATERFRONT,
    this.ZIPCODE,
    this.multipolygon,
  });

  Map<String, dynamic> toMap() {
    return {
      'ACQUISITIONDATE': ACQUISITIONDATE,
      'ACRES': ACRES,
      'ADDRESS': ADDRESS,
      'BOROUGH': BOROUGH,
      'CLASS': CLASS,
      'COMMUNITYBOARD': COMMUNITYBOARD,
      'COUNCILDISTRICT': COUNCILDISTRICT,
      'DEPARTMENT': DEPARTMENT,
      'GISOBJID': GISOBJID,
      'GISPROPNUM': GISPROPNUM,
      'GlobalID': GlobalID,
      'JURISDICTION': JURISDICTION,
      'LOCATION': LOCATION,
      'NAME311': NAME311,
      'NYS_ASSEMBLY': NYS_ASSEMBLY,
      'NYS_SENATE': NYS_SENATE,
      'OBJECTID': OBJECTID,
      'OMPPROPID': OMPPROPID,
      'PARENTID': PARENTID,
      'PERMIT': PERMIT,
      'PERMITDISTRICT': PERMITDISTRICT,
      'PERMITPARENT': PERMITPARENT,
      'PIP_RATABLE': PIP_RATABLE,
      'PRECINCT': PRECINCT,
      'RETIRED': RETIRED,
      'SIGNNAME': SIGNNAME,
      'SUBCATEGORY': SUBCATEGORY,
      'TYPECATEGORY': TYPECATEGORY,
      'US_CONGRESS': US_CONGRESS,
      'WATERFRONT': WATERFRONT,
      'ZIPCODE': ZIPCODE,
      'multipolygon': multipolygon,
    };
  }

  IconData get typeCategoryIcon => Constants.typeCategoryIcons[TYPECATEGORY ?? ''] ?? Icons.park; // fallback

  factory Park.fromMap(Map<String, dynamic> map) {
    return Park(
      ACQUISITIONDATE: map['ACQUISITIONDATE'] ?? '',
      ACRES: map['ACRES'] ?? '',
      ADDRESS: map['ADDRESS'] ?? '',
      BOROUGH: map['BOROUGH'] ?? '',
      CLASS: map['CLASS'] ?? '',
      COMMUNITYBOARD: map['COMMUNITYBOARD'] ?? '',
      COUNCILDISTRICT: map['COUNCILDISTRICT'] ?? '',
      DEPARTMENT: map['DEPARTMENT'] ?? '',
      GISOBJID: map['GISOBJID'] ?? '',
      GISPROPNUM: map['GISPROPNUM'] ?? '',
      GlobalID: map['GlobalID'] ?? '',
      JURISDICTION: map['JURISDICTION'] ?? '',
      LOCATION: map['LOCATION'] ?? '',
      NAME311: map['NAME311'] ?? '',
      NYS_ASSEMBLY: map['NYS_ASSEMBLY'] ?? '',
      NYS_SENATE: map['NYS_SENATE'] ?? '',
      OBJECTID: map['OBJECTID'] ?? '',
      OMPPROPID: map['OMPPROPID'] ?? '',
      PARENTID: map['PARENTID'] ?? '',
      PERMIT: map['PERMIT'] ?? '',
      PERMITDISTRICT: map['PERMITDISTRICT'] ?? '',
      PERMITPARENT: map['PERMITPARENT'] ?? '',
      PIP_RATABLE: map['PIP_RATABLE'] ?? '',
      PRECINCT: map['PRECINCT'] ?? '',
      RETIRED: map['RETIRED'] ?? '',
      SIGNNAME: map['SIGNNAME'] ?? '',
      SUBCATEGORY: map['SUBCATEGORY'] ?? '',
      TYPECATEGORY: map['TYPECATEGORY'] ?? '',
      US_CONGRESS: map['US_CONGRESS'] ?? '',
      WATERFRONT: map['WATERFRONT'] ?? '',
      ZIPCODE: map['ZIPCODE'] ?? '',
      multipolygon: map['multipolygon'] ?? '',
    );
  }

  static Future<Park> fromCSV(List<dynamic> input) async {
    return Park(
      ACQUISITIONDATE: input[0]?.toString(),
      ACRES: input[1]?.toString(),
      ADDRESS: input[2]?.toString(),
      BOROUGH: input[3]?.toString(),
      CLASS: input[4]?.toString(),
      COMMUNITYBOARD: input[5]?.toString(),
      COUNCILDISTRICT: input[6]?.toString(),
      DEPARTMENT: input[7]?.toString(),
      GISOBJID: input[8]?.toString(),
      GISPROPNUM: input[9]?.toString(),
      GlobalID: input[10]?.toString(),
      JURISDICTION: input[11]?.toString(),
      LOCATION: input[12]?.toString(),
      NAME311: input[14]?.toString(),
      NYS_ASSEMBLY: input[15]?.toString(),
      NYS_SENATE: input[16]?.toString(),
      OBJECTID: input[17]?.toString(),
      OMPPROPID: input[18]?.toString(),
      PARENTID: input[19]?.toString(),
      PERMIT: input[20]?.toString(),
      PERMITDISTRICT: input[21]?.toString(),
      PERMITPARENT: input[22]?.toString(),
      PIP_RATABLE: input[23]?.toString(),
      PRECINCT: input[24]?.toString(),
      RETIRED: input[25]?.toString(),
      SIGNNAME: input[26]?.toString(),
      SUBCATEGORY: input[27]?.toString(),
      TYPECATEGORY: input[28]?.toString(),
      US_CONGRESS: input[29]?.toString(),
      WATERFRONT: input[30]?.toString(),
      ZIPCODE: input[31]?.toString(),
      multipolygon: input[32]?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Park.fromJson(String source) => Park.fromMap(json.decode(source));
}
