// notifications_screen.dart
import 'package:flutter/material.dart';
// Firebase kütüphanelerini ekliyoruz
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Firebase örnekleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tüm bildirimleri "Okundu" olarak işaretleyen gelişmiş metod (Batch Update)
  Future<void> _markAllAsRead() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // Sadece 'isRead' == false olan bildirimleri getir
      final unreadQuery = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadQuery.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zaten tüm bildirimler okunmuş.')),
        );
        return;
      }

      // Veritabanını yormamak için 'Batch' (toplu işlem) kullanıyoruz
      final WriteBatch batch = _firestore.batch();

      for (var doc in unreadQuery.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tüm bildirimler okundu olarak işaretlendi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Bildirimleri güncellerken hata: $e');
    }
  }

  // Tek bir bildirime tıklandığında onu okundu yapan metod
  Future<void> _markAsRead(String docId, bool isAlreadyRead) async {
    if (isAlreadyRead) return; // Zaten okunmuşsa veritabanına boşuna istek atma

    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(docId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Bildirim güncellenirken hata: $e');
    }
  }

  // Firestore Timestamp'i okunabilir zamana çeviren yardımcı metod
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Şimdi';
    final DateTime date = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata'), backgroundColor: Colors.red),
        body: const Center(child: Text('Lütfen önce giriş yapın.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _markAllAsRead, // Toplu güncelleme metodunu çağırır
            child: const Text(
              'Tümünü Okundu İşaretle',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      // Firebase'den bildirimleri canlı olarak çeken StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('notifications')
            .orderBy('createdAt', descending: true) // En yeni bildirim en üstte
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Bildirimler yüklenirken hata oluştu.'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!.docs;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notifDoc = notifications[index];
              final notifData = notifDoc.data() as Map<String, dynamic>;
              final String docId = notifDoc.id;

              return _buildNotificationTile(notifData, docId);
            },
          );
        },
      ),
    );
  }

  // Bildirim yoksa gösterilecek boş ekran
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz bildiriminiz yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni bir gelişme olduğunda size haber vereceğiz.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Bildirim liste elemanının tasarımı
  Widget _buildNotificationTile(Map<String, dynamic> notif, String docId) {
    IconData iconData;
    Color iconColor;

    // Veritabanından gelen verileri güvenli şekilde al
    final String type = notif['type'] ?? 'system_alert';
    final bool isRead = notif['isRead'] ?? false;
    final String title = notif['title'] ?? 'Bildirim';
    final String message = notif['message'] ?? '';
    final Timestamp? createdAt = notif['createdAt'] as Timestamp?;

    // Tipe göre simge ve renk belirleme
    switch (type) {
      case 'provider_alert':
        iconData = Icons.work;
        iconColor = Colors.orange;
        break;
      case 'owner_alert':
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'wallet_alert':
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.info;
        iconColor = Colors.grey;
    }

    return Container(
      color: isRead
          ? Colors.white
          : AppTheme.lightGreen.withValues(
              alpha: 0.3,
            ), // Okunmamışları hafif yeşil yap
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.1),
              radius: 24,
              child: Icon(iconData, color: iconColor),
            ),
            // Okunmamış bildirimler için kırmızı nokta
            if (!isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 6),
              Text(
                _formatTime(createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        onTap: () {
          // Bildirime tıklanınca "Okundu" olarak güncelle
          _markAsRead(docId, isRead);

          // Gelecekte: Bildirim tipine göre ilgili sayfaya (Örn: Cüzdan, Randevular) yönlendirme yapılabilir
        },
      ),
    );
  }
}
