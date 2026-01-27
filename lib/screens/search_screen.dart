import 'package:flutter/material.dart';
import 'package:nyc_parks/components/leaf_rating.dart';
import 'package:nyc_parks/models/park.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/screens/park_screen.dart';
import 'package:nyc_parks/screens/user_screen.dart';
import 'package:nyc_parks/services/search_services.dart';
import 'package:nyc_parks/styles/styles.dart';
import 'package:nyc_parks/utils/constants.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService searchService = SearchService();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> randomParks = [];
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadRandomParks();
  }

  void _loadRandomParks() {
    final parksProvider = Provider.of<ParksProvider>(context, listen: false);
    final allParks = parksProvider.parks;

    if (allParks.isNotEmpty) {
      // Get 10 random parks
      final shuffled = List.from(allParks)..shuffle();
      final selected = shuffled.take(10).map((park) {
        return {
          'GlobalID': park.GlobalID,
          'SIGNNAME': park.SIGNNAME,
          'NAME311': park.NAME311,
          'LOCATION': park.LOCATION,
          'BOROUGH': park.BOROUGH,
          'ZIPCODE': park.ZIPCODE,
          'TYPECATEGORY': park.TYPECATEGORY,
          'type': 'park',
        };
      }).toList();

      setState(() {
        randomParks = selected;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> performSearch() async {
    final query = searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        hasSearched = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    final loggedInUserId = Provider.of<LoggedInUserProvider>(context, listen: false).user.id;
    final results = await searchService.search(
      query: query,
      loggedInUserId: loggedInUserId,
    );

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void navigateToPark(String globalId) async {
    Provider.of<ParksProvider>(context, listen: false).setActiveParkFromGlobalId(globalId);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParkScreen(),
      ),
    );

    // If a LatLng is returned, pop back to map with coordinates
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  void navigateToUser(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back button and title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.spacing16,
                      AppSizes.spacing12,
                      AppSizes.spacing16,
                      AppSizes.spacing16,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacing16),
                        Expanded(
                          child: Text(
                            'Search Parks',
                            style: AppTypography.headlineLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.spacing16,
                      0,
                      AppSizes.spacing16,
                      AppSizes.spacing16,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppBorderRadius.medium,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        style: AppTypography.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search parks, locations, reviews...',
                          hintStyle: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: AppBorderRadius.medium,
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppBorderRadius.medium,
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppBorderRadius.medium,
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      searchResults = [];
                                      hasSearched = false;
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.spacing16,
                            vertical: AppSizes.spacing12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {}); // Rebuild to show/hide clear button
                        },
                        onSubmitted: (value) => performSearch(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Results
          Expanded(
            child:
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : hasSearched && searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: AppSizes.spacing16),
                            Text(
                              'No results found',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacing8),
                            Text(
                              'Try searching with different keywords',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : !hasSearched && randomParks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.park_outlined,
                                  size: 80,
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AppSizes.spacing16),
                                Text(
                                  'Search for parks',
                                  style: AppTypography.titleLarge.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.spacing8),
                                Text(
                                  'Find parks by name, location, or reviews',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : !hasSearched && randomParks.isNotEmpty
                            ? _buildRandomParksList()
                            : _buildSearchResults()
          ),
        ],
      ),
    );
  }

  Widget _buildRandomParksList() {
    return ListView(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      children: [
        Text(
          'Explore',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.spacing8),
        Text(
          'Random parks to get started',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacing16),
        ...randomParks.map((park) => _buildParkCard(park, [])),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];

        // Check if it's a standalone review
        final isReview = result['type'] == 'review';

        if (isReview) {
          // Display standalone review
          final rating = result['stars'] as int?;

          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppBorderRadius.medium,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: AppPadding.allMedium,
              leading: Container(
                padding: const EdgeInsets.all(AppSizes.spacing8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: AppBorderRadius.small,
                ),
                child: Icon(
                  Icons.rate_review,
                  color: AppColors.accent,
                ),
              ),
              title: Text(
                result['comments'] ?? 'No comment',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSizes.spacing8),
                child: LeafRating(
                  rating: rating,
                  size: 16,
                ),
              ),
              onTap: () => navigateToPark(result['parkId']),
            ),
          );
        } else {
          // Display park result
          final allMatchingReviews = result['matchingReviews'] as List? ?? [];
          final matchingReviews = allMatchingReviews.take(2).toList();

          return _buildParkCard(result, matchingReviews);
        }
      },
    );
  }

  Widget _buildParkCard(Map<String, dynamic> result, List matchingReviews) {
    final typeCategory = result['TYPECATEGORY'] as String?;
    final parkIcon = typeCategory != null
        ? Constants.typeCategoryIcons[typeCategory] ?? Icons.park
        : Icons.park;
    final boroughCode = result['BOROUGH'] as String?;
    final boroughName = boroughFromCode(boroughCode);
    final zipcode = result['ZIPCODE'] as String?;
    final firstZipcode = zipcode?.split(',').first.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.medium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: AppPadding.allMedium,
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSizes.spacing16,
            0,
            AppSizes.spacing16,
            AppSizes.spacing16,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppSizes.spacing8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppBorderRadius.small,
            ),
            child: Icon(
              parkIcon,
              color: AppColors.primary,
            ),
          ),
          title: Text(
            result['SIGNNAME'] ?? result['NAME311'] ?? 'Unknown Park',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSizes.spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result['LOCATION'] != null)
                  Text(
                    result['LOCATION'],
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (boroughName.isNotEmpty)
                      Text(
                        boroughName,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (firstZipcode != null && firstZipcode.isNotEmpty)
                      Text(
                        ' • $firstZipcode',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          children: [
            if (matchingReviews.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Matching Reviews:',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              ...matchingReviews.map((review) {
                final reviewRating = review['stars'] as int?;

                return Container(
                  margin: const EdgeInsets.only(bottom: AppSizes.spacing8),
                  padding: AppPadding.allSmall,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppBorderRadius.small,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.comment,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              review['comments'] ?? 'No comment',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LeafRating(
                        rating: reviewRating,
                        size: 14,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSizes.spacing8),
            ],
            FilledButton.icon(
              onPressed: () => navigateToPark(result['GlobalID']),
              icon: const Icon(Icons.arrow_forward, size: 20),
              label: const Text('View Park Details'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

