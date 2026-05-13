import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../widgets/onboarding_widgets.dart';
import '../auth/create_account.dart';


// ONBOARDING SCREEN 3
// Final onboarding page -> Get started screen

class Onboarding3 extends StatelessWidget {
  final PageController controller;

  Onboarding3({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [

            SizedBox(height: 35),

            // APP BRANDING 
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

            SizedBox(height: 60),

            // IMAGE 
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                  ),
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

            SizedBox(height: 35),

            // TITLE 
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                children: [
                  TextSpan(text: "Grow Your Business\n"),
                  TextSpan(
                    text: "Smarter",
                    style: TextStyle(color: AppColors.goldDark),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12),

            // DESCRIPTION 
            Text(
              "Track sales performance, monitor stock\n"
              "movements, and make smarter business\n"
              "decisions with real-time insights.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),

            Spacer(),

            // DOT INDICATORS (REUSABLE) 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OnboardingDot(active: false),
                OnboardingDot(active: false),
                OnboardingDot(active: true),
              ],
            ),

            SizedBox(height: 20),

            // BACK BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                TextButton(
                  onPressed: () {
                    controller.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_rounded, color: AppColors.black),
                      SizedBox(width: 4),
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

                // GET STARTED BUTTON (REUSABLE) 
                GradientButton(
                  text: "GET STARTED",
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateAccount(),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}