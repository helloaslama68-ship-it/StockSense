import 'package:flutter/material.dart';
import '../colors.dart';

enum ScreenSize { phone, tablet, desktop }

class Responsive {
  final BuildContext _ctx;
  const Responsive._(this._ctx);

  static Responsive of(BuildContext context) => Responsive._(context);

  double get _w => MediaQuery.sizeOf(_ctx).width;
  double get _h => MediaQuery.sizeOf(_ctx).height;

  ScreenSize get size {
    if (_w >= 1024) return ScreenSize.desktop;
    if (_w >= 600)  return ScreenSize.tablet;
    return ScreenSize.phone;
  }

  bool get isPhone   => size == ScreenSize.phone;
  bool get isTablet  => size == ScreenSize.tablet;
  bool get isDesktop => size == ScreenSize.desktop;
  bool get isWide    => !isPhone;

  double sp(double phoneVal) {
    if (isPhone)   return phoneVal;
    if (isTablet)  return phoneVal * 1.15;
    return phoneVal * 1.25;
  }

  double wp(double pct) => _w * pct / 100;
  double hp(double pct) => _h * pct / 100;

  EdgeInsets get pagePadding {
    if (isPhone)   return const EdgeInsets.symmetric(horizontal: 16);
    if (isTablet)  return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 32);
  }

  double get pageHPad {
    if (isPhone)   return 16;
    if (isTablet)  return 24;
    return 32;
  }

  double get contentMaxWidth {
    if (isDesktop) return 900;
    if (isTablet)  return 720;
    return double.infinity;
  }

  Widget get gap4  => const SizedBox(height: 4,  width: 4);
  Widget get gap8  => const SizedBox(height: 8,  width: 8);
  Widget get gap12 => const SizedBox(height: 12, width: 12);
  Widget get gap16 => const SizedBox(height: 16, width: 16);
  Widget get gap24 => const SizedBox(height: 24, width: 24);
  Widget get gap32 => const SizedBox(height: 32, width: 32);

  Widget vGap(double v) => SizedBox(height: v);
  Widget hGap(double v) => SizedBox(width: v);

  Widget constrain(Widget child) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: child,
        ),
      );

  int gridColumns({int phone = 2, int tablet = 3, int desktop = 4}) {
    if (isDesktop) return desktop;
    if (isTablet)  return tablet;
    return phone;
  }
}

class AppSpacing {
  AppSpacing._();

  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;

  static const Widget gapXs  = SizedBox(height: xs,  width: xs);
  static const Widget gapSm  = SizedBox(height: sm,  width: sm);
  static const Widget gapMd  = SizedBox(height: md,  width: md);
  static const Widget gapLg  = SizedBox(height: lg,  width: lg);
  static const Widget gapXl  = SizedBox(height: xl,  width: xl);
  static const Widget gapXxl = SizedBox(height: xxl, width: xxl);

  static const Widget vXs  = SizedBox(height: xs);
  static const Widget vSm  = SizedBox(height: sm);
  static const Widget vMd  = SizedBox(height: md);
  static const Widget vLg  = SizedBox(height: lg);
  static const Widget vXl  = SizedBox(height: xl);
  static const Widget vXxl = SizedBox(height: xxl);

  static const Widget hXs  = SizedBox(width: xs);
  static const Widget hSm  = SizedBox(width: sm);
  static const Widget hMd  = SizedBox(width: md);
  static const Widget hLg  = SizedBox(width: lg);
  static const Widget hXl  = SizedBox(width: xl);
  static const Widget hXxl = SizedBox(width: xxl);

  static const EdgeInsets pagePad    = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets cardPad    = EdgeInsets.all(lg);
  static const EdgeInsets chipPad    = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets inputPad   = EdgeInsets.symmetric(horizontal: 14, vertical: 14);
  static const EdgeInsets sectionPad = EdgeInsets.fromLTRB(lg, lg, lg, 0);
}

class AppText {
  AppText._();

