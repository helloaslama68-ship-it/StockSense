import 'package:flutter/material.dart';

// Import custom app colors
import '../core/colors.dart';

// Import local storage service
import '../services/storage_service.dart';

// Import onboarding screen
import 'onboarding/onboarding_main.dart';

// Import main home screen
import 'home/home_screen.dart';


// Splash screen widget
// StatefulWidget is used because animation is required
class Splash extends StatefulWidget {

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash>

    // SingleTickerProviderStateMixin provides animation support
    with SingleTickerProviderStateMixin {

  // Animation controller for loading animation
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(

      // Sync animation with screen refresh rate
      vsync: this,

      // Animation duration
      duration: Duration(seconds: 2),

    )

      // Repeat animation continuously
      ..repeat();

    // Wait 3 seconds before navigating
    Future.delayed(Duration(seconds: 3), () {

      // Prevent navigation if widget is removed
      if (!mounted) return;

      // Access local storage service
      final storage = StorageService();

      // Check whether account already exists
      if (storage.hasAccount()) {

        // Existing user → open Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(),
          ),
        );

      } else {

        // First-time user → open onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardingMain(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {

    // Dispose animation controller
    // Prevents memory leaks
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(
        children: [

          
          // GRADIENT BACKGROUND
          

          Container(
            width: double.infinity,

            decoration: BoxDecoration(

              // Vertical gradient background
              gradient: LinearGradient(

                colors: [
                  AppColors.backgroundTop,
                  AppColors.backgroundBottom,
                ],

                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          
          // BACKGROUND OVERLAY IMAGE
          

          Positioned.fill(

            child: Opacity(

              // Reduce opacity for subtle effect
              opacity: 0.2,

              child: Image.asset(

                // Decorative overlay image
                'assets/images/bg_overlay.png',

                fit: BoxFit.cover,
              ),
            ),
          ),

          
          // MAIN CONTENT
          

          Column(
            children: [

              Spacer(),

              // Center app branding section
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [

                    // App logo
                    Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                    ),

                    SizedBox(height: 14),

                    // App name
                    Text(
                      "StockSense",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),

                    SizedBox(height: 6),

                    // App tagline
                    Text(
                      "Sense Your Stock Before It\nRuns Out",

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),

              
              // LOADING ANIMATION
              

              Padding(
                padding: EdgeInsets.only(bottom: 40),

                child: Column(
                  children: [

                    // Background progress bar
                    Container(

                      width: 140,
                      height: 4,

                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,

                        borderRadius:
                            BorderRadius.circular(10),
                      ),

                      // Animated loading indicator
                      child: AnimatedBuilder(

                        // Listen to animation controller
                        animation: _controller,

                        builder: (context, child) {

                          return Align(

                            // Move indicator left to right
                            alignment: Alignment(
                              -1 + (_controller.value * 2),
                              0,
                            ),

                            child: Container(

                              width: 50,
                              height: 4,

                              decoration: BoxDecoration(
                                color: AppColors.primary,

                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 10),

                    // Loading text
                    Text(
                      "INITIALIZING",

                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}