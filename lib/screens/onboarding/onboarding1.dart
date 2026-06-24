import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/utils/responsive.dart';
import '../auth/create_account.dart';
import '../../widgets/onboarding_widgets.dart';

class Onboarding1 extends StatelessWidget {
  final PageController controller;

  Onboarding1({required this.controller});

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final h = MediaQuery.sizeOf(context).height;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: r.pageHPad, vertical: 20),
            child: Column(
              children: [
                // Logo
                Image.asset('assets/images/logo.png', width: 50),
                const SizedBox(height: 8),
                Text(
                  "StockSense",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: r.sp(16),
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: h * 0.04),

                // Illustration
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.15),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/onboarding1.png',
                      height: h * 0.25,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.04),

                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: r.sp(20),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    children: [
                      const TextSpan(text: "Manage Your "),
                      TextSpan(
                        text: "Inventory",
                        style: const TextStyle(color: AppColors.goldDark),
                      ),
                      const TextSpan(text: "\nEfficiently"),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.02),

                Text(
                  "Track products, monitor stock levels,\n"
                  "and organize grocery inventory in one place.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: r.sp(13), color: AppColors.grey),
                ),

                SizedBox(height: h * 0.05),

                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    OnboardingDot(active: true),
                    OnboardingDot(active: false),
                    OnboardingDot(active: false),
                  ],
                ),

                const SizedBox(height: 24),

                // Next button
                GradientButton(
                  text: "Next",
                  onTap: () => controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => CreateAccount()),
                  ),
                  child: const Text(
                    "Skip Intro",
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}