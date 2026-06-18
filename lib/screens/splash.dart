import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../services/storage_service.dart';
import 'onboarding/onboarding_main.dart';
import 'home/home_screen.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    Future.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      final storage = StorageService();
      if (storage.hasAccount()) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OnboardingMain()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [

          // GRADIENT BACKGROUND — dark
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF121212), const Color(0xFF1A1A1A)]
                    : [AppColors.backgroundTop, AppColors.backgroundBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // BACKGROUND OVERLAY IMAGE
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.05 : 0.2,
              child: Image.asset(
                'assets/images/bg_overlay.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // MAIN CONTENT
          Column(
            children: [

              Spacer(),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Image.asset('assets/images/logo.png', width: 80),

                    SizedBox(height: 14),

                    Text(
                      "StockSense",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),

                    SizedBox(height: 6),

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

                    Container(
                      width: 140,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Align(
                            alignment: Alignment(
                              -1 + (_controller.value * 2),
                              0,
                            ),
                            child: Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 10),

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