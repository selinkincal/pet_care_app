//owner_bookings_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevularım'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: ListView.builder(
        itemCount: 3, // Geçici, sonra Firebase'den gelecek
        itemBuilder: (context, index) {
          return _buildBookingCard(context, index);
        },
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, int index) {
    final bookings = [
      {
        'service': 'Profesyonel Köpek Bakımı',
        'date': '15 Mayıs 2026',
        'time': '14:00',
        'status': 'Aktif',
      },
      {
        'service': 'Kedi Yürüyüşü',
        'date': '18 Mayıs 2026',
        'time': '10:30',
        'status': 'Aktif',
      },
      {
        'service': 'Veteriner Kontrolü',
        'date': '20 Mayıs 2026',
        'time': '09:00',
        'status': 'Onay Bekliyor',
      },
    ];

    final booking = bookings[index];

    return Card(
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
                        booking['service']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${booking['date']} • ${booking['time']}'),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: booking['status'] == 'Aktif'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['status']!,
                    style: TextStyle(
                      color: booking['status'] == 'Aktif'
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
