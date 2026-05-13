import 'package:flutter/material.dart';
import '../core/colors.dart';


/// ONBOARDING DOT INDICATOR

class OnboardingDot extends StatelessWidget {
  final bool active;

  const OnboardingDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.goldDark : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}


/// PRIMARY GRADIENT BUTTON
/// Note: do NOT use inside a Row without wrapping in Expanded
/// width is controlled by parent

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GradientButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width removed — let parent control width
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [AppColors.goldDark, AppColors.goldLight],
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


/// BACK TEXT BUTTON

class BackButtonText extends StatelessWidget {
  final VoidCallback onTap;

  const BackButtonText({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        "BACK",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}