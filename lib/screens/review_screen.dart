import 'package:flutter/material.dart';
import 'package:nyc_parks/components/leaf_rating.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/providers/review_provider.dart';
import 'package:nyc_parks/services/review_services.dart';
import 'package:nyc_parks/styles/styles.dart';
import 'package:provider/provider.dart';

/// Shows the review modal bottom sheet
Future<void> showReviewModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ReviewModal(),
  );
}

class ReviewModal extends StatefulWidget {
  const ReviewModal({super.key});

  @override
  State<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends State<ReviewModal> {
  final ReviewService reviewService = ReviewService();
  final TextEditingController commentsController = TextEditingController();

  bool _isFavorited = false;
  int? _rating = null;
  bool _initialized = false;
  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final existingReview =
          Provider.of<ReviewProvider>(context, listen: false).review;
      _isFavorited = existingReview?.favorite ?? false;
      _rating = existingReview?.rating ?? null;
      commentsController.text = existingReview?.comments ?? '';
    }
  }

  @override
  void dispose() {
    commentsController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }

  void _submitReview() {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final review = reviewService.validateAndCreateReview(
        context,
        commentsController.text,
        _rating?.toString(),
        _isFavorited,
      );

      Provider.of<ReviewProvider>(context, listen: false)
          .setReviewFromModel(review);

      reviewService.addReview(context: context);

      Navigator.pop(context);
    } catch (e) {
      // Snackbar workaround so it comes in on top the modal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final park = Provider.of<ParksProvider>(context).activePark;
    final existingReview = Provider.of<ReviewProvider>(context).review;
    final isEditing = existingReview != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Review' : 'Write a Review',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            park.SIGNNAME ?? 'Park',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppColors.textSecondary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating section
                      Text(
                        'Your Rating',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildRatingSelector(),

                      const SizedBox(height: 24),

                      // Favorite toggle
                      _buildFavoriteToggle(),

                      const SizedBox(height: 24),

                      // Comments section
                      Text(
                        'Comments',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: commentsController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Share your experience...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor:
                              AppColors.textSecondary.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  AppColors.textSecondary.withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color:
                                  AppColors.textSecondary.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Submit button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size(double.infinity, AppSizes.buttonHeightMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? 'Update Review' : 'Submit Review',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingSelector() {
    final hasRating = _rating != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasRating
            ? AppColors.primaryLight.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: hasRating
            ? null
            : Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
      ),
      child: Column(
        children: [
          if (hasRating)
            LeafRating(rating: _rating, size: 40)
          else
            Text(
              'Drag the slider to rate',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 16),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: hasRating ? AppColors.primary : AppColors.textSecondary,
              inactiveTrackColor: AppColors.primaryLight.withValues(alpha: 0.3),
              thumbColor: hasRating ? AppColors.primary : AppColors.textSecondary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: (_rating ?? 5).toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _rating = value.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteToggle() {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isFavorited
              ? AppColors.favorite.withValues(alpha: 0.1)
              : AppColors.textSecondary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFavorited
                ? AppColors.favorite.withValues(alpha: 0.3)
                : AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? AppColors.favorite : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorite Park',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _isFavorited
                        ? 'This is one of your favorites!'
                        : 'Tap to mark as a favorite',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
