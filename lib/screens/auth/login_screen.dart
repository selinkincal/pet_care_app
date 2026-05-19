// login_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase kütüphanelerini ekliyoruz (Giriş ve veri çekme işlemleri için)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import 'register_screen.dart';
import '../common/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  // Yüklenme durumunu kontrol etmek için değişken (Butona basıldığında dönecek animasyon için)
  bool _isLoading = false;

  // Firebase Giriş İşlemi
  void _handleLogin() async {
    // 1. Formdaki e-posta ve şifrenin geçerli olup olmadığını kontrol et
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Yüklenme animasyonunu başlat
      });

      try {
        // 2. Firebase Authentication ile giriş yapmayı dene
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // Giriş yapan kullanıcının benzersiz kimliğini (UID) al
        String uid = userCredential.user!.uid;

        // 3. Firestore'dan kullanıcının kayıtlı bilgilerini (Rolü, Adı vb.) çek
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        String activeRole = 'pet_owner'; // Varsayılan rol
        String userName = 'Kullanıcı';

        // Eğer kullanıcı veritabanında bulunursa bilgileri güncelle
        if (userDoc.exists) {
          activeRole = userDoc.get('activeRole') ?? 'pet_owner';
          userName = userDoc.get('name') ?? 'Kullanıcı';
        }

        // 4. Uygulamanın diğer sayfalarında hızlı erişim için bilgileri SharedPreferences'a kaydet
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userEmail', _emailController.text.trim());
        await prefs.setString('userRole', activeRole);
        await prefs.setString('userName', userName);

        if (!mounted) return;

        // 5. Giriş başarılı! Kullanıcıyı kendi rolüne uygun ana sayfaya yönlendir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigation(userRole: activeRole),
          ),
        );
      } on FirebaseAuthException catch (e) {
        // Firebase'den gelen giriş hatalarını yakala ve kullanıcı dostu mesajlar göster
        String errorMessage = 'Giriş başarısız oldu.';

        // Yeni Firebase sürümlerinde genellikle 'invalid-credential' hatası döner
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMessage = 'E-posta adresiniz veya şifreniz hatalı.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Geçersiz bir e-posta adresi formatı.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      } catch (e) {
        // Beklenmeyen diğer hatalar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // İşlem bittiğinde (başarılı veya başarısız) yüklenme animasyonunu durdur
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.pets, size: 80, color: AppTheme.primaryGreen),
                const SizedBox(height: 20),
                const Text(
                  'Pet Care Marketplace',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // E-posta alanı
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'E-posta giriniz';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Geçerli bir e-posta adresi giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre alanı
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Giriş Yap Butonu
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    // Yüklenme sırasındaysa butonu tıklanmaz yap
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Yükleniyorsa dönen animasyon göster, yoksa metni göster
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kayıt sayfasına yönlendirme metni
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabınız yok mu?'),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
