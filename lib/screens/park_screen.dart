import 'package:flutter/material.dart';
import 'package:nyc_parks/components/leaf_rating.dart';
import 'package:nyc_parks/components/review_card.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/providers/review_provider.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/review_screen.dart';
import 'package:nyc_parks/screens/user_screen.dart';
import 'package:nyc_parks/services/review_services.dart';
import 'package:nyc_parks/styles/styles.dart';
import 'package:nyc_parks/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkScreen extends StatefulWidget {
  const ParkScreen({Key? key}) : super(key: key);

  @override
  State<ParkScreen> createState() => _ParkScreenState();
}

class _ParkScreenState extends State<ParkScreen> {
  String? _lastFetchedParkId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final park = Provider.of<ParksProvider>(context, listen: false).activePark;
    final user = Provider.of<LoggedInUserProvider>(context, listen: false).user;

    final parkId = park.GlobalID;
    if (parkId == null || parkId.isEmpty) return;

    if (_lastFetchedParkId == parkId) return;
    _lastFetchedParkId = parkId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Clear old reviews first so stale data doesn't show
      Provider.of<ReviewProvider>(context, listen: false).clearReviews();
      ReviewService().getReviews(
        context: context,
        parkId: parkId,
        userId: user.id,
      );
    });
  }

  // This function inpired by https://stackoverflow.com/questions/47046637/open-google-maps-app-if-available-with-flutter
  Future<void> _openInMaps(String? address, String borough) async {
    final query = Uri.encodeComponent(
      [address, borough, 'New York'].where((s) => s != null && s.isNotEmpty).join(', ')
    );
    
    final googleUrl = 'comgooglemaps://?q=$query';
    final appleUrl = 'https://maps.apple.com/?q=$query';
    
    if (await canLaunchUrl(Uri.parse('comgooglemaps://'))) {
      await launchUrl(Uri.parse(googleUrl));
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      await launchUrl(Uri.parse(appleUrl), mode: LaunchMode.externalApplication);
    }
  }

  // Widget selection aided by Cursor and Opus 4.5 AI
  @override
  Widget build(BuildContext context) {
    final park = Provider.of<ParksProvider>(context).activePark;
    final reviewProvider = context.watch<ReviewProvider>();
    final loggedInUsersReview = reviewProvider.review;
    final reviews = reviewProvider.reviews;
    final averageRating = reviewProvider.averageRating;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header that sizes to content
              SliverToBoxAdapter(
                child: _buildHeader(park, averageRating),
              ),

              // Quick info chips
          SliverToBoxAdapter(
            child: _buildInfoChips(park),
          ),

          // Add/Edit Review button
          SliverToBoxAdapter(
            child: Padding(
              padding: AppPadding.horizontalMedium,
              child: _buildReviewButton(loggedInUsersReview),
            ),
          ),

          // Reviews header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.spacing16,
                AppSizes.spacing24,
                AppSizes.spacing16,
                AppSizes.spacing8,
              ),
              child: Row(
                children: [
                  Text(
                    'Reviews',
                    style: AppTypography.headlineMedium,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacing8,
                      vertical: AppSizes.spacing2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppBorderRadius.round,
                    ),
                    child: Text(
                      '${reviews.where((r) => r != null).length}',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reviews list
          reviews.isEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptyReviews(),
                )
              : SliverList.separated(
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacing24,
                    ),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    if (review == null) return const SizedBox.shrink();

                    return ReviewCard(
                      review: review,
                      onAuthorTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserScreen(userId: review.author.id),
                          ),
                        );
                      },
                    );
                  },
                ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.spacing32),
          ),
        ],
      ),
    ]),
    );
  }

  Widget _buildHeader(park, int? averageRating) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacing16,
            AppSizes.spacing12,
            AppSizes.spacing16,
            AppSizes.spacing16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back button and Map button row
              Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                  const Spacer(),
                  // Map button
                  GestureDetector(
                    onTap: () {
                      final center = park.getCenterPoint();
                      if (center != null) {
                        // Set the pending zoom location in the provider
                        Provider.of<ParksProvider>(context, listen: false)
                            .setPendingMapZoom(center);

                        // Pop all the way back to the map screen (first route)
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        // Just go back if no coordinates
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.spacing16),
              
              // Park type badge
              if (park.TYPECATEGORY != null && park.TYPECATEGORY!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing12,
                    vertical: AppSizes.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: AppBorderRadius.round,
                  ),
                  child: Text(
                    park.TYPECATEGORY!.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),

              const SizedBox(height: AppSizes.spacing8),

              // Park name
              Text(
                park.SIGNNAME ?? 'Unknown Park',
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.spacing8),

              // Location - tap to open in Maps
              if (park.ADDRESS != null || park.BOROUGH != null)
                GestureDetector(
                  onTap: () => _openInMaps(park.ADDRESS, park.boroughName),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          [toTitleCase(park.ADDRESS), park.boroughName]
                              .where((s) => s.isNotEmpty)
                              .join(', '),
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSizes.spacing24),

              // Rating card
              Container(
                padding: const EdgeInsets.all(AppSizes.spacing16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppBorderRadius.large,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community Rating',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LeafRating(
                            rating: averageRating,
                            size: AppSizes.iconXLarge,
                            showValue: true,
                          ),
                        ],
                      ),
                    ),
                    // Decorative leaf illustration
                    _buildLeafIllustration(averageRating),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeafIllustration(int? rating) {
    final fillPercent = rating != null ? rating / 10 : 0.0;

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withOpacity(0.2),
            ),
          ),
          // Fill circle (animated based on rating)
          Positioned(
            bottom: 0,
            child: ClipOval(
              child: Container(
                width: 56,
                height: 56 * fillPercent,
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ),
          // Leaf icon
          Icon(
            Icons.eco,
            size: 32,
            color: rating != null ? AppColors.primary : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips(park) {
    final chips = <_ChipData>[];

    if (park.ACRES != null && park.ACRES!.isNotEmpty) {
      final acres = double.tryParse(park.ACRES!);
      if (acres != null) {
        chips.add(_ChipData(
          icon: Icons.straighten,
          label: '${acres.toStringAsFixed(1)} acres',
        ));
      }
    }

    if (park.CLASS != null && park.CLASS!.isNotEmpty && park.CLASS! != "PARK") {
      chips.add(_ChipData(
        icon: Icons.park_outlined,
        label: toTitleCase(park.CLASS!),
      ));
    }

    if (park.WATERFRONT == 'true') {
      chips.add(_ChipData(
        icon: Icons.water,
        label: 'Waterfront',
      ));
    }

    if (park.SUBCATEGORY != null && park.SUBCATEGORY!.isNotEmpty && park.SUBCATEGORY! != park.TYPECATEGORY) {
      chips.add(_ChipData(
        icon: Icons.category,
        label: park.SUBCATEGORY!,
      ));
    }

    if (park.RETIRED == 'true') {
      chips.add(_ChipData(
        icon: Icons.park_outlined,
        label: 'Retired',
      ));
    }

    if (park.ZIPCODE != null && park.ZIPCODE!.isNotEmpty) {
      chips.add(_ChipData(
        icon: Icons.pin_drop_outlined,
        label: park.ZIPCODE!,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing16,
        vertical: AppSizes.spacing16,
      ),
      child: Row(
        children: chips.map((chip) {
          return Container(
            margin: const EdgeInsets.only(right: AppSizes.spacing8),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppBorderRadius.round,
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  chip.icon,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  chip.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewButton(loggedInUsersReview) {
    final hasReview = loggedInUsersReview != null;

    return FilledButton.icon(
      onPressed: () => showReviewModal(context),
      icon: Icon(hasReview ? Icons.edit : Icons.rate_review_outlined),
      label: Text(hasReview ? 'Edit Your Review' : 'Write a Review'),
      style: FilledButton.styleFrom(
        backgroundColor: hasReview ? AppColors.secondary : AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.medium,
        ),
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: AppPadding.allLarge,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              size: 40,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Text(
            'No reviews yet',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.spacing8),
          Text(
            'Be the first to share your experience!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipData {
  final IconData icon;
  final String label;

  _ChipData({required this.icon, required this.label});
}
