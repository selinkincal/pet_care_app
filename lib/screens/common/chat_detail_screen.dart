// chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final String? otherUserName;
  final String? otherUserId; // 👈 هذا المتغير مهم جداً لإنشاء الغرفة المشتركة

  const ChatDetailScreen({super.key, this.otherUserName, this.otherUserId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  // Firebase örnekleri (Giriş yapan kullanıcıyı ve veritabanını almak için)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // İki kullanıcı arasında benzersiz ve sabit bir sohbet odası ID'si oluşturan metod
  // UID'leri alfabetik sıraya göre birleştiririz ki A kişisi B'ye veya B kişisi A'ya mesaj atsa da aynı oda açılsın.
  String _getChatRoomId(String uid1, String uid2) {
    if (uid1.compareTo(uid2) > 0) {
      return '${uid1}_$uid2';
    } else {
      return '${uid2}_$uid1';
    }
  }

  // Mesaj gönderme işlemi
  void _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty || widget.otherUserId == null) return;

    // Gönderim sırasında TextField'ı temizle
    _messageController.clear();

    final String currentUserId = _auth.currentUser!.uid;
    final String chatRoomId = _getChatRoomId(
      currentUserId,
      widget.otherUserId!,
    );

    // Mesaj verisini oluştur (Firestore'a gönderilecek Map)
    final Map<String, dynamic> messageData = {
      'senderId': currentUserId,
      'receiverId': widget.otherUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(), // Firebase sunucu saati
    };

    try {
      // Veritabanında chats -> [OdaID] -> messages yoluna mesajı ekle
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .add(messageData);

      // İsteğe bağlı: Sohbet odasının en son mesajını ve zamanını ana belgeye kaydedebiliriz
      // (Böylece gelen kutusu 'ChatListScreen' sayfasında son mesajı kolayca gösteririz)
      await _firestore.collection('chats').doc(chatRoomId).set({
        'users': [currentUserId, widget.otherUserId],
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Mesaj gönderilirken hata oluştu: $e');
    }
  }

  // Firestore Timestamp'i saat:dakika formatına çeviren yardımcı metod
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null)
      return ''; // Eğer mesaj daha yeni gönderiliyorsa ve sunucuya ulaşmadıysa boş döndür
    final DateTime date = timestamp.toDate();
    final String hours = date.hour.toString().padLeft(2, '0');
    final String minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _auth.currentUser?.uid;

    // Güvenlik kontrolü: Kullanıcı giriş yapmamışsa veya karşı tarafın ID'si yoksa hata göster
    if (currentUserId == null || widget.otherUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hata'), backgroundColor: Colors.red),
        body: const Center(
          child: Text('Sohbet başlatılamadı. Geçersiz kullanıcı.'),
        ),
      );
    }

    final String chatRoomId = _getChatRoomId(
      currentUserId,
      widget.otherUserId!,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.otherUserName ?? 'Mesajlaşma'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            // 👈 StreamBuilder: Firestore'daki değişiklikleri canlı (real-time) dinler
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy(
                    'timestamp',
                    descending: true,
                  ) // En yeni mesaj en altta (reverse: true kullanacağımız için)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Mesajlar yüklenirken bir hata oluştu.'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Henüz mesaj yok. İlk mesajı siz gönderin!',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                // Firestore'dan gelen belgeler (mesajlar)
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true, // Mesajların alttan üste doğru dizilmesi için
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageDoc = messages[index];
                    final messageData =
                        messageDoc.data() as Map<String, dynamic>;

                    // Mesajın bana mı yoksa karşı tarafa mı ait olduğunu kontrol et
                    final bool isMe = messageData['senderId'] == currentUserId;
                    final Timestamp? timestamp =
                        messageData['timestamp'] as Timestamp?;

                    return _buildMessageBubble(
                      text: messageData['text'] ?? '',
                      time: _formatTimestamp(timestamp),
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Mesaj balonu (Tasarımı eskisinden korundu, sadece dinamik veriler alıyor)
  Widget _buildMessageBubble({
    required String text,
    required String time,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.75, // Mesaj çok uzunsa ekranın %75'ini kaplasın
        ),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryGreen : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            // Balonun kuyruk kısmını ayarlıyoruz (Bana aitse sağ alt düz, karşıya aitse sol alt düz)
            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mesaj yazma ve gönderme alanı
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Mesaj yaz...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primaryGreen,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
