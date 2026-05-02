// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _registeredRole = '';
  String _activeRole = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // جلب بيانات المستخدم من الذاكرة المحلية
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _registeredRole = prefs.getString('registeredRole') ?? 'pet_owner';
      _activeRole = prefs.getString('userRole') ?? 'pet_owner'; // الدور النشط حالياً
      _userEmail = prefs.getString('userEmail') ?? 'kullanici@email.com';
    });
  }

  // دالة التبديل بين الحسابين
  Future<void> _switchAccountMode() async {
    final prefs = await SharedPreferences.getInstance();
    // عكس الدور النشط
    String newActiveRole = _activeRole == 'pet_owner' ? 'service_provider' : 'pet_owner';
    
    // حفظ الدور النشط الجديد
    await prefs.setString('userRole', newActiveRole);

    if (!mounted) return;

    // إعادة تحميل الصفحة الرئيسية بالدور الجديد
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavigation(userRole: newActiveRole),
      ),
    );
  }

  // دالة تسجيل الخروج
  Future<void> _handleLogout() async {
    // يمكننا هنا مسح الدور النشط أو إبقاء البيانات حسب الرغبة
    // للمحاكاة، سنكتفي بالانتقال لشاشة تسجيل الدخول
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // تحديد هل هو في وضع مقدم الخدمة حالياً؟
    bool isProviderMode = _activeRole == 'service_provider';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Profilim'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات المستخدم الأساسية
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.lightGreen,
              child: Icon(
                isProviderMode ? Icons.work : Icons.pets, 
                size: 50, 
                color: AppTheme.primaryGreen
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ahmet Yılmaz', // اسم وهمي مؤقت
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _userEmail,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            
            // وسم يوضح الوضع الحالي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isProviderMode ? 'Hizmet Veren Modu' : 'Evcil Hayvan Sahibi Modu',
                style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 32),

            // زر التبديل يظهر فقط لمن سجل كـ "İkisi de" (both)
            if (_registeredRole == 'both') ...[
              Container(
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
                    isProviderMode ? 'Evcil Hayvan Sahibi Moduna Geç' : 'Hizmet Veren Moduna Geç',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Diğer hesabınıza geçiş yapın',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Divider(),

            // قوائم الإعدادات (تتغير حسب الدور)
            if (!isProviderMode) ...[
              _buildMenuItem(Icons.pets, 'Evcil Hayvanlarım'),
              _buildMenuItem(Icons.favorite_border, 'Favori Hizmet Verenler'),
            ] else ...[
              _buildMenuItem(Icons.work_history, 'Deneyim ve Yeteneklerim'),
              _buildMenuItem(Icons.account_balance, 'Banka Hesap Bilgileri'),
            ],

            _buildMenuItem(Icons.person_outline, 'Kişisel Bilgiler'),
            _buildMenuItem(Icons.settings, 'Ayarlar'),
            _buildMenuItem(Icons.help_outline, 'Yardım ve Destek'),
            
            const Divider(),
            
            // زر تسجيل الخروج
            _buildMenuItem(
              Icons.logout, 
              'Çıkış Yap', 
              isLogout: true,
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء عناصر القائمة
  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withValues(alpha: 0.1) : AppTheme.lightGreen,
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
      trailing: isLogout ? null : const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap ?? () {
        // سيتم ربط الصفحات لاحقاً
      },
    );
  }
}