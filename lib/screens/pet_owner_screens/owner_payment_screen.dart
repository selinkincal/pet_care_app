// owner_payment_screen.dart
import 'package:flutter/material.dart';
// Firebase Firestore kütüphanesini ekliyoruz
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';

class OwnerPaymentScreen extends StatefulWidget {
  // Önceki sayfadan (Rezervasyon Oluşturma) Firestore'daki belgenin ID'sini almamız gerekiyor
  final String bookingId;
  final String serviceName;
  final String price;
  final String date;
  final String time;

  const OwnerPaymentScreen({
    super.key,
    required this.bookingId, // Veritabanındaki belgeyi bulmak için şart
    required this.serviceName,
    required this.price,
    required this.date,
    required this.time,
  });

  @override
  State<OwnerPaymentScreen> createState() => _OwnerPaymentScreenState();
}

class _OwnerPaymentScreenState extends State<OwnerPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Firebase Entegreli Ödeme Simülasyonu
  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      // 1. Ekrana yükleniyor animasyonu çıkar (Kullanıcı tekrar butona basmasın diye)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );

      try {
        // 2. Banka / Ödeme geçidi simülasyonu (2 saniye bekleme)
        await Future.delayed(const Duration(seconds: 2));

        // 3. FİREBASE GÜNCELLEMESİ: Ödeme başarılı oldu!
        // Firestore'daki 'bookings' koleksiyonunda, bizim bookingId'mize sahip belgeyi bul
        // ve durumunu (status) 'Aktif' olarak güncelle.
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId) // Parametre olarak gelen ID
            .update({
              'status':
                  'Aktif', // Artık ödeme alındı, randevu onay bekliyor/aktif.
              'paymentDate':
                  FieldValue.serverTimestamp(), // Ödemenin yapıldığı kesin anı da kaydediyoruz
            });

        // 4. İşlem bittikten sonra yükleme ekranını kapat
        if (!mounted) return;
        Navigator.pop(context);

        // 5. Başarılı penceresini göster
        _showSuccessDialog();
      } catch (e) {
        // Eğer veritabanına yazarken veya ödemede hata çıkarsa
        if (!mounted) return;
        Navigator.pop(context); // Yüklemeyi kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme işlemi sırasında hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text('Ödeme Başarılı!', textAlign: TextAlign.center),
          ],
        ),
        content: const Text(
          'Ödemeniz güvenli havuza alındı ve hizmet verene talep iletildi. Hizmet veren onayladığında işleminiz kesinleşecektir.',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Ana Sayfaya Dön (Açık olan ödeme ve detay sayfalarını kapatır)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ana Sayfaya Dön',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Toplam tutarı hesaplamak için rakamları ayrıştırıyoruz
    double basePrice =
        double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    double serviceFee =
        basePrice * 0.10; // %10 Uygulama komisyonu/Hizmet Bedeli
    double totalPrice = basePrice + serviceFee;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Güvenli Ödeme'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sipariş Özeti
              const Text(
                'Sipariş Özeti',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Hizmet',
                      widget.serviceName,
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Tarih & Saat',
                      '${widget.date} - ${widget.time}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _buildSummaryRow(
                      'Hizmet Tutarı',
                      '₺${basePrice.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Hizmet Bedeli',
                      '₺${serviceFee.toStringAsFixed(2)}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _buildSummaryRow(
                      'Toplam',
                      '₺${totalPrice.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 2. Kart Bilgileri (Tasarım aynı kalıyor)
              const Row(
                children: [
                  Icon(Icons.credit_card, color: AppTheme.darkGreen),
                  SizedBox(width: 8),
                  Text(
                    'Kart Bilgileri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Kart Üzerindeki İsim',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value!.isEmpty ? 'İsim zorunludur' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: const InputDecoration(
                  labelText: 'Kart Numarası',
                  hintText: '0000 0000 0000 0000',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: "",
                ),
                validator: (value) => value!.length < 16
                    ? 'Geçerli bir kart numarası girin'
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                      decoration: const InputDecoration(
                        labelText: 'Son Kullanma',
                        hintText: 'AA/YY',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: "",
                      ),
                      validator: (value) => value!.isEmpty ? 'Zorunlu' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '***',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        counterText: "",
                      ),
                      validator: (value) =>
                          value!.length < 3 ? 'Zorunlu' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 3. Ödeme Butonu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    '₺${totalPrice.toStringAsFixed(2)} Öde',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      '256-bit SSL ile güvenli ödeme',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey[700],
            fontSize: isTotal ? 18 : 14,
            fontWeight: (isBold || isTotal)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppTheme.primaryGreen : Colors.black,
            fontSize: isTotal ? 18 : 14,
            fontWeight: (isBold || isTotal)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
