import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../widgets/main_bottom_navigation.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'services_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

@RoutePage(name: 'HomeRoute')
class MainNavigationPage extends StatefulWidget {
  final TabItem initialTab;

  const MainNavigationPage({super.key, this.initialTab = TabItem.home});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late TabItem _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  List<Widget> _buildPages(BuildContext context) {
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    final locale = context.locale;
    return [
      HomePage(
        key: ValueKey('home_${locale.toString()}'),
        onTabChange: _handleTabChange,
      ),
      ServicesPage(key: ValueKey('services_${locale.toString()}')),
      FavoritesPage(key: ValueKey('favorites_${locale.toString()}')),
      ProfilePage(key: ValueKey('profile_${locale.toString()}')),
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
    // Locale o'zgarishini kuzatish uchun context.locale ni ishlatamiz
    final locale = context.locale;
    return Scaffold(
      body: IndexedStack(
        key: ValueKey('indexed_stack_${locale.toString()}'),
        index: _currentTab.index,
        children: _buildPages(context),
      ),
      bottomNavigationBar: MainBottomNavigation(
        key: ValueKey('bottom_nav_${locale.toString()}'),
        currentTab: _currentTab,
        onTabChanged: _handleTabChange,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
