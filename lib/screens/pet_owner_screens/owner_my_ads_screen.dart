// owner_my_ads_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
// استدعاء صفحة إنشاء الإعلان التي قمت أنت ببرمجتها
import 'owner_create_ad_screen.dart';

class OwnerMyAdsScreen extends StatefulWidget {
  const OwnerMyAdsScreen({super.key});

  @override
  State<OwnerMyAdsScreen> createState() => _OwnerMyAdsScreenState();
}

class _OwnerMyAdsScreenState extends State<OwnerMyAdsScreen> {
  // بيانات وهمية لمحاكاة الإعلانات التي نشرها صاحب الحيوان
  final List<Map<String, dynamic>> _myAds = [
    {
      'id': '1',
      'title': 'Hafta sonu için köpek gezdirici',
      'pet': 'Max (Köpek)',
      'service': 'Köpek Yürüyüşü',
      'date': '25/05/2026',
      'budget': '300',
      'isActive': true,
    },
    {
      'id': '2',
      'title': 'Kedim için 3 günlük evde bakım',
      'pet': 'Mia (Kedi)',
      'service': 'Evde Bakım',
      'date': '10/06/2026',
      'budget': '1200',
      'isActive': false, // إعلان منتهي أو غير فعال
    },
  ];

  void _deleteAd(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text('Bu ilanı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myAds.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('İlan başarıyla silindi'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('İlanlarım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      // الزر العائم لإنشاء إعلان جديد (ينقلك لصفحتك التي برمجتها)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OwnerCreateAdScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni İlan Ver', style: TextStyle(color: Colors.white)),
      ),
      body: _myAds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz hiç ilan vermediniz.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myAds.length,
              itemBuilder: (context, index) {
                final ad = _myAds[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                ad['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ad['isActive']
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                ad['isActive'] ? 'Aktif' : 'Pasif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ad['isActive'] ? Colors.green : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.pets, ad['pet']),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.category, ad['service']),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.calendar_today, ad['date']),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.attach_money, '${ad['budget']} TL'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // ✅ تمرير بيانات الإعلان للنافذة وتحديث القائمة عند العودة
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    // قمنا بإزالة const وتمرير adData
                                    builder: (context) => OwnerCreateAdScreen(adData: ad), 
                                  ),
                                ).then((updatedAd) {
                                  // هذا الجزء لتحديث القائمة فور تعديل الإعلان والعودة
                                  if (updatedAd != null) {
                                    setState(() {
                                      _myAds[index] = updatedAd;
                                    });
                                  }
                                });
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Düzenle'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteAd(index),
                              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                              label: const Text('Sil', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.grey[800], fontSize: 13),
        ),
      ],
    );
  }
}