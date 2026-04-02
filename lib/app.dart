import 'package:flutter/material.dart';

import 'config/feature_flags.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/prayers_screen.dart';
import 'screens/bible_screen.dart';
import 'screens/donations_screen.dart';

class OrtodoxApp extends StatelessWidget {
  const OrtodoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumina Zilei',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  // Screen-urile vizitate — indexul 0 e activ de la start
  final Set<int> _visitedScreens = {0};
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onNavigate: _onItemTapped),
      const CalendarScreen(),
      const PrayersScreen(),
      const BibleScreen(),
      if (FeatureFlags.donationsEnabled) const DonationsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _visitedScreens.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_screens.length, (i) {
          if (!_visitedScreens.contains(i)) return const SizedBox.shrink();
          return _screens[i];
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.goldColor,
        unselectedItemColor: AppTheme.creamColor.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Acasă',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Rugăciuni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            activeIcon: Icon(Icons.auto_stories),
            label: 'Biblie',
          ),
          if (FeatureFlags.donationsEnabled)
            const BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism_outlined),
              activeIcon: Icon(Icons.volunteer_activism),
              label: 'Donații',
            ),
        ],
      ),
    );
  }
}
