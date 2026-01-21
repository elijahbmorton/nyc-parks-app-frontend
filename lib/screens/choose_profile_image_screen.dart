import 'package:flutter/material.dart';
import 'package:nyc_parks/models/user.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/services/user_services.dart';
import 'package:nyc_parks/styles/styles.dart';
import 'package:nyc_parks/utils/utils.dart';
import 'package:provider/provider.dart';

class ChooseProfileImageScreen extends StatefulWidget {
  const ChooseProfileImageScreen({Key? key}) : super(key: key);

  @override
  State<ChooseProfileImageScreen> createState() =>
      _ChooseProfileImageScreenState();
}

class _ChooseProfileImageScreenState extends State<ChooseProfileImageScreen> {
  final UserService userService = UserService();

  ProfileImageImage? selectedImage;
  ProfileImageBackgroundColor? selectedBackgroundColor;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final loggedInUser = context.read<LoggedInUserProvider>().user;
    final existing = loggedInUser.profileImage;

    selectedImage = existing?.image;
    selectedBackgroundColor = existing?.backgroundColor;

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final bool canPickColor = selectedImage != null;
    final bool canSubmit = selectedImage != null && selectedBackgroundColor != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreviewCard(),
                  const SizedBox(height: AppSizes.spacing24),

                  Text('Choose an icon', style: AppTypography.titleLarge),
                  const SizedBox(height: AppSizes.spacing12),
                  _buildImagePicker(),

                  const SizedBox(height: AppSizes.spacing24),

                  Row(
                    children: [
                      Text('Background color', style: AppTypography.titleLarge),
                      const SizedBox(width: AppSizes.spacing8),
                      if (!canPickColor)
                        Text(
                          '(pick an icon first)',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacing12),
                  Opacity(
                    opacity: canPickColor ? 1 : 0.4,
                    child: IgnorePointer(
                      ignoring: !canPickColor,
                      child: _buildBackgroundColorPicker(),
                    ),
                  ),

                  const SizedBox(height: AppSizes.spacing24),

                  FilledButton.icon(
                    onPressed: canSubmit
                        ? () => userService.updateProfileImage(
                              context: context,
                              profileImage: ProfileImage(
                                image: selectedImage!,
                                backgroundColor: selectedBackgroundColor!,
                              ),
                            )
                        : null,
                    //icon: const Icon(Icons.check),
                    label: const Text('Save'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, AppSizes.buttonHeightMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppBorderRadius.medium,
                      ),
                    ),
                    
                  ),

                  const SizedBox(height: AppSizes.spacing32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
              const SizedBox(height: AppSizes.spacing16),
              Text(
                'Profile icon',
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.spacing8),
              Text(
                'Pick a flower and a background color.',
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final previewImage = selectedImage;
    final previewBg = selectedBackgroundColor;

    return Container(
      width: double.infinity,
      padding: AppPadding.allLarge,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.large,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spacing16),
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: previewBg != null
                  ? colorFromProfileImageBackgroundColor(previewBg)
                  : AppColors.primary.withValues(alpha: 0.08),
              child: previewImage != null
                  ? CircleAvatar(
                      radius: 52,
                      backgroundImage: profileImageUri(previewImage),
                      backgroundColor: Colors.transparent,
                    )
                  : Icon(
                      Icons.person,
                      size: 56,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Wrap(
      spacing: AppSizes.spacing8,
      runSpacing: AppSizes.spacing8,
      children: [
        for (final image in ProfileImageImage.values)
          _CircleOption(
            selected: image == selectedImage,
            onTap: () {
              setState(() {
                selectedImage = image;
                selectedBackgroundColor ??= ProfileImageBackgroundColor.green;
              });
            },
            child: CircleAvatar(
              radius: 28,
              backgroundImage: profileImageUri(image),
              backgroundColor: AppColors.surface,
            ),
          ),
      ],
    );
  }

  Widget _buildBackgroundColorPicker() {
    final image = selectedImage;
    return Wrap(
      spacing: AppSizes.spacing8,
      runSpacing: AppSizes.spacing8,
      children: [
        for (final color in ProfileImageBackgroundColor.values)
          _CircleOption(
            selected: color == selectedBackgroundColor,
            onTap: () => setState(() => selectedBackgroundColor = color),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: colorFromProfileImageBackgroundColor(color),
              child: image == null
                  ? null
                  : CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImageUri(image),
                      backgroundColor: Colors.transparent,
                    ),
            ),
          ),
      ],
    );
  }
}

class _CircleOption extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _CircleOption({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacing4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}