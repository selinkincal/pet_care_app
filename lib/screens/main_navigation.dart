// main_navigation.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ---------------- صفحات صاحب الحيوان ----------------
import 'pet_owner_screens/owner_home_screen.dart';
import 'pet_owner_screens/owner_service_list_screen.dart';
import 'pet_owner_screens/owner_create_ad_screen.dart'; // الصفحة الجديدة (İlan Ver)
import 'pet_owner_screens/owner_bookings_screen.dart';

// ---------------- صفحات مقدم الخدمة ----------------
import 'service_provider_screens/provider_home_screen.dart';
import 'service_provider_screens/provider_ads_screen.dart';
import 'service_provider_screens/provider_bookings_screen.dart';
import 'service_provider_screens/provider_earnings_screen.dart';

// ---------------- صفحة مشتركة ----------------
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String userRole; // 'pet_owner' أو 'service_provider'

  // الافتراضي هو pet_owner لتسهيل الاختبار حالياً
  const MainNavigation({super.key, this.userRole = 'service_provider'});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // 1. تحديد الصفحات بناءً على الدور
  // 1. تحديد الصفحات بناءً على الدور
  List<Widget> get _pages {
    if (widget.userRole == 'service_provider') {
      return const [
        ProviderHomeScreen(),      // Ana Sayfa (خاصة بمقدم الخدمة)
        ProviderAdsScreen(),       // İlanlar
        ProviderBookingsScreen(),  // Randevular (خاصة بمقدم الخدمة)
        ProviderEarningsScreen(),  // Kazançlarım
        ProfileScreen(),           // Profil
      ];
    } else {
      return const [
        OwnerHomeScreen(),         // <-- تم التعديل (بدلاً من HomeScreen)
        OwnerServiceListScreen(),  // <-- تم التعديل (بدلاً من ServiceListScreen)
        OwnerCreateAdScreen(),     // İlan Ver
        OwnerBookingsScreen(),     // <-- تم التعديل (بدلاً من MyBookingsScreen)
        ProfileScreen(),           // Profil
      ];
    }
  }

  // 2. تحديد أزرار الشريط السفلي بناءً على الدور
  List<BottomNavigationBarItem> get _navItems {
    if (widget.userRole == 'service_provider') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'İlanlar'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Randevular'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Kazançlar'), // <-- الزر الجديد
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Hizmetler'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'İlan Ver'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Randevular'),
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