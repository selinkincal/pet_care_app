// provider_experience_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class ProviderExperienceScreen extends StatefulWidget {
  const ProviderExperienceScreen({super.key});

  @override
  State<ProviderExperienceScreen> createState() => _ProviderExperienceScreenState();
}

class _ProviderExperienceScreenState extends State<ProviderExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _bioController = TextEditingController();
  final _certificationsController = TextEditingController();
  String _selectedExperience = '1-3 Yıl';

  // قائمة المهارات المتاحة
  final List<String> _availableSkills = [
    'İlk Yardım',
    'İlaç Verebilme',
    'Büyük Irk Köpekler',
    'Yavru Hayvan Bakımı',
    'Eğitim/İtaat',
    'Özel Diyet Hazırlama',
    'Yaşlı Hayvan Bakımı'
  ];

  // المهارات التي اختارها المستخدم
  final Set<String> _selectedSkills = {};

  final List<String> _experienceYears = [
    '1 Yıldan az',
    '1-3 Yıl',
    '3-5 Yıl',
    '5+ Yıl',
    '10+ Yıl'
  ];

  @override
  void initState() {
    super.initState();
    _loadExperienceData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _certificationsController.dispose();
    super.dispose();
  }

  // محاكاة جلب البيانات المحفوظة
  Future<void> _loadExperienceData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bioController.text = prefs.getString('providerBio') ?? '';
      _selectedExperience = prefs.getString('providerExpYears') ?? '1-3 Yıl';
      _certificationsController.text = prefs.getString('providerCerts') ?? '';
      
      List<String>? savedSkills = prefs.getStringList('providerSkills');
      if (savedSkills != null) {
        _selectedSkills.addAll(savedSkills);
      }
    });
  }

  // حفظ البيانات
  Future<void> _saveExperienceData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('providerBio', _bioController.text);
      await prefs.setString('providerExpYears', _selectedExperience);
      await prefs.setString('providerCerts', _certificationsController.text);
      await prefs.setStringList('providerSkills', _selectedSkills.toList());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deneyim ve yetenekleriniz güncellendi!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Deneyim ve Yeteneklerim'),
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
              // 1. نبذة عني
              const Text(
                'Hakkımda',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Müşterilerinize kendinizden ve hayvanlara olan sevginizden bahsedin...',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'Lütfen kendinizi kısaca tanıtın' : null,
              ),
              const SizedBox(height: 24),

              // 2. سنوات الخبرة
              const Text(
                'Deneyim Süresi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedExperience,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.work_history_outlined),
                ),
                items: _experienceYears.map((year) {
                  return DropdownMenuItem(value: year, child: Text(year));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedExperience = value!);
                },
              ),
              const SizedBox(height: 24),

              // 3. المهارات الخاصة (Chips)
              const Text(
                'Özel Yetenekler (Birden fazla seçebilirsiniz)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                    selectedColor: AppTheme.lightGreen,
                    checkmarkColor: AppTheme.primaryGreen,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 4. الشهادات
              const Text(
                'Sertifikalar ve Eğitimler (İsteğe Bağlı)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _certificationsController,
                decoration: const InputDecoration(
                  hintText: 'Örn: Veteriner Teknikeri, İleri Düzey Köpek Eğitmeni',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.card_membership),
                ),
              ),
              const SizedBox(height: 40),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveExperienceData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kaydet ve Güncelle',
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