// provider_bookings_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../common/chat_detail_screen.dart';
import 'provider_ad_detail_screen.dart';


class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  // Aktif işler listesi
  List<Map<String, String>> _activeJobs = [
    {
      'service': 'Köpek Yürüyüşü',
      'pet': 'Max (Golden Retriever)',
      'date': 'Bugün',
      'time': '15:00 - 16:00',
      'location': 'Moda Sahili, Kadıköy',
      'price': '300 TL',
      'owner': 'Ayşe Y.',
      'ownerId': 'user123',
    },
    {
      'service': 'Evde Kedi Bakımı',
      'pet': 'Mia (Tekir)',
      'date': 'Yarın',
      'time': '10:00 - 11:00',
      'location': 'Merkez, Beşiktaş',
      'price': '250 TL',
      'owner': 'Can K.',
      'ownerId': 'user456',
    },
  ];

  // Tamamlanmış işler listesi
  List<Map<String, String>> _completedJobs = [
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

  void _completeJob(int index) {
    setState(() {
      final completedJob = _activeJobs[index];
      completedJob['status'] = 'Tamamlandı';
      completedJob['date'] = _getCurrentDate();
      _completedJobs.insert(0, completedJob);
      _activeJobs.removeAt(index);
    });

    // Bildirim göster (evcil hayvan sahibine bildirim simülasyonu)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✅ İş tamamlandı olarak işaretlendi! Evcil hayvan sahibine bildirim gönderildi.',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day} ${_getMonthName(now.month)} ${now.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('İşlerim ve Randevular'),
          backgroundColor: AppTheme.primaryGreen,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            tabs: [
              Tab(text: 'Aktif İşler (${_activeJobs.length})'),
              Tab(text: 'Geçmiş İşler (${_completedJobs.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildActiveJobsList(context), _buildPastJobsList()],
        ),
      ),
    );
  }

  Widget _buildActiveJobsList(BuildContext context) {
    if (_activeJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Aktif işiniz bulunmuyor'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeJobs.length,
      itemBuilder: (context, index) {
        final job = _activeJobs[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderAdDetailScreen(
                  adData: {
                    'title': job['service']!,
                    'pet': job['pet']!,
                    'location': job['location']!,
                    'date': job['date']!,
                    'time': job['time']!,
                    'budget': job['price']!,
                    'status': 'Yaklaşan',
                    'description':
                        '${job['service']} hizmeti için randevu oluşturuldu.',
                    'ownerName': job['owner']!,
                    'ownerPhone': '0532 123 45 67',
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        job['service']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Yaklaşan',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.pets, job['pet']!),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.person, 'Müşteri: ${job['owner']}'),
                  const SizedBox(height: 6),
                  _buildInfoRow(
                    Icons.calendar_today,
                    '${job['date']} • ${job['time']}',
                  ),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.location_on, job['location']!),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        job['price']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      Row(
                        children: [
                     IconButton(
  icon: const Icon(Icons.phone, color: Colors.green),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(otherUserName: job['owner']), // const'i KALDIR
      ),
    );
  },
),
                          ElevatedButton(
                            onPressed: () => _completeJob(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Tamamla',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastJobsList() {
    if (_completedJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Henüz tamamlanmış iş yok'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedJobs.length,
      itemBuilder: (context, index) {
        final job = _completedJobs[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProviderAdDetailScreen(
                  adData: {
                    'title': job['service']!,
                    'pet': job['pet']!,
                    'location': job['location']!,
                    'date': job['date']!,
                    'time': 'Tamamlandı',
                    'budget': job['price']!,
                    'status': 'Tamamlandı',
                    'description': 'Bu iş tamamlanmıştır.',
                    'ownerName': 'Müşteri',
                    'ownerPhone': '0532 123 45 67',
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
              title: Text(
                job['service']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('${job['pet']} • ${job['date']}'),
                  Text(
                    job['location']!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              trailing: Text(
                job['price']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
