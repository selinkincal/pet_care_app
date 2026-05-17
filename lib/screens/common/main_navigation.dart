// main_navigation.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ---------------- صفحات صاحب الحيوان ----------------
import '../pet_owner_screens/owner_home_screen.dart';
import '../pet_owner_screens/owner_service_list_screen.dart';
import '../pet_owner_screens/owner_my_ads_screen.dart';
import '../pet_owner_screens/owner_bookings_screen.dart';

// ---------------- صفحات مقدم الخدمة ----------------
import '../service_provider_screens/provider_home_screen.dart';
import '../service_provider_screens/provider_ads_screen.dart';
import '../service_provider_screens/provider_bookings_screen.dart';
import '../service_provider_screens/provider_my_services_screen.dart'; 

// ---------------- صفحة مشتركة ----------------
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userRole;
  const MainNavigation({super.key, this.userRole = 'service_provider'});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  List<Widget> get _pages {
    if (widget.userRole == 'service_provider') {
      return [
        const ProviderHomeScreen(),
        const ProviderAdsScreen(),
        const ProviderMyServicesScreen(), 
        const ProviderBookingsScreen(),
        const ProfileScreen(),
      ];
    } else {
      return [
        const OwnerHomeScreen(),
        const OwnerServiceListScreen(),
        const OwnerMyAdsScreen(),
        const OwnerBookingsScreen(),
        const ProfileScreen(),
      ];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    if (widget.userRole == 'service_provider') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'İlanlar'),
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Hizmetlerim',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Hizmetler'),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          label: 'İlanlarım',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Randevular',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}
