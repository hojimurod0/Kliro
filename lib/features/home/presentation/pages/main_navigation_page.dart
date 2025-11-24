import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../widgets/main_bottom_navigation.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'services_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

@RoutePage(name: 'HomeRoute')
class MainNavigationPage extends StatefulWidget {
  final TabItem initialTab;

  const MainNavigationPage({
    super.key,
    this.initialTab = TabItem.home,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late TabItem _currentTab;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _pages = [
      HomePage(
        onTabChange: _handleTabChange,
      ),
      const ServicesPage(),
      const FavoritesPage(),
      const ProfilePage(),
    ];
  }

  void _handleTabChange(TabItem tab) {
    if (_currentTab == tab) return;
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab.index,
        children: _pages,
      ),
      bottomNavigationBar: MainBottomNavigation(
        currentTab: _currentTab,
        onTabChanged: _handleTabChange,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

