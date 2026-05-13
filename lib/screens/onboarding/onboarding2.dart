import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../widgets/onboarding_widgets.dart';

class Onboarding2 extends StatelessWidget {
  final PageController controller;

  // Initialize onboarding screen with page controller
  // Controls navigation between onboarding pages
  Onboarding2({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            SizedBox(height: 20),

            // ── APP BRANDING 
            // Displays the app logo and app name
            // Reinforces brand identity during onboarding
            Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 50,
                ),

                SizedBox(height: 8),

                Text(
                  "StockSense",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),

            // ── FEATURE GRID 
            // Displays key application features
            // Helps users quickly understand app capabilities
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              physics: NeverScrollableScrollPhysics(),
              children: [

                // Low stock alert feature
                _feature(Icons.warning, "LOW STOCK"),

                // Expiry tracking feature
                _feature(Icons.event_busy, "EXPIRY\nTRACKING"),

                // Barcode scanning feature
                _feature(Icons.qr_code, "QUICK SCAN"),

                // Smart prediction feature
                _feature(Icons.show_chart, "SMART\nPREDICTIONS"),

              ],
            ),

            SizedBox(height: 30),

            // ── MAIN TITLE 
            // Highlights the primary benefits of the app
            Text(
              "Smart Tracking and\nInstant Alerts",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: 12),

            // ── DESCRIPTION TEXT 
            // Explains the core functionality of the app
            Text(
              "Get low stock warnings, manage expiry\ndates, scan barcodes, and receive\nsmart restock suggestions.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),

            Spacer(),

            // ── PAGE INDICATORS 
            // Shows current onboarding page progress
       Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    OnboardingDot(active: false),
    OnboardingDot(active: true),
    OnboardingDot(active: false),
  ],
),

            SizedBox(height: 20),

            // ── NAVIGATION BUTTONS 
            // Back button navigates to previous page
            // Next button navigates to next page
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // ── BACK BUTTON 
                // Moves user to previous onboarding screen
                TextButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // Back arrow icon
                      Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.black,
                        size: 20,
                      ),

                      SizedBox(width: 4),

                      // Back button label
                      Text(
                        "BACK",
                        style: TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── NEXT BUTTON 
                // Navigates user to next onboarding screen
                Container(
                  height: 45,

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),

                    // Gold gradient background
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldDark,
                        AppColors.goldLight,
                      ],
                    ),
                  ),

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                    ),

                    onPressed: () {
                      controller.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Next button text
                        Text(
                          "Next",
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(width: 5),

                        // Forward arrow icon
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── FEATURE CARD WIDGET 
  // Reusable widget for onboarding feature items
  // Displays feature icon and feature title
  Widget _feature(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),

        // Card shadow for elevated appearance
        boxShadow: [
          BoxShadow(
            color: AppColors.black,
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Feature icon
          Icon(
            icon,
            color: AppColors.goldDark,
            size: 26,
          ),

          SizedBox(height: 8),

          // Feature label
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
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