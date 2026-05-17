// chat_list_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
// 👈 تم تحديث اسم الملف المستدعى هنا
import 'chat_detail_screen.dart'; 

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // بيانات وهمية لمحاكاة صندوق الوارد (Inbox)
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'Ahmet Yılmaz',
      'lastMessage': 'Cumartesi 14:00 uygun, beklerim',
      'time': '10:05',
      'unreadCount': 2,
    },
    {
      'id': '2',
      'name': 'Ayşe Demir',
      'lastMessage': 'Teşekkür ederim, görüşmek üzere.',
      'time': 'Dün',
      'unreadCount': 0,
    },
    {
      'id': '3',
      'name': 'Mehmet Kaya',
      'lastMessage': 'Hizmet detaylarını konuşabilir miyiz?',
      'time': 'Pzt',
      'unreadCount': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mesajlarım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: _chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz hiç mesajınız yok.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = _chats[index];
                final bool hasUnread = chat['unreadCount'] > 0;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.lightGreen,
                    child: const Icon(Icons.person, color: AppTheme.primaryGreen, size: 30),
                  ),
                  title: Text(
                    chat['name'],
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      chat['lastMessage'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasUnread ? Colors.black87 : Colors.grey[600],
                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread ? AppTheme.primaryGreen : Colors.grey[500],
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
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
                            chat['unreadCount'].toString(),
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
                    // 👈 تم تحديث اسم الكلاس هنا إلى ChatDetailScreen ليتوافق مع التعديل الجديد
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          otherUserName: chat['name'],
                          otherUserId: chat['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}