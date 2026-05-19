// owner_service_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import 'owner_create_booking_screen.dart';
import '../common/chat_detail_screen.dart';

class OwnerServiceDetailScreen extends StatefulWidget {
  // Önceki sayfadan (Liste veya Ana Sayfa) tıklanan hizmetin verilerini alıyoruz
  final Map<String, dynamic> serviceData;
  final String serviceId;

  const OwnerServiceDetailScreen({
    super.key,
    required this.serviceData,
    required this.serviceId,
  });

  @override
  State<OwnerServiceDetailScreen> createState() =>
      _OwnerServiceDetailScreenState();
}

class _OwnerServiceDetailScreenState extends State<OwnerServiceDetailScreen> {
  // Hizmet verenin adını Firestore'dan çekmek için değişkenler
  String _providerName = 'Hizmet Veren Yükleniyor...';
  String? _providerId;
  bool _isLoadingProvider = true;

  @override
  void initState() {
    super.initState();
    _fetchProviderInfo();
  }

  // 1. Hizmeti Veren Kişinin (Provider) Bilgilerini Çekme
  Future<void> _fetchProviderInfo() async {
    try {
      // Veritabanındaki hizmet belgesinden providerId'yi alıyoruz
      // (Hizmet veren kişi hizmeti oluştururken kendi UID'sini bu alana kaydetmeli)
      _providerId =
          widget.serviceData['providerId'] ?? widget.serviceData['ownerId'];

      if (_providerId != null) {
        // 'users' tablosundan bu kişinin profilini bul
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_providerId)
            .get();
        if (doc.exists && mounted) {
          setState(() {
            _providerName = doc.data()?['name'] ?? 'İsimsiz Hizmet Veren';
            _isLoadingProvider = false;
          });
        }
      } else {
        setState(() {
          _providerName = 'Hizmet Veren Bulunamadı';
          _isLoadingProvider = false;
        });
      }
    } catch (e) {
      debugPrint('Hizmet veren bilgisi çekilemedi: $e');
      if (mounted) {
        setState(() {
          _providerName = 'Hizmet Veren';
          _isLoadingProvider = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gelen verileri güvenli bir şekilde değişkenlere aktarıyoruz
    final String title = widget.serviceData['title'] ?? 'İsimsiz Hizmet';
    final String price = widget.serviceData['price']?.toString() ?? '0';
    final String location =
        widget.serviceData['location'] ?? 'Konum Bilinmiyor';
    final String rating = widget.serviceData['rating']?.toString() ?? '5.0';
    final String description =
        widget.serviceData['description'] ??
        'Bu hizmet için henüz bir açıklama girilmemiş.';

    // Resim yolunu al (şimdilik ikon gösteriyoruz ama altyapı hazır)
    final String? imagePath = widget.serviceData['imagePath'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Hizmet Detayı'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Resim Alanı
            Container(
              height: 200,
              width: double.infinity,
              color: AppTheme.lightGreen,
              child: const Icon(
                Icons.pets,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3. Başlık ve Fiyat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
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
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$price TL',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 4. Puan ve Konum
                  Row(
                    children: [
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. Hizmet Veren Profili (Mini Kart)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.lightGreen,
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hizmet Veren',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              _isLoadingProvider
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _providerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 6. Açıklama
                  const Text(
                    'Hizmet Açıklaması',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 7. Harita Başlığı (Şimdilik Placeholder)
                  const Text(
                    'Konum',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Harita görünümü ileride eklenebilir',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 8. REZERVASYON BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Rezervasyon sayfasına gerçek isim ve fiyatı gönderiyoruz
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OwnerCreateBookingScreen(
                              serviceName: title,
                              price: '$price TL',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '📅 Rezervasyon Yap',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 9. MESAJ GÖNDER BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Güvenlik kontrolü: Provider ID yoksa mesaj atılamaz
                        if (_providerId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hizmet veren profili bulunamadı.'),
                            ),
                          );
                          return;
                        }

                        // ChatDetailScreen'e gerçek ID ve İsmi gönderiyoruz
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              otherUserName: _providerName,
                              otherUserId:
                                  _providerId, // 👈 Bu sayede Firebase'de doğru sohbet odası açılacak
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.chat,
                        color: AppTheme.primaryGreen,
                      ),
                      label: const Text(
                        'Mesaj Gönder',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
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
}
