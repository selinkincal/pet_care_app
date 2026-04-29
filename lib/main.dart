import 'package:flutter/material.dart';
import 'package:pet_care_app/theme/app_theme.dart';
import 'package:pet_care_app/screens/home_screen.dart';
import 'package:pet_care_app/screens/service_list_screen.dart';
import 'package:pet_care_app/screens/service_detail_screen.dart';
import 'package:pet_care_app/screens/my_bookings_screen.dart';
import 'package:pet_care_app/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care Marketplace',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const ServiceListScreen(),
    const ServiceDetailScreen(),
    const MyBookingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Hizmetler'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Detay'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Randevular',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
