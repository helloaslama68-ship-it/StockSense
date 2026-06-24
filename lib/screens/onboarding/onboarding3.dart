import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/onboarding_widgets.dart';
import '../auth/create_account.dart';

class Onboarding3 extends StatelessWidget {
  final PageController controller;

  const Onboarding3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                    color: cs.onSurface,
                  ),
                ),

                SizedBox(height: h * 0.05),

                // Illustration
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withOpacity(0.15),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/onboarding3.png',
                      height: h * 0.25,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: h * 0.04),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: r.sp(20),
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                    children: [
                      const TextSpan(text: "Grow Your Business\n"),
                      TextSpan(
                        text: "Smarter",
                        style: const TextStyle(color: AppColors.goldDark),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Track sales performance, monitor stock\n"
                  "movements, and make smarter business\n"
                  "decisions with real-time insights.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: r.sp(13), color: cs.onSurface.withOpacity(0.6)),
                ),

                SizedBox(height: h * 0.05),

                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    OnboardingDot(active: false),
                    OnboardingDot(active: false),
                    OnboardingDot(active: true),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BackButtonText(
                      onTap: () => controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: GradientButton(
                        text: 'GET STARTED',
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => CreateAccount()),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}