import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../widgets/onboarding_widgets.dart';
import '../auth/create_account.dart';

class Onboarding3 extends StatelessWidget {
  final PageController controller;

  const Onboarding3({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            const SizedBox(height: 35),

            Column(
              children: [
                Image.asset('assets/images/logo.png', width: 50),
                const SizedBox(height: 8),
                const Text(
                  "StockSense",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 15),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/onboarding3.png',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 35),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                children: [
                  const TextSpan(text: "Grow Your Business\n"),
                  TextSpan(
                    text: "Smarter",
                    style: TextStyle(color: AppColors.goldDark),
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
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),

            const Spacer(),

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
                  width: 160,  // slightly wider for "GET STARTED" text
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
    );
  }
}