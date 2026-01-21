import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:nyc_parks/components/user_icon.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/screens/park_screen.dart';
import 'package:nyc_parks/screens/search_screen.dart';
import 'package:nyc_parks/screens/user_screen.dart';
import 'package:nyc_parks/services/friend_services.dart';
import 'package:nyc_parks/services/map_services.dart';
import 'package:nyc_parks/services/user_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:nyc_parks/styles/sizes.dart';
import 'package:nyc_parks/styles/styles.dart';
import 'package:provider/provider.dart';
import 'package:nyc_parks/utils/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum MapViewMode { myParks, friendsParks }

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapService mapService = MapService();
  final UserService userService = UserService();
  final FriendService friendService = FriendService();
  late final AnimatedMapController _animatedMapController =
      AnimatedMapController(vsync: this);
  final List<Polygon> parkPolygons = [];
  List<String> myReviewedParkIds = [];
  List<String> myFavoriteParkIds = [];
  List<String> friendsReviewedParkIds = [];
  List<String> friendsFavoriteParkIds = [];
  bool locationPermissionGranted = false;
  MapViewMode viewMode = MapViewMode.myParks;

  final LayerHitNotifier<Object> _parkHitNotifier = ValueNotifier(null);

  void _openHitParkIfAny() {
    final result = _parkHitNotifier.value;
    print("Result: $result");
    if (result == null || result.hitValues.isEmpty) return;

    final id = result.hitValues.first.toString();
    Provider.of<ParksProvider>(context, listen: false).setActiveParkFromGlobalId(id);

    print("Opening park: $id");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ParkScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    // Load map immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ParksProvider>(context, listen: false)
          .setParks(await mapService.loadParks());

      // Try to get location permission
      try {
        await determinePosition();
        setState(() {
          locationPermissionGranted = true;
        });
      } catch (e) {
        print("Location not available: $e");
        setState(() {
          locationPermissionGranted = false;
        });
      }
    });

    // Load park data asynchronously after map renders
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchUserReviews();
      // Load friends parks in background
      fetchFriendsReviews();
    });
  }

  Future<void> fetchUserReviews() async {
    try {
      final loggedInUserId =
          Provider.of<LoggedInUserProvider>(context, listen: false).user.id;
      final userInfo = await userService.getUserInfo(
          context: context, userId: loggedInUserId);

      if (userInfo != null && userInfo['Reviews'] != null) {
        final reviews = userInfo['Reviews'] as List;

        setState(() {
          myReviewedParkIds =
              reviews.map((review) => review['parkId'] as String).toList();

          // Extract favorite parks
          myFavoriteParkIds = reviews
              .where((review) =>
                  review['favorite'] == true || review['favorite'] == 1)
              .map((review) => review['parkId'] as String)
              .toList();
        });
      }
    } catch (e) {
      print("Failed to load reviewed parks: $e");
    }
  }

  Future<void> fetchFriendsReviews() async {
    try {
      final loggedInUserId =
          Provider.of<LoggedInUserProvider>(context, listen: false).user.id;
      final friendsParksData =
          await friendService.getFriendsParks(userId: loggedInUserId);

      if (friendsParksData != null) {
        setState(() {
          friendsReviewedParkIds =
              (friendsParksData['reviewedParkIds'] as List?)
                      ?.map((parkId) => parkId.toString())
                      .toList() ??
                  [];
          friendsFavoriteParkIds =
              (friendsParksData['favoriteParkIds'] as List?)
                      ?.where((parkId) => parkId != null) // Filter out nulls
                      .map((parkId) => parkId.toString())
                      .toList() ??
                  [];
        });
      }
    } catch (e) {
      print("Failed to load friends' parks: $e");
    }
  }

  List<String> get currentReviewedParkIds {
    return viewMode == MapViewMode.myParks
        ? myReviewedParkIds
        : friendsReviewedParkIds;
  }

  List<String> get currentFavoriteParkIds {
    return viewMode == MapViewMode.myParks
        ? myFavoriteParkIds
        : friendsFavoriteParkIds;
  }

  void toggleViewMode(MapViewMode mode) {
    setState(() {
      viewMode = mode;
    });
  }

  @override
  void dispose() {
    _parkHitNotifier.dispose();
    _animatedMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<LoggedInUserProvider>(context).user;
    final parksAsPolygons =
        Provider.of<ParksProvider>(context).getParksAsPolygons(
      highlightedParkIds: currentReviewedParkIds,
      favoriteParkIds: currentFavoriteParkIds,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _animatedMapController.mapController,
          options: MapOptions(
            initialCenter: const LatLng(40.7128,
                -74.0060), // Center the map over New York City, NY, USA
            initialZoom: 12,
            minZoom: 9.7,
            cameraConstraint: CameraConstraint.contain(
              bounds: LatLngBounds.fromPoints([const LatLng(41.30, -73.35), const LatLng(40.20, -74.50)]),
            ),
            onTap: (_, __) => _openHitParkIfAny(),
          ),
          children: [
            TileLayer(
              // Use local tiles stored in assets
              tileProvider: AssetTileProvider(),
              // TODO: Make this cleaner... include better zoom or alternate local and online tiles
              // TODO: Make it sattelite view
              urlTemplate: 'assets/tiles/{z}/{x}/{y}.png',
              userAgentPackageName: 'parks_app.com.example.app',
            ),
            // Old OpenStreetMap tile layer
            // TileLayer(
            //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            //   userAgentPackageName: 'parks_app.com.example.app',
            // ),
            PolygonLayer(
              polygons: parksAsPolygons,
              hitNotifier: _parkHitNotifier,
            ),
            // Location layer - only show if permission granted
            if (locationPermissionGranted) CurrentLocationLayer(),
            // TODO: Add a better attribution widget
            RichAttributionWidget(
              // Include a stylish prebuilt attribution widget that meets all requirments
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  //onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                  textStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
                // Also add images...
              ],
            ),
          ],
        ),
        // Top bar with search, title, and user icon
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing12, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Search button
                  FloatingActionButton(
                    mini: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.iconXXLarge)),
                    heroTag: 'search',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.search, size: AppSizes.iconLarge),
                  ),
                  // Title
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSizes.spacing16,
                      AppSizes.spacing2,
                      AppSizes.spacing16,
                      AppSizes.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      viewMode == MapViewMode.myParks
                          ? 'My Parks'
                          : "Friends' Parks",
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  // User icon
                  UserIcon(
                    user: loggedInUser,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserScreen(),
                        ),
                      );
                    },
                    iconSize: AppSizes.iconXXLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Location button (separate from toolbar)

        // Centered view mode toolbar
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 30,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'location',
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  onPressed: () async {
                    // Zoom into user's current location
                    try {
                      final position = await determinePosition();
                      _animatedMapController.animateTo(
                        dest: LatLng(position.latitude, position.longitude),
                        zoom: 15,
                      );
                    } catch (e) {
                      print("Could not get location: $e");
                    }
                  },
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.blue,
                    size: 25,
                  ),
                ),
                SegmentedButton<MapViewMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment<MapViewMode>(
                      value: MapViewMode.myParks,
                      icon: SizedBox(
                        width: 40,
                        child: Center(
                          child: UserIcon(
                            user: loggedInUser,
                            iconSize: 28,
                            onPressed: null,
                          ),
                        ),
                      ),
                    ),
                    ButtonSegment<MapViewMode>(
                      value: MapViewMode.friendsParks,
                      icon: const SizedBox(
                        width: 40,
                        child: Center(
                          child: Icon(Icons.people, size: 28),
                        ),
                      ),
                    ),
                  ],
                  selected: {viewMode},
                  onSelectionChanged: (Set<MapViewMode> newSelection) {
                    toggleViewMode(newSelection.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.blue.withOpacity(0.5);
                      }
                      return Colors.white;
                    }),
                    side: WidgetStateProperty.all(
                      BorderSide(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ]),
        ),
      ],
    );
  }
}
