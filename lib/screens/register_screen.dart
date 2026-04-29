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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole; // 'pet_owner', 'service_provider', 'both'
  int _currentStep = 0; // 0: Rol seçimi, 1: Bilgiler

  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir rol seçin')));
      return;
    }
    setState(() {
      _currentStep = 1;
    });
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Firebase'siz: ana sayfaya git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
              'assets/background_pets.png',
            ), // Arkaplan resmi (sonra ekleyeceğiz)
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
                ),
                const SizedBox(height: 20),

                // Step göstergesi
                Row(
                  children: [
                    _buildStepCircle(0, 'Rol Seçimi'),
                    Expanded(child: _buildStepLine()),
                    _buildStepCircle(1, 'Bilgilerin'),
                  ],
                ),
                const SizedBox(height: 30),

                // Step içeriği
                Expanded(
                  child: _currentStep == 0
                      ? _buildRoleSelection()
                      : _buildInfoForm(),
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

  Widget _buildStepLine() {
    return Container(
      height: 2,
      color: _currentStep > 0 ? AppTheme.primaryGreen : Colors.grey[300],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Rol seçim kartları
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
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
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
                    side: BorderSide(color: AppTheme.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Geri',
                    style: TextStyle(color: AppTheme.primaryGreen),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleRegister,
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
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(color: AppTheme.primaryGreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
