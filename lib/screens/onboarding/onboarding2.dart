import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../widgets/onboarding_widgets.dart';

class Onboarding2 extends StatelessWidget {
  final PageController controller;

  const Onboarding2({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            const SizedBox(height: 20),

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

            const SizedBox(height: 25),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _feature(Icons.warning, "LOW STOCK"),
                _feature(Icons.event_busy, "EXPIRY\nTRACKING"),
                _feature(Icons.qr_code, "QUICK SCAN"),
                _feature(Icons.show_chart, "SMART\nPREDICTIONS"),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Smart Tracking and\nInstant Alerts",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Get low stock warnings, manage expiry\ndates, scan barcodes, and receive\nsmart restock suggestions.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                OnboardingDot(active: false),
                OnboardingDot(active: true),
                OnboardingDot(active: false),
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
                  width: 140,
                  child: GradientButton(
                    text: 'Next',
                    onTap: () => controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
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

  Widget _feature(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.goldDark, size: 26),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}