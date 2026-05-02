// provider_ads_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProviderAdsScreen extends StatelessWidget {
  const ProviderAdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية مؤقتة للإعلانات
    final List<Map<String, String>> mockAds = [
      {
        'title': 'Hafta sonu için köpek gezdirici',
        'pet': 'Max (Golden Retriever)',
        'location': 'Kadıköy, Moda',
        'date': '9 Mayıs 2026',
        'time': '10:00 - 11:30',
        'budget': '350 TL',
        'status': 'Acil',
      },
      {
        'title': '3 günlük tatil için kedi bakımı',
        'pet': 'Mia (Tekir)',
        'location': 'Beşiktaş, Merkez',
        'date': '12 - 15 Mayıs 2026',
        'time': 'Günde 1 saat',
        'budget': '1200 TL',
        'status': 'Yeni',
      },
      {
        'title': 'Veteriner ziyareti için refakatçi',
        'pet': 'Paşa (Papağan)',
        'location': 'Üsküdar',
        'date': '10 Mayıs 2026',
        'time': '14:00 - 16:00',
        'budget': '400 TL',
        'status': 'Normal',
      },
      {
        'title': 'Enerjik köpeğim için günlük koşu arkadaşı',
        'pet': 'Rex (Husky)',
        'location': 'Maltepe Sahil',
        'date': 'Her Sabah',
        'time': '07:00 - 08:00',
        'budget': 'Aylık 4000 TL',
        'status': 'Yeni',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Müşteri İlanları'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // سيتم إضافة الفلاتر لاحقاً
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث المدمج
          Container(
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Bölge veya hizmet türü ara...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // قائمة الإعلانات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockAds.length,
              itemBuilder: (context, index) {
                return _buildAdCard(context, mockAds[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء بطاقة الإعلان
  Widget _buildAdCard(BuildContext context, Map<String, String> ad) {
    // تحديد لون الوسم بناءً على الحالة
    Color badgeColor;
    if (ad['status'] == 'Acil') {
      badgeColor = Colors.red;
    } else if (ad['status'] == 'Yeni') {
      badgeColor = Colors.green;
    } else {
      badgeColor = Colors.blueGrey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان والوسم
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ad['title']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    ad['status']!,
                    style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // تفاصيل الحيوان والموقع
            Row(
              children: [
                const Icon(Icons.pets, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(ad['pet']!, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(ad['location']!, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            
            // تفاصيل الزمان
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(ad['date']!, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(ad['time']!, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // السعر وزر التقديم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bütçe', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      ad['budget']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // محاكاة إرسال طلب على الإعلان
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('İlana başarıyla başvurdunuz!'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Başvur', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}