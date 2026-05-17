// provider_my_services_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'provider_create_service_screen.dart'; // صفحة الإضافة والتعديل

class ProviderMyServicesScreen extends StatefulWidget {
  const ProviderMyServicesScreen({super.key});

  @override
  State<ProviderMyServicesScreen> createState() => _ProviderMyServicesScreenState();
}

class _ProviderMyServicesScreenState extends State<ProviderMyServicesScreen> {
  // بيانات وهمية لمحاكاة خدمات الموفر
  final List<Map<String, dynamic>> _myServices = [
    {
      'id': '1',
      'title': 'Profesyonel Köpek Yürüyüşü',
      'category': 'Köpek Yürüyüşü',
      'price': '150',
      'duration': '1 saat',
      'location': 'Kadıköy, İstanbul',
      'description': 'Köpeğinizi güvenle gezdiriyorum.',
      'isActive': true,
    },
    {
      'id': '2',
      'title': 'Evde Kedi Bakımı',
      'category': 'Evde Bakım',
      'price': '300',
      'duration': 'Günlük',
      'location': 'Moda, İstanbul',
      'description': 'Siz tatildeyken kedinize kendi evinde bakıyorum.',
      'isActive': false,
    },
  ];

  void _deleteService(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hizmeti Sil'),
        content: const Text('Bu hizmeti silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myServices.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hizmet başarıyla silindi'),
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
        title: const Text('Hizmetlerim'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // إضافة خدمة جديدة
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProviderCreateServiceScreen(),
            ),
          ).then((newService) {
            if (newService != null) {
              setState(() {
                _myServices.add(newService);
              });
            }
          });
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Yeni Hizmet Ekle', style: TextStyle(color: Colors.white)),
      ),
      body: _myServices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz hiç hizmet eklemediniz.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _myServices.length,
              itemBuilder: (context, index) {
                final service = _myServices[index];
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
                                service['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: service['isActive']
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                service['isActive'] ? 'Aktif' : 'Pasif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: service['isActive'] ? Colors.green : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.category, service['category']),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.attach_money, '${service['price']} TL / ${service['duration']}'),
                        const SizedBox(height: 4),
                        _buildInfoRow(Icons.location_on, service['location']),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // تعديل الخدمة وتمرير بياناتها
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProviderCreateServiceScreen(serviceData: service),
                                  ),
                                ).then((updatedService) {
                                  if (updatedService != null) {
                                    setState(() {
                                      _myServices[index] = updatedService;
                                    });
                                  }
                                });
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Düzenle'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _deleteService(index),
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