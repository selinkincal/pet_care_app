// provider_home_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // لون خلفية هادئ لإبراز البطاقات
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              // سيتم برمجة صفحة الإشعارات لاحقاً
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الترحيب
            const Text(
              'Merhaba, Ahmet 👋', // اسم وهمي مؤقت
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Bugün harika bir gün! İşte işlerinin özeti:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // قسم الإحصائيات السريعة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Tamamlanan', '42', Icons.check_circle, Colors.blue),
                _buildStatCard('Kazanç', '₺3.250', Icons.account_balance_wallet, AppTheme.primaryGreen),
                _buildStatCard('Puan', '4.9', Icons.star, Colors.orange),
              ],
            ),
            const SizedBox(height: 32),

            // قسم الموعد القادم (أقرب موعد)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sıradaki Randevun',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // يمكن نقله لصفحة "İşlerim" عند الضغط هنا
                  },
                  child: const Text('Tümünü Gör', style: TextStyle(color: AppTheme.primaryGreen)),
                )
              ],
            ),
            const SizedBox(height: 12),
            _buildAppointmentCard(),
            
            const SizedBox(height: 32),

            // قسم إعلانات الفرص الجديدة السريعة
            const Text(
              'Bölgendeki Yeni İlanlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildJobOpportunityCard('Hafta sonu köpek gezdirme', 'Kadıköy, Moda', '₺300'),
            _buildJobOpportunityCard('Tatil boyu kedi bakımı', 'Üsküdar, Merkez', '₺1200'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء بطاقات الإحصائيات (لتجنب تكرار الكود)
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء بطاقة الموعد القادم
  Widget _buildAppointmentCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.lightGreen, // استخدام اللون الفاتح من الثيم الخاص بك
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryGreen, width: 2),
              ),
              child: const Icon(Icons.pets, color: AppTheme.primaryGreen, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Köpek Yürüyüşü (Max)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bugün, 15:00 - 16:00',
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Moda Sahili',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () {
                  // محاكاة إتمام المهمة
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة لبناء بطاقات الفرص السريعة
  Widget _buildJobOpportunityCard(String title, String location, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.campaign, color: Colors.orange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        trailing: Text(
          price,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 16),
        ),
      ),
    );
  }
}