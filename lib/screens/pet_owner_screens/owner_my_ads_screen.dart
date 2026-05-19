// owner_my_ads_screen.dart
import 'package:flutter/material.dart';
// Firebase kütüphanelerini ekliyoruz
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import 'owner_create_ad_screen.dart';

class OwnerMyAdsScreen extends StatefulWidget {
  const OwnerMyAdsScreen({super.key});

  @override
  State<OwnerMyAdsScreen> createState() => _OwnerMyAdsScreenState();
}

class _OwnerMyAdsScreenState extends State<OwnerMyAdsScreen> {
  // Firebase örnekleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // İlanı veritabanından kalıcı olarak silen metod
  void _deleteAd(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text(
          'Bu ilanı silmek istediğinize emin misiniz? İşlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              // Dialog'u kapat
              Navigator.pop(context);

              try {
                // Firestore'dan belgeyi (ilanı) sil
                await _firestore.collection('ads').doc(docId).delete();

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('İlan başarıyla silindi'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                debugPrint('Silme hatası: $e');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('İlan silinemedi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Giriş yapmış kullanıcının ID'sini alıyoruz
    final String? currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('İlanlarım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      // Yeni İlan Ver Butonu
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
        label: const Text(
          'Yeni İlan Ver',
          style: TextStyle(color: Colors.white),
        ),
      ),
      // Güvenlik kontrolü
      body: currentUserId == null
          ? const Center(child: Text('Lütfen giriş yapın.'))
          // Firestore'dan canlı veri çekme işlemi
          : StreamBuilder<QuerySnapshot>(
              // Sadece 'ownerId'si mevcut kullanıcı olan ilanları getir
              stream: _firestore
                  .collection('ads')
                  .where('ownerId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                // Veri yüklenirken
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                // Hata oluştuysa
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Bir hata oluştu: ${snapshot.error}'),
                  );
                }

                // Kullanıcının hiç ilanı yoksa
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz hiç ilan vermediniz.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // İlanlar geldi
                final ads = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16).copyWith(
                    bottom: 80,
                  ), // Butonun arkasında kalmaması için alt boşluk
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final doc = ads[index];
                    // Belge verilerini Map'e çeviriyoruz
                    final adData = doc.data() as Map<String, dynamic>;

                    // Düzenleme sayfasına göndermek için ID'yi de Map'in içine ekliyoruz
                    adData['id'] = doc.id;

                    // Veritabanındaki boş olabilecek alanları güvenli bir şekilde alıyoruz
                    final String title = adData['title'] ?? 'İlan Başlığı';
                    final bool isActive = adData['isActive'] ?? true;
                    final String pet = adData['pet'] ?? 'Belirtilmedi';
                    final String service = adData['service'] ?? 'Hizmet';
                    final String date = adData['date'] ?? 'Tarih Yok';
                    final String budget = adData['budget']?.toString() ?? '0';

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
                                    title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isActive ? 'Aktif' : 'Pasif',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.pets, pet),
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.category, service),
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.calendar_today, date),
                            const SizedBox(height: 4),
                            _buildInfoRow(Icons.attach_money, '$budget TL'),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    // Düzenle butonuna basıldığında OwnerCreateAdScreen açılır
                                    // Veritabanından gelen veriler (ID dahil) sayfaya aktarılır
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OwnerCreateAdScreen(adData: adData),
                                      ),
                                    );
                                    // Not: StreamBuilder kullandığımız için sayfadan dönünce setState yapmaya
                                    // gerek kalmadı, veritabanı değiştiği an ekran otomatik güncellenir!
                                  },
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Düzenle'),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  // Silme işlemi için belgenin Firestore ID'sini gönderiyoruz
                                  onPressed: () => _deleteAd(doc.id),
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    'Sil',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
        Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 13)),
      ],
    );
  }
}
