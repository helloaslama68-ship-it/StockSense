import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../auth/create_account.dart';
import '../../widgets/onboarding_widgets.dart';


// ONBOARDING SCREEN 1
// First introduction screen shown to the user.
// Explains inventory management feature of the app.

class Onboarding1 extends StatelessWidget {

  // Controller used to navigate between onboarding pages
  final PageController controller;

  // Constructor
  // Receives PageController from parent screen
  Onboarding1({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: Padding(

        padding: EdgeInsets.symmetric(horizontal: 20),

        child: Column(
          children: [

            // Top spacing
            SizedBox(height: 30),

            
            // APP LOGO + APP NAME
            // Displays application branding
            
            Column(
              children: [

                // App logo image
                Image.asset(
                  'assets/images/logo.png',
                  width: 50,
                ),

                SizedBox(height: 8),

                // App name text
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

            SizedBox(height: 50),

            // 
            // ONBOARDING ILLUSTRATION
            // Displays feature-related image
            // 
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

                borderRadius: BorderRadius.circular(10),

                child: Image.asset(
                  'assets/images/onboarding1.png',

                  height: 200,
                  width: double.infinity,

                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 30),

            // 
            // MAIN TITLE
            // Uses RichText to highlight important words
            // 
            RichText(

              textAlign: TextAlign.center,

              text: TextSpan(

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),

                children: [

                  TextSpan(
                    text: "Manage Your ",
                  ),

                  // Highlighted word
                  TextSpan(
                    text: "Inventory",
                    style: TextStyle(
                      color: AppColors.goldDark,
                    ),
                  ),

                  TextSpan(
                    text: "\nEfficiently",
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // 
            // DESCRIPTION TEXT
            // Explains app functionality briefly
            // 
            Text(
              "Track products, monitor stock levels,\n"
              "and organize grocery inventory in one place.",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),

            Spacer(),

            // 
            // PAGE INDICATOR DOTS
            // Shows current onboarding page position
            // 
            Row(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
       OnboardingDot(active: true),
      OnboardingDot(active: false),
       OnboardingDot(active: false),
  ],
),

            SizedBox(height: 30),

            // 
            // NEXT BUTTON
            // Navigates user to next onboarding screen
            // 
          GradientButton(
  text: "Next",
  onTap: () {
    controller.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  },
),

            SizedBox(height: 10),

          
            // SKIP INTRO BUTTON
            // Skips onboarding and opens account creation
            
            TextButton(

              onPressed: () {

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(
                    builder: (_) => CreateAccount(),
                  ),
                );
              },

              child: Text(
                "Skip Intro",

                style: TextStyle(
                  color: AppColors.grey,
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}