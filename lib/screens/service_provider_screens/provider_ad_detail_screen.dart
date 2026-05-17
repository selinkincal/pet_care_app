// provider_ad_detail_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../common/chat_detail_screen.dart';

class ProviderAdDetailScreen extends StatelessWidget {
  final Map<String, String>? adData;

  const ProviderAdDetailScreen({super.key, this.adData});

  @override
  Widget build(BuildContext context) {
    // Tüm alanlar için güvenli erişim
    final title = adData?['title'] ?? 'İlan Başlığı';
    final pet = adData?['pet'] ?? 'Evcil Hayvan';
    final location = adData?['location'] ?? 'Konum belirtilmemiş';
    final date = adData?['date'] ?? 'Tarih belirtilmemiş';
    final time = adData?['time'] ?? 'Saat belirtilmemiş';
    final budget = adData?['budget'] ?? '0 TL';
    final status = adData?['status'] ?? 'Normal';
    final description = adData?['description'] ?? 'Açıklama eklenmemiş.';
    final ownerName = adData?['ownerName'] ?? 'İlan Sahibi';
    final ownerPhone = adData?['ownerPhone'] ?? 'Telefon bilgisi yok';
    final petImageUrl =
        adData?['petImageUrl'] ?? ''; // YENİ: evcil hayvan resmi URL'i

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evcil Hayvan Resmi (YENİ)
            Container(
              height: 200,
              width: double.infinity,
              color: AppTheme.lightGreen,
              child: petImageUrl.isNotEmpty
                  ? Image.network(
                      petImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultPetImage();
                      },
                    )
                  : _buildDefaultPetImage(),
            ),
            // İlan bilgileri
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppTheme.lightGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.pets, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(pet, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.location_on, 'Konum', location),
                          const Divider(),
                          _buildInfoRow(Icons.calendar_today, 'Tarih', date),
                          const Divider(),
                          _buildInfoRow(Icons.access_time, 'Saat', time),
                          const Divider(),
                          _buildInfoRow(
                            Icons.attach_money,
                            'Bütçe',
                            budget,
                            isPrice: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📝 Açıklama',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '👤 İlan Sahibi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.person, 'İsim', ownerName),
                          const Divider(),
                          _buildInfoRow(Icons.phone, 'Telefon', ownerPhone),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatDetailScreen(otherUserName: ownerName),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('Mesaj Gönder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Başvuru Gönderildi'),
                                content: const Text(
                                  'İlana başvurunuz başarıyla iletildi.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Tamam'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Başvur'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPetImage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.pets, size: 64, color: AppTheme.primaryGreen),
        const SizedBox(height: 8),
        Text(
          'Evcil Hayvan Resmi',
          style: TextStyle(color: AppTheme.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                color: isPrice ? AppTheme.primaryGreen : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Acil':
        return Colors.red;
      case 'Yeni':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}
