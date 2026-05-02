// owner_create_ad_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OwnerCreateAdScreen extends StatefulWidget {
  const OwnerCreateAdScreen({super.key});

  @override
  State<OwnerCreateAdScreen> createState() => _OwnerCreateAdScreenState();
}

class _OwnerCreateAdScreenState extends State<OwnerCreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // متغيرات لتخزين القيم المختارة
  String? _selectedServiceType;
  String? _selectedPet;

  // قوائم وهمية مؤقتة (Mock Data)
  final List<String> _serviceTypes = ['Köpek Yürüyüşü', 'Evde Bakım', 'Veteriner Ziyareti', 'Eğitim'];
  final List<String> _myPets = ['Max (Köpek)', 'Mia (Kedi)', 'Paşa (Kuş)'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Ver'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hizmet İhtiyacınızı Belirtin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Evcil hayvanınız için ihtiyacınız olan hizmetin detaylarını aşağıya giriniz.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // حقل عنوان الإعلان
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'İlan Başlığı',
                    hintText: 'Örn: Hafta sonu için köpek gezdirici aranıyor',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
                ),
                const SizedBox(height: 16),

                // قائمة اختيار الحيوان الأليف
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Hangi Evcil Hayvanınız İçin?',
                    prefixIcon: Icon(Icons.pets),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedPet,
                  items: _myPets.map((String pet) {
                    return DropdownMenuItem<String>(
                      value: pet,
                      child: Text(pet),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPet = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Lütfen bir evcil hayvan seçin' : null,
                ),
                const SizedBox(height: 16),

                // قائمة اختيار نوع الخدمة
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Hizmet Türü',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedServiceType,
                  items: _serviceTypes.map((String service) {
                    return DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedServiceType = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Lütfen bir hizmet türü seçin' : null,
                ),
                const SizedBox(height: 16),

                // صف للتاريخ والوقت
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          hintText: 'GG/AA/YYYY',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Saat',
                          hintText: '14:30',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // حقل الموقع
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Konum',
                    hintText: 'Örn: Kadıköy, Moda',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // حقل الميزانية المتوقعة
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bütçe (TL)',
                    hintText: 'Örn: 300',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // حقل التفاصيل
                TextFormField(
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detaylar ve Özel İstekler',
                    hintText: 'Köpeğim çok enerjiktir, parkta oyun oynamayı sever...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // زر النشر
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // محاكاة عملية النشر
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('İlanınız başarıyla yayınlandı!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // مسح الحقول بعد النشر الوهمي
                        _formKey.currentState!.reset();
                        setState(() {
                          _selectedPet = null;
                          _selectedServiceType = null;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İlanı Yayınla',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}