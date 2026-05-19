// owner_bookings_screen.dart
import 'package:flutter/material.dart';
// Firebase kütüphanelerini ekliyoruz
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import 'owner_service_detail_screen.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  // Firebase örneklerini (instance) oluşturuyoruz
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Mevcut oturum açmış kullanıcının ID'sini alıyoruz
    final String? currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Arka planı biraz yumuşatalım
      appBar: AppBar(
        title: const Text('Randevularım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      // 1. Güvenlik Kontrolü: Kullanıcı giriş yapmamışsa hata mesajı göster
      body: currentUserId == null
          ? const Center(child: Text('Lütfen önce giriş yapın.'))
          // 2. StreamBuilder: Firestore'dan kullanıcının randevularını canlı olarak dinler
          : StreamBuilder<QuerySnapshot>(
              // Firestore sorgusu: 'bookings' koleksiyonunda, 'ownerId'si benim UID'm olanları getir
              stream: _firestore
                  .collection('bookings')
                  .where('ownerId', isEqualTo: currentUserId)
                  // Eğer tarih sırasına göre dizmek isterseniz aşağıdaki satırı açabilirsiniz
                  // (Not: orderBy kullanmak Firebase konsolundan indeks oluşturmanızı gerektirebilir)
                  // .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Veri yüklenirken dönen bir indikatör göster
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                // Bir hata oluştuysa kullanıcıya bildir
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Randevular yüklenirken hata oluştu: ${snapshot.error}',
                    ),
                  );
                }

                // Eğer kullanıcının hiç randevusu yoksa boş durum (empty state) tasarımı göster
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz hiç randevunuz bulunmuyor.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Firestore'dan gelen belge listesini (randevuları) al
                final bookings = snapshot.data!.docs;

                // Verileri ListView ile ekrana bas
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ), // Alta biraz boşluk
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    // Her bir randevu belgesini Map verisine dönüştür
                    final bookingData =
                        bookings[index].data() as Map<String, dynamic>;

                    return _buildBookingCard(context, bookingData);
                  },
                );
              },
            ),
    );
  }

  // Randevu Kartı Tasarımı (Artık statik index yerine dinamik Firestore verisi alıyor)
  Widget _buildBookingCard(
    BuildContext context,
    Map<String, dynamic> bookingData,
  ) {
    // Veritabanından gelen alanları güvenli bir şekilde değişkenlere aktarıyoruz
    // Eğer veritabanında o alan boşsa (null) varsayılan değerler atıyoruz
    final String serviceName = bookingData['service'] ?? 'Bilinmeyen Hizmet';
    final String date = bookingData['date'] ?? 'Tarih Belirtilmedi';
    final String time = bookingData['time'] ?? 'Saat Belirtilmedi';
    final String status = bookingData['status'] ?? 'Onay Bekliyor';

    // Duruma göre (Aktif vs Onay Bekliyor) renkleri belirliyoruz
    final bool isActive = status.toLowerCase() == 'aktif';

    return InkWell(
      onTap: () {
        // Detay sayfasına yönlendirme (İleride bu sayfaya booking ID'sini de gönderebilirsiniz)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const OwnerServiceDetailScreen(serviceData: {}, serviceId: ''),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pets, color: AppTheme.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$date • $time',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
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
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isActive ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
