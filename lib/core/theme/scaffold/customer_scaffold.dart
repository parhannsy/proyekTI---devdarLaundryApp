import 'package:devdar_laundry_pos_app/core/theme/widgets/customer/top_bar.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/mission/index.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/order/index.dart';
import 'package:flutter/material.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/dashboard/index.dart';
import 'package:devdar_laundry_pos_app/features/customer/pages/profil/index.dart';
import 'package:devdar_laundry_pos_app/core/theme/widgets/customer/bottom_bar.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _currentIndex = 0;
  late PageController _pageController;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _resetScrollPosition();
  }

  void _resetScrollPosition() {
    try {
      PrimaryScrollController.of(context).animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Membiarkan body memanjang ke bawah BottomBar
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: const FloatingTopbar(),
                ),
              ];
            },
            // body TIDAK BOLEH dibungkus SafeArea/Padding jika ingin efek transparan
            body: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const HomePage(),
                const OrderPage(),
                const MissionPage(),
                const ProfilePage(),
              ],
            ),
          ),
          // Floating Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingBottomBar(
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}