import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Explicitly listen to locale changes to trigger instant rebuild
    final currentLang = context.locale.languageCode;

    final screens = [
      const HomeScreen(),
      _PlaceholderTabScreen(title: 'nav_wardrobe'.tr()),
      _PlaceholderTabScreen(title: 'nav_outfits'.tr()),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: Color(0xFFECE8E2),
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            child: BottomNavigationBar(
              key: ValueKey('bottom_nav_$currentLang'),
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: const Color(0xFFA59F99),
              selectedFontSize: 12.sp,
              unselectedFontSize: 12.sp,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home_filled),
                  label: 'nav_home'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.checkroom_outlined),
                  activeIcon: const Icon(Icons.checkroom),
                  label: 'nav_wardrobe'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.style_outlined),
                  activeIcon: const Icon(Icons.style),
                  label: 'nav_outfits'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded),
                  activeIcon: const Icon(Icons.person_rounded),
                  label: 'nav_profile'.tr(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTabScreen extends StatelessWidget {
  final String title;
  const _PlaceholderTabScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '$title Screen',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
