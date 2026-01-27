import 'package:flutter/material.dart';
import 'package:nyc_parks/components/custom_textfield.dart';
import 'package:nyc_parks/screens/login_screen.dart';
import 'package:nyc_parks/services/auth_services.dart';
import 'package:nyc_parks/styles/styles.dart';

// Tutorial:
// https://www.youtube.com/watch?v=EuP3xycjiM4

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final AuthService authService = AuthService();

  void signupUser() {
    authService.signUpUser(
      context: context,
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
    );
  }

  // Functionality completed by me. Styles and component choice aided by Claude Code using Sonnet 4.5
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient (extends beyond safe area)
            Container(
              width: double.infinity,
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.spacing24,
                    AppSizes.spacing12,
                    AppSizes.spacing24,
                    AppSizes.spacing12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.eco,
                        size: AppSizes.iconXXLarge,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: AppSizes.spacing16),
                      Text(
                        'Join the NYC Green Community',
                        style: AppTypography.displaySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacing8),
                      Text(
                        'Create an account to start exploring',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Form content
            Padding(
              padding: AppPadding.allLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    const SizedBox(height: AppSizes.spacing24),

                    // Name field
                    Text(
                      'Name',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Enter your name',
                    ),

                    const SizedBox(height: AppSizes.spacing20),

                    // Email field
                    Text(
                      'Email',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Enter your email',
                    ),

                    const SizedBox(height: AppSizes.spacing20),

                    // Password field
                    Text(
                      'Password',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacing8),
                    CustomTextField(
                      controller: passwordController,
                      hintText: 'Enter your password',
                    ),

                    const SizedBox(height: AppSizes.spacing40),

                    // Signup button
                    FilledButton(
                      onPressed: signupUser,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, AppSizes.buttonHeightLarge),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.medium,
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSizes.spacing24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Login',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
