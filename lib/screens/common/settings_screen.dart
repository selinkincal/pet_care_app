// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase kütüphanelerini ekliyoruz
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Bildirim tercihleri
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  // Şifre değiştirme kontrolcüleri
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Firebase örnekleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 1. Ayarları Firestore'dan (veya yerel bellekten) yükleme
  Future<void> _loadSettings() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _pushNotifications = data['pushNotifications'] ?? true;
            _emailNotifications = data['emailNotifications'] ?? false;
          });
        }
      } catch (e) {
        debugPrint('Ayarlar yüklenirken hata: $e');
      }
    }
  }

  // 2. Bildirim ayarlarını Firestore'a kaydetme
  Future<void> _saveNotificationSettings() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).update({
          'pushNotifications': _pushNotifications,
          'emailNotifications': _emailNotifications,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim ayarları başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Bildirim ayarları kaydedilirken hata: $e');
      }
    }
  }

  // 3. Güvenli Şifre Değiştirme (Re-authentication gerektirir)
  Future<void> _changePassword(Function(void Function()) setDialogState) async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni şifreler eşleşmiyor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifre en az 6 karakter olmalı'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setDialogState(() => _isLoadingPasswordChange = true);

    try {
      User? user = _auth.currentUser;
      String email = user?.email ?? '';

      // Güvenlik için kullanıcının eski şifresini doğruluyoruz (Re-authenticate)
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _oldPasswordController.text,
      );
      await user?.reauthenticateWithCredential(credential);

      // Doğrulama başarılıysa yeni şifreyi ayarla
      await user?.updatePassword(_newPasswordController.text);

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) return;
      Navigator.pop(context); // Dialogu kapat

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreniz başarıyla değiştirildi!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Şifre değiştirilemedi.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMsg = 'Eski şifreniz hatalı.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setDialogState(() => _isLoadingPasswordChange = false);
    }
  }

  // 4. Hesabı tamamen silme işlemi
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabımı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz? Tüm verileriniz kalıcı olarak silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Önce veritabanındaki kullanıcı belgesini sil
          await _firestore.collection('users').doc(user.uid).delete();
          // Sonra Auth sisteminden sil
          await user.delete();

          // Cihazdaki yerel verileri temizle
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Güvenlik sebebiyle uzun süredir giriş yapmış kullanıcıların hesap silmeden önce tekrar girmesi istenir
        if (e.code == 'requires-recent-login') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Güvenlik nedeniyle hesabınızı silmek için lütfen çıkış yapıp tekrar giriş yapın.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hesap silinemedi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  bool _isLoadingPasswordChange = false;

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // Dialog içinde durum yönetimi için StatefulBuilder kullanıyoruz
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Şifre Değiştir'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Eski Şifre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Yeni Şifre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Yeni Şifre (Tekrar)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isLoadingPasswordChange
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: _isLoadingPasswordChange
                      ? null
                      : () => _changePassword(setDialogState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: _isLoadingPasswordChange
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kaydet',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // HESAP AYARLARI
            _buildSectionHeader('Hesap Ayarları'),
            _buildListTile(
              Icons.lock_outline,
              'Şifre Değiştir',
              onTap: _showChangePasswordDialog,
            ),
            _buildListTile(
              Icons.delete_forever,
              'Hesabımı Sil',
              isDestructive: true,
              onTap: _deleteAccount,
            ),

            const SizedBox(height: 16),

            // BİLDİRİMLER
            _buildSectionHeader('Bildirimler'),
            _buildSwitchTile(
              Icons.notifications_active_outlined,
              'Anlık Bildirimler',
              'Yeni mesajlar ve randevu güncellemeleri',
              _pushNotifications,
              (val) => setState(() => _pushNotifications = val),
            ),
            _buildSwitchTile(
              Icons.email_outlined,
              'E-posta Bildirimleri',
              'Kampanyalar ve haftalık özetler',
              _emailNotifications,
              (val) => setState(() => _emailNotifications = val),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _saveNotificationSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
                child: const Text(
                  'Bildirim Ayarlarını Kaydet',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // UYGULAMA TERCIHLERI
            _buildSectionHeader('Uygulama Tercihleri'),
            _buildListTile(
              Icons.language,
              'Dil Seçenekleri',
              subtitle: 'Türkçe',
              onTap: () {},
            ),

            const SizedBox(height: 16),

            // YASAL VE DESTEK
            _buildSectionHeader('Yasal ve Destek'),
            _buildListTile(
              Icons.description_outlined,
              'Kullanım Koşulları',
              onTap: () {},
            ),
            _buildListTile(
              Icons.privacy_tip_outlined,
              'Gizlilik Politikası',
              onTap: () {},
            ),
            _buildListTile(
              Icons.info_outline,
              'Uygulama Hakkında',
              subtitle: 'Sürüm 1.0.0',
              onTap: () {},
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title, {
    String? subtitle,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.grey[700],
        ),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.black87),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.grey[700]),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        value: value,
        activeColor: AppTheme.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }
}
