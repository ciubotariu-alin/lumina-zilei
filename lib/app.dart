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
  // Cache lazy — ecranele sunt create doar la prima vizită
  final Map<int, Widget> _builtScreens = {};

  int get _screenCount =>
      4 + (FeatureFlags.donationsEnabled ? 1 : 0);

  Widget _getScreen(int index) {
    return _builtScreens.putIfAbsent(index, () => _createScreen(index));
  }

  Widget _createScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(onNavigate: _onItemTapped);
      case 1:
        return const CalendarScreen();
      case 2:
        return const PrayersScreen();
      case 3:
        return const BibleScreen();
      case 4:
        return FeatureFlags.donationsEnabled
            ? const DonationsScreen()
            : const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    // Creează ecranul de start (index 0) imediat
    _builtScreens[0] = _createScreen(0);
  }

  void _onItemTapped(int index) {
    _getScreen(index); // instanțiază și cachează înainte de rebuild
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_screenCount, (i) {
          if (!_builtScreens.containsKey(i)) return const SizedBox.shrink();
          return _builtScreens[i]!;
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
