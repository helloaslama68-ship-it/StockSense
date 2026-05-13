import 'package:flutter/material.dart';

// Onboarding screens
import 'onboarding1.dart';
import 'onboarding2.dart';
import 'onboarding3.dart';

/// 
/// ONBOARDING MAIN SCREEN
/// Controls swipe navigation between onboarding pages
/// Uses PageView + PageController
/// 
class OnboardingMain extends StatefulWidget {
  @override
  State<OnboardingMain> createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {

  // Controller for PageView navigation
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose(); // IMPORTANT: prevents memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Swipeable onboarding pages
      body: PageView(

        controller: _controller,

        children: [

          Onboarding1(controller: _controller),
          Onboarding2(controller: _controller),
          Onboarding3(controller: _controller),
        ],
      ),
    );
  }
}