import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profil resmi
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.lightGreen,
              child: Icon(Icons.person, size: 50, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kullanıcı Adı',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'kullanici@email.com',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Divider(),
            // Menü öğeleri
            _buildMenuItem(Icons.person_outline, 'Hesap Bilgilerim'),
            _buildMenuItem(Icons.history, 'Randevu Geçmişi'),
            _buildMenuItem(Icons.favorite_border, 'Favori Hizmetler'),
            _buildMenuItem(Icons.settings, 'Ayarlar'),
            const Divider(),
            _buildMenuItem(Icons.logout, 'Çıkış Yap', isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : AppTheme.primaryGreen),
      title: Text(
        title,
        style: TextStyle(color: isLogout ? Colors.red : Colors.black),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        if (isLogout) {
          // Çıkış işlemi sonra gelecek
        }
      },
    );
  }
}
