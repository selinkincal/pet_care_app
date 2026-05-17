// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import 'main_navigation.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import '../pet_owner_screens/owner_my_pets_screen.dart';
import '../pet_owner_screens/owner_my_favorites_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import '../service_provider_screens/provider_bank_account_screen.dart';
import '../service_provider_screens/provider_experience_screen.dart';
import '../service_provider_screens/provider_earnings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _registeredRole = '';
  String _activeRole = '';
  String _userEmail = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _registeredRole = prefs.getString('registeredRole') ?? 'pet_owner';
      _activeRole = prefs.getString('userRole') ?? 'pet_owner';
      _userEmail = prefs.getString('userEmail') ?? 'kullanici@email.com';
      _userName = prefs.getString('userName') ?? 'Kullanıcı Adı';
    });
  }

  Future<void> _switchAccountMode() async {
    final prefs = await SharedPreferences.getInstance();
    String newActiveRole = _activeRole == 'pet_owner'
        ? 'service_provider'
        : 'pet_owner';
    await prefs.setString('userRole', newActiveRole);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(userRole: newActiveRole),
      ),
    );
  }

  Future<void> _handleLogout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isProviderMode = _activeRole == 'service_provider';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Hesabım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.lightGreen,
              child: Icon(
                isProviderMode ? Icons.work : Icons.pets,
                size: 50,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _userEmail,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isProviderMode
                    ? 'Hizmet Veren Modu'
                    : 'Evcil Hayvan Sahibi Modu',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),

            if (_registeredRole == 'both') ...[
              _buildSwitchButton(isProviderMode),
              const SizedBox(height: 24),
            ],

            const Divider(),

            // Evcil Hayvan Sahibi menüleri
            if (!isProviderMode) ...[
              _buildMenuItem(Icons.pets, 'Evcil Hayvanlarım', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const MyPetsScreen()),
                );
              }),
              _buildMenuItem(Icons.favorite_border, 'Beğendiklerim', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const MyFavoritesScreen()),
                );
              }),
            ] else ...[
              _buildMenuItem(Icons.work_history, 'Deneyim ve Yeteneklerim', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProviderExperienceScreen(),
                  ),
                );
              }),

              _buildMenuItem(
                Icons.account_balance,
                'Banka Hesap Bilgileri',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const BankAccountScreen(),
                    ),
                  );
                },
              ),
              // Profil menüsüne ekle
              _buildMenuItem(Icons.account_balance_wallet, 'Kazançlarım', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => const ProviderEarningsScreen(),
                  ),
                );
              }),
            ],

            // Ortak menüler
            _buildMenuItem(Icons.person_outline, 'Kişisel Bilgilerim', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const EditProfileScreen()),
              );
            }),
            _buildMenuItem(Icons.settings, 'Ayarlar', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const SettingsScreen()),
              );
            }),
            _buildMenuItem(Icons.help_outline, 'Yardım ve Destek', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const HelpScreen()),
              );
            }),

            const Divider(),

            _buildMenuItem(
              Icons.logout,
              'Çıkış Yap',
              _handleLogout,
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchButton(bool isProviderMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: _switchAccountMode,
        leading: const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
        title: Text(
          isProviderMode
              ? 'Evcil Hayvan Sahibi Moduna Geç'
              : 'Hizmet Veren Moduna Geç',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Diğer hesabınıza geçiş yapın',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.red.withValues(alpha: 0.1)
              : AppTheme.lightGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isLogout ? Colors.red : AppTheme.primaryGreen),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black87,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
