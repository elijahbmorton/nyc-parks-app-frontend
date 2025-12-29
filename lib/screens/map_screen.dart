import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_node_auth/providers/park_provider.dart';
import 'package:flutter_node_auth/screens/park_screen.dart';
import 'package:flutter_node_auth/screens/user_screen.dart';
import 'package:flutter_node_auth/services/map_services.dart';
import 'package:flutter_node_auth/utils/utils.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService mapService = MapService();
  final List<Polygon> parkPolygons = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ParksProvider>(context, listen: false).setParks(await mapService.loadParks());
    });
  }

  @override
  Widget build(BuildContext context) {
    final parks = Provider.of<ParksProvider>(context).parks;
    final parksAsPolygons = Provider.of<ParksProvider>(context).getParksAsPolygons();
    final LayerHitNotifier<Object> parkHitNotifier = ValueNotifier(null);

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(40.7128, -74.0060), // Center the map over New York City, NY, USA
            initialZoom: 12,
            minZoom: 9.7,
          ),
          children: [
            TileLayer( // Bring your own tiles
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // For demonstration only
              userAgentPackageName: 'parks_app.com.example.app' // Add your app identifier
              // And many more recommended properties!
            ),
            MouseRegion(
              hitTestBehavior: HitTestBehavior.deferToChild,
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final LayerHitResult<Object>? result = parkHitNotifier.value;
                  if (result == null) return;
                  
                  for (final hitValue in result.hitValues) {
                      final id = hitValue.toString();
                        Provider.of<ParksProvider>(context, listen: false).setActiveParkFromGlobalId(id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ParkScreen(),
                          ),
                        );
                      }
                },
                child: PolygonLayer(
                  polygons: parksAsPolygons,
                  hitNotifier: parkHitNotifier,
                ),
              ),
            ),
            RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  //onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                ),
                // Also add images...
              ],
            ),
          ],
        ),
        Positioned(
          top: 50,
          right: 10,
          child:IconButton(
              iconSize: 30,
              icon: const Icon(Icons.person),
              style: ButtonStyle( backgroundColor: WidgetStateProperty.all<Color>(Colors.grey)  ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserScreen(),
                  ),
                );
              },
          )
        ),
      ],
    );
  }
}