// provider_bank_account_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({super.key});

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // متحكمات الحقول
  final _ibanController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBankDetails();
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  // جلب البيانات المحفوظة
  Future<void> _loadBankDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ibanController.text = prefs.getString('userIban') ?? '';
      _bankNameController.text = prefs.getString('userBankName') ?? '';
      _accountHolderController.text = prefs.getString('userAccountHolder') ?? '';
    });
  }

  // حفظ البيانات
  Future<void> _saveBankDetails() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userIban', _ibanController.text);
      await prefs.setString('userBankName', _bankNameController.text);
      await prefs.setString('userAccountHolder', _accountHolderController.text);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banka bilgileriniz başarıyla kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Banka Hesap Bilgileri'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة تنبيهية
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kazançlarınızı çekebilmek için banka hesabınızın sizin adınıza olması gerekmektedir.',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Para Çekilecek Hesap',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // حقل اسم صاحب الحساب
              TextFormField(
                controller: _accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Hesap Sahibinin Adı Soyadı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),

              // حقل اسم البنك
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Banka Adı',
                  hintText: 'Örn: Ziraat Bankası, Garanti vb.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),

              // حقل الـ IBAN
              TextFormField(
                controller: _ibanController,
                keyboardType: TextInputType.text,
                maxLength: 26,
                decoration: const InputDecoration(
                  labelText: 'IBAN',
                  hintText: 'TR00 0000 0000 0000 0000 0000 00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'IBAN giriniz';
                  if (!value.toUpperCase().startsWith('TR')) return 'IBAN TR ile başlamalıdır';
                  if (value.length < 24) return 'Geçerli bir IBAN giriniz';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveBankDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Bilgileri Kaydet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}