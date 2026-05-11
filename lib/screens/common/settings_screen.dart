// settings_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // متغيرات وهمية لحالة أزرار التفعيل (Switches)
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkMode = false;

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
            
            // 1. Hesap Ayarları (إعدادات الحساب)
            _buildSectionHeader('Hesap Ayarları'),
            _buildListTile(Icons.lock_outline, 'Şifre Değiştir', onTap: () {}),
            _buildListTile(Icons.security, 'İki Adımlı Doğrulama', onTap: () {}),
            _buildListTile(
              Icons.delete_forever, 
              'Hesabımı Sil', 
              isDestructive: true, 
              onTap: () {
                _showDeleteAccountDialog(context);
              }
            ),

            const SizedBox(height: 16),

            // 2. Bildirimler (الإشعارات)
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

            const SizedBox(height: 16),

            // 3. Uygulama Tercihleri (تفضيلات التطبيق)
            _buildSectionHeader('Uygulama Tercihleri'),
            _buildListTile(Icons.language, 'Dil Seçenekleri', subtitle: 'Türkçe', onTap: () {}),
            _buildSwitchTile(
              Icons.dark_mode_outlined, 
              'Karanlık Mod', 
              'Göz yorgunluğunu azaltın',
              _darkMode,
              (val) => setState(() => _darkMode = val),
            ),

            const SizedBox(height: 16),

            // 4. Yasal ve Destek (القانونية والدعم)
            _buildSectionHeader('Yasal ve Destek'),
            _buildListTile(Icons.description_outlined, 'Kullanım Koşulları', onTap: () {}),
            _buildListTile(Icons.privacy_tip_outlined, 'Gizlilik Politikası', onTap: () {}),
            _buildListTile(Icons.help_outline, 'Yardım Merkezi', onTap: () {}),
            _buildListTile(Icons.info_outline, 'Uygulama Hakkında', subtitle: 'Sürüm 1.0.0', onTap: () {}),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لعنوان كل قسم
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  // دالة مساعدة للأزرار العادية
  Widget _buildListTile(IconData icon, String title, {String? subtitle, bool isDestructive = false, VoidCallback? onTap}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.black87),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // دالة مساعدة لأزرار التفعيل (Switches)
  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.grey[700]),
        title: Text(title, style: const TextStyle(color: Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        value: value,
        activeColor: AppTheme.primaryGreen,
        onChanged: onChanged,
      ),
    );
  }

  // نافذة تأكيد حذف الحساب (تصميم احترافي للأمان)
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Hesabı Sil', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz kalıcı olarak silinir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // إجراء الحذف وتسجيل الخروج لاحقاً
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Evet, Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}