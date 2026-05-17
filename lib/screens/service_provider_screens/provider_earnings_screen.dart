// provider_earnings_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
// استدعاء صفحة تفاصيل الإعلان (تأكد من مسارها الصحيح في مشروعك)
import 'provider_ad_detail_screen.dart';

class ProviderEarningsScreen extends StatelessWidget {
  const ProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تحديث البيانات الوهمية لدعم النوع (type) لتحديد ما إذا كانت ربحاً أم سحباً
    final List<Map<String, dynamic>> transactions = [
      {
        'title': 'Köpek Yürüyüşü (Max)',
        'date': '1 Mayıs 2026',
        'amount': '+300 TL',
        'status': 'Tamamlandı',
        'type': 'earning', // 👈 أرباح من إعلان
        // بيانات وهمية للإعلان لنقلها للصفحة التالية
        'adData': {'title': 'Köpek Yürüyüşü', 'pet': 'Max'}, 
      },
      {
        'title': 'Evde Kedi Bakımı (Mia)',
        'date': '29 Nisan 2026',
        'amount': '+250 TL',
        'status': 'Tamamlandı',
        'type': 'earning',
        'adData': {'title': 'Evde Kedi Bakımı', 'pet': 'Mia'},
      },
      {
        'title': 'Para Çekme İşlemi',
        'date': '25 Nisan 2026',
        'amount': '-1500 TL',
        'status': 'Banka Hesabına Aktarıldı',
        'type': 'withdrawal', // 👈 سحب بنكي (ليس له إعلان)
      },
      {
        'title': 'Veteriner Refakati (Paşa)',
        'date': '20 Nisan 2026',
        'amount': '+400 TL',
        'status': 'Beklemede (Havuzda)',
        'type': 'earning',
        'adData': {'title': 'Veteriner Refakati', 'pet': 'Paşa'},
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kazançlarım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الرصيد الرئيسي والمحدثة
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Çekilebilir Bakiye',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '₺1.250,00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 👈 إضافة الرصيد المعلق (Bekleyen Bakiye) بشكل أنيق
                  const Divider(color: Colors.white30, height: 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bekleyen Bakiye (Havuzda)',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '₺400,00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Para çekme talebiniz alındı!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Para Çek',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ملخص الأرباح
            const Text(
              'Kazanç Özeti',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryCard('Bu Hafta', '₺550'),
                const SizedBox(width: 16),
                _buildSummaryCard('Bu Ay', '₺3.250'),
              ],
            ),
            const SizedBox(height: 32),

            // سجل المعاملات
            const Text(
              'İşlem Geçmişi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx['amount'].toString().startsWith('+');
                final isEarning = tx['type'] == 'earning'; // التحقق من نوع المعاملة

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    // 👈 التوجيه الديناميكي لصفحة التفاصيل فقط إذا كان الدخل من خدمة
                    onTap: isEarning
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProviderAdDetailScreen(
                                  // تمرير بيانات الإعلان للصفحة المستقبلة
                                  adData: tx['adData'],
                                ),
                              ),
                            );
                          }
                        : null, // لا تفعل شيئاً إذا كان سحباً بنكياً
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isIncome
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      tx['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(tx['date'], style: const TextStyle(fontSize: 12)),
                        Text(
                          tx['status'],
                          style: TextStyle(
                            fontSize: 11,
                            color: tx['status'].toString().contains('Beklemede')
                                ? Colors.orange // إعطاء لون برتقالي للحالة المعلقة
                                : Colors.grey[600],
                            fontWeight: tx['status'].toString().contains('Beklemede')
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tx['amount'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isIncome ? AppTheme.primaryGreen : Colors.red,
                          ),
                        ),
                        // إضافة سهم صغير للدلالة على إمكانية الضغط إذا كان إعلاناً
                        if (isEarning) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}