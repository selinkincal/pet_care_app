// chat_list_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Firebase örnekleri (Firebase nesneleri)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Zaman damgasını (Timestamp) okunabilir saat/tarih formatına çeviren yardımcı metod
  // (Timestamp'i okunabilir saat/tarih formatına dönüştüren yardımcı metot)
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = timestamp.toDate();
    final DateTime now = DateTime.now();

    // Eğer mesaj bugün atılmışsa saati göster, değilse tarihi göster
    // (Mesaj bugün gönderildiyse saati, değilse tarihi göster)
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      final String hours = date.hour.toString().padLeft(2, '0');
      final String minutes = date.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _auth.currentUser?.uid;

    // Kullanıcı giriş yapmamışsa hata ekranı göster (Kullanıcı giriş yapmamışsa hata ekranı göster)
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata'), backgroundColor: Colors.red),
        body: const Center(child: Text('Lütfen önce giriş yapın.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mesajlarım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      // 1. StreamBuilder: Kullanıcının dahil olduğu sohbet odalarını canlı dinler
      // (StreamBuilder: Kullanıcının dahil olduğu sohbet odalarını gerçek zamanlı dinler)
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where(
              'users',
              arrayContains: currentUserId,
            ) // Sadece benim olduğum odaları getir (Sadece benim bulunduğum odaları getir)
            .orderBy(
              'lastMessageTime',
              descending: true,
            ) // En son mesaj atılan en üstte olsun (En son mesaj gönderilen en üstte olsun)
            .snapshots(),
        builder: (context, snapshot) {
          // Veri yüklenirken bekleme göstergesi (Veri yüklenirken yükleniyor göstergesi)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }

          // Hata durumunda Firebase hatası yerine "Şu anda hiç sohbet yok" mesajı göster
          // (Hata durumunda Firebase hatası yerine "Şu anda hiç sohbet yok" mesajını göster)
          if (snapshot.hasError) {
            return _buildEmptyChatsWidget();
          }

          // Veri yoksa veya boşsa "hiç sohbet yok" mesajı göster (Veri yoksa veya boşsa "hiç sohbet yok" mesajını göster)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyChatsWidget();
          }

          final chatRooms = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chatRooms.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final roomDoc = chatRooms[index];
              final roomData = roomDoc.data() as Map<String, dynamic>;

              // Odadaki kullanıcılardan "ben" olmayan diğer kişinin ID'sini bul
              // (Odadaki kullanıcılardan "ben" olmayan diğer kişinin ID'sini bul)
              final List<dynamic> users = roomData['users'] ?? [];
              final String otherUserId = users.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              final String lastMessage =
                  roomData['lastMessage'] ?? 'Fotoğraf/Dosya';
              final Timestamp? lastMessageTime =
                  roomData['lastMessageTime'] as Timestamp?;

              // Okunmamış mesaj sayısı (varsayılan 0) (Okunmamış mesaj sayısı, varsayılan 0)
              final int unreadCount = roomData['unreadCount'] ?? 0;
              final bool hasUnread = unreadCount > 0;

              // 2. FutureBuilder: Diğer kullanıcının adını 'users' tablosundan asenkron olarak çekiyoruz
              // (FutureBuilder: Diğer kullanıcının adını 'users' koleksiyonundan asenkron olarak alıyoruz)
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  String otherUserName = 'Yükleniyor...';

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    otherUserName =
                        userSnapshot.data!.get('name') ?? 'İsimsiz Kullanıcı';
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.lightGreen,
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.primaryGreen,
                        size: 30,
                      ),
                    ),
                    title: Text(
                      otherUserName,
                      style: TextStyle(
                        fontWeight: hasUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasUnread ? Colors.black87 : Colors.grey[600],
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(lastMessageTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? AppTheme.primaryGreen
                                : Colors.grey[500],
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (hasUnread)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      // Karşı tarafın UID'si ve adı ile sohbet detay ekranına geç
                      // (Karşı tarafın UID'si ve adı ile sohbet detay ekranına git)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            otherUserName: otherUserName,
                            otherUserId: otherUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // "Şu anda hiç sohbet yok" mesajını gösteren yardımcı widget (Yardımcı widget: "Şu anda hiç sohbet yok" mesajını gösterir)
  Widget _buildEmptyChatsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Şu anda hiç sohbet yok', // "لا يوجد أي دردشات حاليا"
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
