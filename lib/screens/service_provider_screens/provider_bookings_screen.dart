// provider_bookings_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProviderBookingsScreen extends StatelessWidget {
  const ProviderBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // عدد التبويبات (نشط / سابق)
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('İşlerim ve Randevular'),
          backgroundColor: AppTheme.primaryGreen,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Aktif İşler'),
              Tab(text: 'Geçmiş İşler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // التبويب الأول: المهام النشطة
            _buildActiveJobsList(context),
            // التبويب الثاني: المهام السابقة (المكتملة/الملغاة)
            _buildPastJobsList(),
          ],
        ),
      ),
    );
  }

  // قائمة المهام النشطة
  Widget _buildActiveJobsList(BuildContext context) {
    final List<Map<String, String>> activeJobs = [
      {
        'service': 'Köpek Yürüyüşü',
        'pet': 'Max (Golden Retriever)',
        'date': 'Bugün',
        'time': '15:00 - 16:00',
        'location': 'Moda Sahili, Kadıköy',
        'price': '300 TL',
        'owner': 'Ayşe Y.',
      },
      {
        'service': 'Evde Kedi Bakımı',
        'pet': 'Mia (Tekir)',
        'date': 'Yarın',
        'time': '10:00 - 11:00',
        'location': 'Merkez, Beşiktaş',
        'price': '250 TL',
        'owner': 'Can K.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeJobs.length,
      itemBuilder: (context, index) {
        final job = activeJobs[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رأس البطاقة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job['service']!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Yaklaşan',
                        style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // التفاصيل
                _buildInfoRow(Icons.pets, job['pet']!),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.person, 'Müşteri: ${job['owner']}'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.calendar_today, '${job['date']} • ${job['time']}'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.location_on, job['location']!),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(),
                ),

                // السعر والأزرار
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      job['price']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () {
                            // محاكاة الاتصال
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${job['owner']} aranıyor...')),
                            );
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // محاكاة إكمال المهمة
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('İş tamamlandı olarak işaretlendi!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Tamamla', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // قائمة المهام السابقة (المكتملة)
  Widget _buildPastJobsList() {
    final List<Map<String, String>> pastJobs = [
      {
        'service': 'Veteriner Refakati',
        'pet': 'Paşa (Kuş)',
        'date': '5 Mayıs 2026',
        'location': 'Üsküdar',
        'price': '400 TL',
        'status': 'Tamamlandı',
      },
      {
        'service': 'Köpek Yürüyüşü',
        'pet': 'Karabaş (Kangal)',
        'date': '3 Mayıs 2026',
        'location': 'Kadıköy',
        'price': '350 TL',
        'status': 'Tamamlandı',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastJobs.length,
      itemBuilder: (context, index) {
        final job = pastJobs[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.green),
            ),
            title: Text(job['service']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${job['pet']} • ${job['date']}'),
                Text(job['location']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
            trailing: Text(
              job['price']!,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  // دالة مساعدة لإنشاء صفوف المعلومات مع الأيقونات
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
      ],
    );
  }
}