// notifications_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات وهمية مختلطة (تصلح لجميع أنواع الحسابات)
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Yeni İş Talebi!',
        'message': 'Ahmet Y. köpek yürüyüşü için size bir talep gönderdi.',
        'time': '5 dk önce',
        'type': 'provider_alert', // إشعار خاص بمقدم الخدمة
        'isRead': false,
      },
      {
        'title': 'Rezervasyon Onaylandı',
        'message': 'Max için yarın 15:00\'teki randevunuz onaylandı.',
        'time': '1 saat önce',
        'type': 'owner_alert', // إشعار خاص بصاحب الحيوان
        'isRead': true,
      },
      {
        'title': 'Ödemeniz Alındı',
        'message': '300 TL bakiyeniz cüzdanınıza eklendi.',
        'time': '2 saat önce',
        'type': 'wallet_alert', // إشعار مالي
        'isRead': true,
      },
      {
        'title': 'Sisteme Hoş Geldiniz',
        'message': 'Pet Care Marketplace\'e katıldığınız için teşekkürler!',
        'time': '1 gün önce',
        'type': 'system_alert', // إشعار نظام
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Bildirimler'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // محاكاة جعل جميع الإشعارات مقروءة
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tümü okundu olarak işaretlendi')),
              );
            },
            child: const Text(
              'Tümünü Okundu İşaretle',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationTile(notif);
              },
            ),
    );
  }

  // واجهة في حال عدم وجود إشعارات
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

  // دالة بناء عنصر الإشعار (تتغير الأيقونة حسب نوع الإشعار)
  Widget _buildNotificationTile(Map<String, dynamic> notif) {
    IconData iconData;
    Color iconColor;

    // تحديد الأيقونة واللون بناءً على النوع (Type)
    switch (notif['type']) {
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
      color: notif['isRead']
          ? Colors.white
          : AppTheme.lightGreen.withValues(
              alpha: 0.3,
            ), // تمييز الإشعارات غير المقروءة
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
            // نقطة حمراء صغيرة للإشعارات غير المقروءة
            if (!notif['isRead'])
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
          notif['title'],
          style: TextStyle(
            fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notif['message'], style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 6),
              Text(
                notif['time'],
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
        onTap: () {
          // هنا لاحقاً سنقوم بالتوجيه للصفحة المناسبة حسب نوع الإشعار
        },
      ),
    );
  }
}
