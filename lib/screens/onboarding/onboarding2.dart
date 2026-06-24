import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/onboarding_widgets.dart';

class Onboarding2 extends StatelessWidget {
  final PageController controller;

  const Onboarding2({super.key, required this.controller});

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

                SizedBox(height: h * 0.03),

                // Feature grid — constrained height so it doesn't over-expand
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: r.isDesktop ? 1.6 : 1.3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _feature(context, Icons.warning, "LOW STOCK"),
                    _feature(context, Icons.event_busy, "EXPIRY\nTRACKING"),
                    _feature(context, Icons.qr_code, "QUICK SCAN"),
                    _feature(context, Icons.show_chart, "SMART\nPREDICTIONS"),
                  ],
                ),

                SizedBox(height: h * 0.03),

                Text(
                  "Smart Tracking and\nInstant Alerts",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: r.sp(20),
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Get low stock warnings, manage expiry\ndates, scan barcodes, and receive\nsmart restock suggestions.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: r.sp(13), color: cs.onSurface.withOpacity(0.6)),
                ),

                SizedBox(height: h * 0.05),

                // Dots
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
        ),
      ),
    );
  }

  Widget _feature(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: cs.shadow.withOpacity(0.06), blurRadius: 10),
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
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}