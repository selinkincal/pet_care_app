// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase kütüphanelerini ekliyoruz
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Firebase örnekleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Kullanıcı verilerini yükleme işlemi (Önce yerel bellekten, sonra Firestore'dan güncelleyerek)
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Arayüzün hızlı yüklenmesi için önce SharedPreferences'ten verileri alıyoruz
    setState(() {
      _registeredRole = prefs.getString('registeredRole') ?? 'pet_owner';
      _activeRole = prefs.getString('userRole') ?? 'pet_owner';
      _userEmail = prefs.getString('userEmail') ?? 'kullanici@email.com';
      _userName = prefs.getString('userName') ?? 'Kullanıcı Adı';
    });

    // 2. Arka planda Firestore'dan en güncel bilgileri çekiyoruz (Örn: EditProfile sayfasında isim değişmişse günceller)
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _registeredRole = data['registeredRole'] ?? _registeredRole;
            _activeRole = data['activeRole'] ?? _activeRole;
            _userName = data['name'] ?? _userName;
            _userEmail =
                _auth.currentUser?.email ??
                _userEmail; // E-postayı Auth'tan almak daha güvenli
          });

          // Yerel belleği en yeni bilgilerle güncelle
          await prefs.setString('registeredRole', _registeredRole);
          await prefs.setString('userRole', _activeRole);
          await prefs.setString('userName', _userName);
          await prefs.setString('userEmail', _userEmail);
        }
      }
    } catch (e) {
      debugPrint('Profil güncellenirken hata: $e');
    }
  }

  // Hesap modunu değiştirme (Hem yerel hem veritabanı üzerinde)
  Future<void> _switchAccountMode() async {
    String newActiveRole = _activeRole == 'pet_owner'
        ? 'service_provider'
        : 'pet_owner';

    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        // Yeni aktif rolü Firestore'a kaydet ki kullanıcı başka cihazdan girerse aynı rolde başlasın
        await _firestore.collection('users').doc(uid).update({
          'activeRole': newActiveRole,
        });
      }
    } catch (e) {
      debugPrint('Rol değiştirme hatası: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', newActiveRole);

    if (!mounted) return;

    // Yeni rolle ana sayfaya yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(userRole: newActiveRole),
      ),
    );
  }

  // Gerçek ve güvenli çıkış yapma işlemi (Firebase Logout)
  Future<void> _handleLogout() async {
    try {
      // 1. Firebase Authentication'dan çıkış yap
      await _auth.signOut();

      // 2. Güvenlik için yerel cihazdaki tüm kayıtlı verileri temizle
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Çıkış yaparken hata: $e');
    }

    if (!mounted) return;

    // 3. Kullanıcıyı Giriş Ekranına yönlendir
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

            // Sadece 'both' (İkisi de) olarak kayıt olanlarda hesap değiştirme butonu görünür
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
              // Hizmet Veren menüleri
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

            // Çıkış Yap Butonu
            _buildMenuItem(
              Icons.logout,
              'Çıkış Yap',
              _handleLogout, // Güvenli çıkış fonksiyonuna bağlandı
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  // Hesap modunu değiştirme butonu
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

  // Menü öğeleri tasarımı
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
