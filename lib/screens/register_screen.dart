//register_screen.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';
import 'login_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // مفاتيح النماذج (استخدمنا مفتاحين منفصلين لعدم تداخل التقييم Validation)
  final _formKey = GlobalKey<FormState>();
  final _extraFormKey = GlobalKey<FormState>();

  // متحكمات الخطوة 1 (المعلومات الشخصية)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // متحكمات الخطوة 2 (معلومات الحيوان)
  final _petNameController = TextEditingController();
  final _petTypeController = TextEditingController(); // كقطة، كلب، إلخ
  final _petAgeController = TextEditingController();

  // متحكمات الخطوة 2 (معلومات مقدم الخدمة)
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedRole; // 'pet_owner', 'service_provider', 'both'
  int _currentStep = 0; // 0: Rol, 1: Bilgiler, 2: Detaylar

  bool _obscurePassword = true;

  @override
  void dispose() {
    // إغلاق جميع المتحكمات لتوفير الذاكرة
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _petNameController.dispose();
    _petTypeController.dispose();
    _petAgeController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir rol seçin')),
      );
      return;
    }
    setState(() {
      _currentStep = 1;
    });
  }

  void _handleRegister() async {
    if (_extraFormKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      
      // حفظ الدور الأصلي الذي اختاره (pet_owner, service_provider, أو both)
      await prefs.setString('registeredRole', _selectedRole!);
      
      // تحديد الواجهة الافتراضية التي سيبدأ بها
      String activeRole = _selectedRole == 'service_provider' ? 'service_provider' : 'pet_owner';
      
      // حفظ الدور النشط
      await prefs.setString('userRole', activeRole);
      
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setString('userPassword', _passwordController.text);

      if (!mounted) return;
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // التعديل هنا: استخدام activeRole بدلاً من roleToSave
          builder: (context) => MainNavigation(userRole: activeRole), 
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/background_pets.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.85),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Başlık
                const Icon(Icons.pets, size: 60, color: AppTheme.primaryGreen),
                const SizedBox(height: 10),
                const Text(
                  'EVCİL HAYVAN UYGULAMASI',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Step göstergesi (Şimdi 3 Adım)
                Row(
                  children: [
                    _buildStepCircle(0, 'Rol'),
                    Expanded(child: _buildStepLine(0)),
                    _buildStepCircle(1, 'Bilgiler'),
                    Expanded(child: _buildStepLine(1)),
                    _buildStepCircle(2, 'Detaylar'),
                  ],
                ),
                const SizedBox(height: 30),

                // Step içeriği
                Expanded(
                  child: _currentStep == 0
                      ? _buildRoleSelection()
                      : _currentStep == 1
                          ? _buildInfoForm()
                          : _buildExtraInfoForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isActive || isCompleted)
                ? AppTheme.primaryGreen
                : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: (isActive || isCompleted)
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppTheme.primaryGreen : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int stepIndex) {
    return Container(
      height: 2,
      color: _currentStep > stepIndex ? AppTheme.primaryGreen : Colors.grey[300],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildRoleCard(
          'pet_owner',
          '🐾',
          'Evcil Hayvan Sahibi',
          'Hizmet almak istiyorum',
          'Köpeğim, kedim için bakım arıyorum',
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          'service_provider',
          '🐕‍🦺',
          'Hizmet Veren',
          'Hizmet vermek istiyorum',
          'Evcil hayvan bakımı, gezdirme vb. hizmet veriyorum',
        ),
        const SizedBox(height: 16),
        _buildRoleCard(
          'both',
          '🫂',
          'İkisi de',
          'Hem hizmet alıp hem veriyorum',
          'Bazen bakım arıyor, bazen hizmet veriyorum',
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Devam Et',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    String role,
    String emoji,
    String title,
    String subtitle,
    String description,
  ) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ad soyad giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'E-posta giriniz';
                }
                if (!value.contains('@')) {
                  return 'E-posta adresinde "@" işareti bulunmalıdır';
                }
                if (!value.contains('.') ||
                    value.indexOf('@') + 2 > value.lastIndexOf('.')) {
                  return 'Geçerli bir e-posta adresi giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Şifre giriniz';
                }
                if (value.length < 6) {
                  return 'Şifre en az 6 karakter olmalı';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Geri',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _currentStep = 2; // الانتقال للخطوة الثالثة الجديدة
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Devam Et',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Zaten hesabınız var mı?'),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // الواجهة الجديدة للخطوة الثالثة
  Widget _buildExtraInfoForm() {
    return Form(
      key: _extraFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقول مالك الحيوان
            if (_selectedRole == 'pet_owner' || _selectedRole == 'both') ...[
              const Text(
                'Evcil Hayvan Bilgileri',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _petNameController,
                decoration: const InputDecoration(
                  labelText: 'Evcil Hayvan Adı',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Gerekli alan' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _petTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Türü (Kedi, Köpek vs.)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _petAgeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Yaşı',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (_selectedRole == 'both') const SizedBox(height: 24),

            // حقول مقدم الخدمة
            if (_selectedRole == 'service_provider' || _selectedRole == 'both') ...[
              const Text(
                'Hizmet Veren Detayları',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deneyim (Yıl)',
                  prefixIcon: Icon(Icons.work_history),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Gerekli alan' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Kendinizi ve yeteneklerinizi tanıtın',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // أزرار الرجوع والتسجيل النهائي
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1; // الرجوع للخطوة السابقة
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Geri',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleRegister, // دالة التسجيل والانتقال
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}