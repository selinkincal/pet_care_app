// help_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yardım ve Destek'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('📞 İletişim Bilgileri', [
            'Müşteri Hizmetleri: 0850 123 45 67',
            'WhatsApp Destek: 0532 123 45 67',
            'E-posta: destek@petcare.com.tr',
          ]),
          _buildSection('🏢 Kurumsal', [
            'Pet Care Marketplace Teknoloji A.Ş.',
            'Adres: Kadıköy/İstanbul',
            'Vergi No: 1234567890',
            'MERSİS No: 1234567890123456',
          ]),
          _buildSection('⏰ Çalışma Saatleri', [
            'Hafta içi: 09:00 - 20:00',
            'Cumartesi: 10:00 - 18:00',
            'Pazar: Kapalı',
          ]),
          _buildSection('❓ Sık Sorulan Sorular', [
            'Nasıl kayıt olurum?',
            'Hizmet nasıl alırım?',
            'Randevu nasıl iptal edilir?',
            'Ödemeler nasıl yapılır?',
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.mail),
              label: const Text('Destek Talebi Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
