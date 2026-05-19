// help_screen.dart
import 'package:flutter/material.dart';
// Firebase kütüphanelerini ekliyoruz (Destek taleplerini veritabanına göndermek için)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

// Form durumunu ve yüklenme animasyonunu yönetmek için StatelessWidget yerine StatefulWidget kullanıyoruz
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Firebase örnekleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Destek mesajını tutacak kontrolcü
  final TextEditingController _supportController = TextEditingController();

  // Yükleme durumunu kontrol etmek için
  bool _isSubmitting = false;

  @override
  void dispose() {
    _supportController.dispose();
    super.dispose();
  }

  // Destek talebini Firestore'a gönderen metod
  Future<void> _submitSupportTicket() async {
    final String message = _supportController.text.trim();

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir mesaj yazın.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Geçerli kullanıcıyı al (Eğer giriş yapmamışsa null dönebilir, ama normalde yapmıştır)
      final User? currentUser = _auth.currentUser;

      // Firestore'da 'support_tickets' (destek biletleri) adında yeni bir tablo (koleksiyon) oluştur/kullan
      await _firestore.collection('support_tickets').add({
        'uid': currentUser?.uid ?? 'Bilinmeyen Kullanıcı',
        'email': currentUser?.email ?? 'Bilinmeyen E-posta',
        'message': message,
        'status': 'Açık', // Talebin durumu (Açık, İnceleniyor, Çözüldü)
        'createdAt': FieldValue.serverTimestamp(), // Gönderim zamanı
      });

      if (!mounted) return;

      // Başarılı olursa mesaj kutusunu temizle ve pencereyi kapat
      _supportController.clear();
      Navigator.pop(context); // Dialog penceresini kapat

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Destek talebiniz başarıyla alındı! En kısa sürede size dönüş yapacağız.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Destek talebi gönderilirken hata oluştu: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // Kullanıcı destek butonuna tıkladığında açılacak olan pencere (Dialog)
  void _showSupportDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          !_isSubmitting, // Yüklenirken dışarı tıklanıp kapanmasını engelle
      builder: (context) {
        return StatefulBuilder(
          // Dialog içindeki state'i yönetmek için StatefulBuilder kullanıyoruz
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Destek Talebi Oluştur'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Karşılaştığınız sorunu veya sormak istediğiniz soruyu detaylıca yazın:',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _supportController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Mesajınızı buraya yazın...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          // Dialog içindeki UI'ı güncellemek için setState yerine setDialogState kullanıyoruz
                          setDialogState(() => _isSubmitting = true);
                          await _submitSupportTicket();
                          // İşlem bittiğinde dialog açıksa state'i geri al
                          if (mounted && context.mounted) {
                            setDialogState(() => _isSubmitting = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Gönder',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

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

          // Destek Talebi Butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed:
                  _showSupportDialog, // Butona tıklandığında dialog açılır
              icon: const Icon(Icons.mail, color: Colors.white),
              label: const Text(
                'Destek Talebi Oluştur',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: AppTheme.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(color: Colors.grey[800]),
                      ),
                    ),
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