  static const TextStyle pageTitle = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800,
    color: AppColors.nearBlack, letterSpacing: -0.5,
  );
  static const TextStyle pageCategory = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: AppColors.charcoalGrey, letterSpacing: 1.4,
  );
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.nearBlack,
  );
  static const TextStyle body = TextStyle(fontSize: 14, color: AppColors.nearBlack);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, color: AppColors.charcoalGrey);
  static const TextStyle caption = TextStyle(fontSize: 10, color: AppColors.charcoalGrey);

  static TextStyle titleR(Responsive r) => TextStyle(
    fontSize: r.sp(26), fontWeight: FontWeight.w800,
    color: AppColors.nearBlack, letterSpacing: -0.5,
  );
  static TextStyle sectionR(Responsive r) => TextStyle(
    fontSize: r.sp(16), fontWeight: FontWeight.w700,
    color: AppColors.nearBlack,
  );
  static TextStyle bodyR(Responsive r) => TextStyle(
    fontSize: r.sp(14), color: AppColors.nearBlack,
  );
  static TextStyle labelR(Responsive r) => TextStyle(
    fontSize: r.sp(13), fontWeight: FontWeight.w600,
    color: AppColors.nearBlack,
  );
  static TextStyle captionR(Responsive r) => TextStyle(
    fontSize: r.sp(10), color: AppColors.charcoalGrey,
  );
}

class AppShell extends StatelessWidget {
  final List<Widget> screens;
  final List<_ShellDest> destinations;

  const AppShell({
    super.key,
    required this.screens,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return r.isDesktop
        ? _DesktopShell(screens: screens, destinations: destinations)
        : _MobileShell(screens: screens, destinations: destinations);
  }
}

class _ShellDest {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _ShellDest({required this.icon, required this.label, IconData? activeIcon})
      : activeIcon = activeIcon ?? icon;
}

class _MobileShell extends StatelessWidget {
  final List<Widget> screens;
  final List<_ShellDest> destinations;
  const _MobileShell({required this.screens, required this.destinations});

  @override
  Widget build(BuildContext context) {
    final idx = ValueNotifier<int>(0);
    return ValueListenableBuilder<int>(
      valueListenable: idx,
      builder: (_, i, __) => Scaffold(
        backgroundColor: AppColors.white,
        body: screens[i],
        bottomNavigationBar: _AppBottomNav(
          current: i,
          destinations: destinations,
          onTap: (v) => idx.value = v,
        ),
      ),
    );
  }
}

class _AppBottomNav extends StatelessWidget {
  final int _current;
  final List<_ShellDest> destinations;
  final ValueChanged<int> onTap;
  const _AppBottomNav({required int current, required this.destinations, required this.onTap})
      : _current = current;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.09),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(destinations.length, (i) {
          final d      = destinations[i];
          final active = _current == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active ? AppColors.goldDark.withOpacity(0.1) : AppColors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? d.activeIcon : d.icon,
                    color: active ? AppColors.goldDark : AppColors.mutedGrey,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(d.label, style: TextStyle(
                    fontSize: 10,
                    color: active ? AppColors.goldDark : AppColors.mutedGrey,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0.2,
                  )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final List<Widget> screens;
  final List<_ShellDest> destinations;
  const _DesktopShell({required this.screens, required this.destinations});

  @override
  Widget build(BuildContext context) {
    final idx = ValueNotifier<int>(0);
    return ValueListenableBuilder<int>(
      valueListenable: idx,
      builder: (_, i, __) => Scaffold(
        backgroundColor: AppColors.white,
        body: Row(
          children: [
            _SideRail(
              current: i,
              destinations: destinations,
              onTap: (v) => idx.value = v,
            ),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.warmWhite),
            Expanded(child: screens[i]),
          ],
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  final int current;
  final List<_ShellDest> destinations;
  final ValueChanged<int> onTap;
  const _SideRail({required this.current, required this.destinations, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.goldDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('StockSense', style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppColors.nearBlack, letterSpacing: -0.5,
                )),
              ]),
            ),
            const SizedBox(height: 32),
            ...List.generate(destinations.length, (i) {
              final d      = destinations[i];
              final active = current == i;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.goldDark.withOpacity(0.1) : AppColors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(
                      active ? d.activeIcon : d.icon,
                      size: 20,
                      color: active ? AppColors.goldDark : AppColors.charcoalGrey,
                    ),
                    const SizedBox(width: 12),
                    Text(d.label, style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? AppColors.goldDark : AppColors.darkGrey,
                    )),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}