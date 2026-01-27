import 'package:flutter/material.dart';
import 'package:nyc_parks/components/friend_request_button.dart';
import 'package:nyc_parks/components/review_card.dart';
import 'package:nyc_parks/components/user_icon.dart';
import 'package:nyc_parks/models/park.dart';
import 'package:nyc_parks/models/review.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/screens/choose_profile_image_screen.dart';
import 'package:nyc_parks/screens/park_screen.dart';
import 'package:nyc_parks/services/auth_services.dart';
import 'package:nyc_parks/services/friend_services.dart';
import 'package:nyc_parks/services/user_services.dart';
import 'package:nyc_parks/styles/styles.dart';
import 'package:nyc_parks/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class UserScreen extends StatefulWidget {
  final int? userId;

  const UserScreen({
    super.key,
    this.userId,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService userService = UserService();
  final FriendService friendService = FriendService();
  int? userId;
  bool isLoggedInUser = false;
  List<Park> parks = [];
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;
  Map<String, dynamic>? friendRequestWithLoggedInUser = {};

  @override
  void initState() {
    super.initState();
    int loggedInUserId =
        Provider.of<LoggedInUserProvider>(context, listen: false).user.id;
    parks = Provider.of<ParksProvider>(context, listen: false).parks;
    if (widget.userId == null || widget.userId == loggedInUserId) {
      setState(() {
        userId = loggedInUserId;
        isLoggedInUser = true;
      });
      fetchUserInfo();
    } else {
      setState(() {
        userId = widget.userId;
        isLoggedInUser = false;
      });
      loadUserData(loggedInUserId);
    }
  }

  Future<void> loadUserData(int loggedInUserId) async {
    await fetchFriendRequest(loggedInUserId);
    await fetchUserInfo();
  }

  Future<void> fetchFriendRequest(int loggedInUserId) async {
    try {
      friendRequestWithLoggedInUser = await friendService.getFriendRequest(
          userId: loggedInUserId, friendId: widget.userId!);
      // Check if the response has an error
      if (friendRequestWithLoggedInUser != null &&
          friendRequestWithLoggedInUser!['error'] != null) {
        setState(() {
          friendRequestWithLoggedInUser = null;
        });
      } else {
        setState(() {
          friendRequestWithLoggedInUser = friendRequestWithLoggedInUser;
        });
      }
    } catch (e) {
      setState(() {
        friendRequestWithLoggedInUser = null;
      });
    }
  }

Future<void> fetchUserInfo({bool showLoader = true}) async {
  try {
    if (showLoader) {
      setState(() {
        isLoading = true;
      });
    }

    final fetchedUserInfo =
        await userService.getUserInfo(context: context, userId: userId!);

    setState(() {
      userInfo = fetchedUserInfo!;
      isLoading = false; // ok even for showLoader=false
    });
  } catch (e) {
    showSnackBar("Failed to fetch user");
    if (showLoader) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  String _formatJoinDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return 'Joined ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '';
    }
  }

  void _navigateToPark(String parkId) {
    final parksProvider = Provider.of<ParksProvider>(context, listen: false);
    parksProvider.setActiveParkFromGlobalId(parkId);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ParkScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFriend = friendRequestWithLoggedInUser?['status'] == 'accepted';
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverToBoxAdapter(
                    child: _buildHeader(isFriend),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.rate_review_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text('Reviews (${userInfo['Reviews']?.length ?? 0})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_outline, size: 18),
                                const SizedBox(width: 8),
                                Text('Friends (${_getAcceptedFriends().length})'),
                              ],
                            ),
                          ),
                        ],
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _buildReviewsTab(),
                    _buildFriendsTab(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(bool isFriend) {
    final user = userInfo.isNotEmpty ? User.fromMap(userInfo) : null;
    final joinDate = _formatJoinDate(userInfo['createdAt']);
    final reviewCount = userInfo['Reviews']?.length ?? 0;

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
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacing16,
            AppSizes.spacing12,
            AppSizes.spacing16,
            AppSizes.spacing24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back button and badges row
              Row(
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
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 24),
                    ),
                  ),
                  const Spacer(),
                  // Me or Friend badge
                  if (isLoggedInUser)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing12,
                        vertical: AppSizes.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        borderRadius: AppBorderRadius.round,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'ME',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isFriend)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacing12,
                        vertical: AppSizes.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.3),
                        borderRadius: AppBorderRadius.round,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'FRIEND',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSizes.spacing24),

              // User avatar and info
              Row(
                children: [
                  // Avatar (tappable for logged in user)
                  GestureDetector(
                    onTap: isLoggedInUser
                      ? () async {
                          final didUpdate = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (context) => const ChooseProfileImageScreen()),
                          );

                          if (didUpdate == true && mounted) {
                            // Instant UI update (no network):
                            final pi = context.read<LoggedInUserProvider>().user.profileImage;
                            if (pi != null) {
                              setState(() {
                                userInfo['profileImage'] = {
                                  'image': pi.image.name,
                                  'backgroundColor': pi.backgroundColor.name,
                                };
                              });
                            }

                            // Optional: keep backend map fully fresh, but silently:
                            await fetchUserInfo(showLoader: false);
                          }
                        }
                      : null,
                    child: Stack(
                      children: [
                        if (user != null)
                          UserIcon(
                            user: user,
                            iconSize: 100,
                          )
                        else
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                size: 50, color: Colors.white),
                          ),
                        if (isLoggedInUser)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacing16),
                  // Name and stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo['name'] ?? 'User',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacing4),
                        if (joinDate.isNotEmpty)
                          Text(
                            joinDate,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        const SizedBox(height: AppSizes.spacing8),
                        // Stats row
                        Row(
                          children: [
                            _buildStatChip(
                              Icons.rate_review,
                              '$reviewCount parks reviewed',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Friend request button (for non-logged-in users)
              if (!isLoggedInUser && user != null) ...[
                const SizedBox(height: AppSizes.spacing16),
                SizedBox(
                  width: double.infinity,
                  child: FriendRequestButton(
                    friend: {
                      ...user.toMap(),
                      'friendRequestStatus':
                          friendRequestWithLoggedInUser?['status'] ?? 'none',
                      'userId': friendRequestWithLoggedInUser?['userId'],
                    },
                    useWhiteStyle: true,
                  ),
                ),
              ],

              // Action buttons (for logged-in user)
              if (isLoggedInUser) ...[
                const SizedBox(height: AppSizes.spacing16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final userId = Provider.of<LoggedInUserProvider>(context, listen: false).user.id;
                          final userName = Provider.of<LoggedInUserProvider>(context, listen: false).user.name;

                          // Deep link format: nycgreen://user/{userId}
                          final deepLink = 'nycgreen://user/$userId';

                          // TODO: Replace with your actual app store links when published
                          final appStoreLink = 'https://apps.apple.com/app/nycgreen'; // iOS App Store
                          //final playStoreLink = 'https://play.google.com/store/apps/details?id=com.example.nyc_parks'; // Android Play Store

                          Share.share(
                            'Check out $userName\'s profile on NYC Green!\n\n'
                            'Open in app: $deepLink\n\n'
                            'Don\'t have the app?\n'
                            'iOS: $appStoreLink\n',
                            //'Android: $playStoreLink',
                            subject: 'Connect with $userName on NYC Green',
                          );
                        },
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text('Share Profile'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          minimumSize: const Size(0, AppSizes.buttonHeightMedium),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.medium,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacing12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(
                                'Logout',
                                style: AppTypography.titleLarge,
                              ),
                              content: Text(
                                'Are you sure you want to logout?',
                                style: AppTypography.bodyMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppBorderRadius.medium,
                              ),
                              actionsOverflowButtonSpacing: AppSizes.spacing8,
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.pop(dialogContext),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                            color: AppColors.textSecondary.withValues(alpha: 0.3),
                                          ),
                                          minimumSize: const Size(0, AppSizes.buttonHeightMedium),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: AppBorderRadius.medium,
                                          ),
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: AppTypography.labelLarge.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.spacing12),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          AuthService().signOut(context);
                                        },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          minimumSize: const Size(0, AppSizes.buttonHeightMedium),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: AppBorderRadius.medium,
                                          ),
                                        ),
                                        child: Text(
                                          'Logout',
                                          style: AppTypography.labelLarge.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                          minimumSize: const Size(0, AppSizes.buttonHeightMedium),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppBorderRadius.medium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacing8,
        vertical: AppSizes.spacing4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppBorderRadius.round,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final reviews = userInfo['Reviews'] as List? ?? [];

    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'No reviews yet',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: reviews.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ),
      itemBuilder: (context, index) {
        final reviewData = reviews[index];
        final parkId = reviewData['parkId'] as String;
        final park = parks.firstWhere(
          (p) => p.GlobalID == parkId,
          orElse: () => Park(GlobalID: parkId, SIGNNAME: 'Unknown Park'),
        );

        // Create a Review model from the data
        final review = Review(
          id: reviewData['id'],
          parkId: parkId,
          comments: reviewData['comments'],
          rating: reviewData['rating'],
          favorite: reviewData['favorite'] ?? false,
          author: User.fromMap(userInfo),
          createdAt: reviewData['createdAt'],
        );

        return ReviewCard(
          review: review,
          showAuthor: false,
          parkName: park.SIGNNAME ?? 'Unknown Park',
          onParkTap: () => _navigateToPark(parkId),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getAcceptedFriends() {
    final friends = userInfo['friends'] as List? ?? [];
    return friends.where((f) => f['friendRequestStatus'] == 'accepted').toList().cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> _getPendingFriends() {
    final friends = userInfo['friends'] as List? ?? [];
    return friends.where((f) => f['friendRequestStatus'] == 'pending').toList().cast<Map<String, dynamic>>();
  }

  String _formatFriendDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 30) {
        return 'Friends for ${difference.inDays} days';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return 'Friends for $months month${months > 1 ? 's' : ''}';
      } else {
        final years = (difference.inDays / 365).floor();
        return 'Friends for $years year${years > 1 ? 's' : ''}';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildFriendsTab() {
    final acceptedFriends = _getAcceptedFriends();
    final pendingFriends = _getPendingFriends();

    if (acceptedFriends.isEmpty && pendingFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacing16),
            Text(
              'No friends yet',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Pending Requests Section (only show if logged in user and has pending)
        if (isLoggedInUser && pendingFriends.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacing16,
              AppSizes.spacing16,
              AppSizes.spacing16,
              AppSizes.spacing8,
            ),
            color: AppColors.background,
            child: Row(
              children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.spacing8),
                Text(
                  'Pending Requests',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing8,
                    vertical: AppSizes.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: AppBorderRadius.round,
                  ),
                  child: Text(
                    '${pendingFriends.length}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...pendingFriends.asMap().entries.map((entry) {
            final index = entry.key;
            final friend = entry.value;
            final friendUser = User.fromMap(friend);

            return Column(
              children: [
                _buildFriendCard(friendUser, friend, showDate: false),
                if (index < pendingFriends.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: AppSizes.spacing16),
        ],

        // Friends Section
        if (acceptedFriends.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacing16,
              AppSizes.spacing16,
              AppSizes.spacing16,
              AppSizes.spacing8,
            ),
            color: AppColors.background,
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSizes.spacing8),
                Text(
                  'Friends',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSizes.spacing8),
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
                    '${acceptedFriends.length}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...acceptedFriends.asMap().entries.map((entry) {
            final index = entry.key;
            final friend = entry.value;
            final friendUser = User.fromMap(friend);

            return Column(
              children: [
                _buildFriendCard(friendUser, friend, showDate: true),
                if (index < acceptedFriends.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            );
          }),
        ],
      ],
    );
  }

  Widget _buildFriendCard(User friend, Map<String, dynamic> friendData, {bool showDate = false}) {
    final friendDate = showDate ? _formatFriendDate(friendData['createdAt']) : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserScreen(userId: friend.id),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: AppPadding.allMedium,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            UserIcon(
              user: friend,
              iconSize: AppSizes.avatarLarge,
            ),
            const SizedBox(width: AppSizes.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacing4),
                  if (showDate && friendDate.isNotEmpty)
                    Text(
                      friendDate,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else if (isLoggedInUser)
                    FriendRequestButton(friend: friendData)
                  else
                    Text(
                      'Friend',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom delegate for pinned tab bar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
