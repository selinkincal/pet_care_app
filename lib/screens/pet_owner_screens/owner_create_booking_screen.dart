// owner_create_booking_screen.dart
import 'package:flutter/material.dart';
// Firebase kütüphanelerini ekliyoruz
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import 'owner_payment_screen.dart';

class OwnerCreateBookingScreen extends StatefulWidget {
  final String serviceName;
  final String price;

  // Önceki sayfadan hizmetin adını ve fiyatını alıyoruz
  const OwnerCreateBookingScreen({
    super.key,
    required this.serviceName,
    required this.price,
  });

  @override
  State<OwnerCreateBookingScreen> createState() =>
      _OwnerCreateBookingScreenState();
}

class _OwnerCreateBookingScreenState extends State<OwnerCreateBookingScreen> {
  String? _selectedPet;
  String? _selectedDate;
  String? _selectedTime;
  final _noteController = TextEditingController();

  // Firestore'dan çekilecek gerçek evcil hayvan listesi
  List<String> _myPets = [];

  // Saatler şimdilik statik kalabilir (İleride hizmet verenin çalışma saatlerine göre de çekilebilir)
  final List<String> _availableTimes = ['10:00', '13:30', '15:00', '17:00'];

  // Yükleme durumlarını kontrol etmek için değişkenler
  bool _isLoadingPets = true;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPets(); // Sayfa açıldığında kullanıcının evcil hayvanlarını getir
  }

  // 1. Kullanıcının kayıtlı evcil hayvanlarını Firestore'dan çeken fonksiyon
  Future<void> _fetchUserPets() async {
    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Kullanıcının belgesini veritabanından al
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          // Kayıt ekranında (register_screen) evcil hayvan detaylarını 'petDetails' içine kaydetmiştik
          if (data.containsKey('petDetails')) {
            final petData = data['petDetails'];
            final String petName = petData['petName'] ?? 'Evcil Hayvanım';
            final String petType = petData['petType'] ?? '';

            setState(() {
              _myPets = ['$petName ($petType)']; // Örn: Karabaş (Köpek)
              _selectedPet = _myPets.first; // Otomatik olarak ilk hayvanı seç
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Evcil hayvanlar çekilirken hata: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPets = false);
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // 2. Randevuyu veritabanına kaydetme ve ödeme sayfasına geçiş
  Future<void> _confirmBooking() async {
    // Form doğrulama
    if (_selectedPet == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tarih, saat ve evcil hayvan seçiminizi yapın.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      final String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Kullanıcı oturumu bulunamadı');

      // Firestore 'bookings' koleksiyonuna "Taslak/Ödeme Bekliyor" statüsüyle kayıt atıyoruz
      // 👈 BURADA OLUŞAN BELGENİN REFERANSINI (bookingRef) YAKALIYORUZ
      DocumentReference
      bookingRef = await FirebaseFirestore.instance.collection('bookings').add({
        'ownerId': uid,
        'service': widget.serviceName,
        'price': widget.price,
        'petName': _selectedPet,
        'date': _selectedDate,
        'time': _selectedTime,
        'notes': _noteController.text.trim(),
        'status':
            'Ödeme Bekliyor', // Kullanıcı ödeme sayfasında işlemi tamamlarsa bu 'Aktif' olacak
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Kayıt başarılıysa Ödeme Sayfasına yönlendiriyoruz
      // 👈 EN ÖNEMLİ DEĞİŞİKLİK BURADA: bookingId parametresini ekledik
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OwnerPaymentScreen(
            bookingId: bookingRef
                .id, // 👈 Firebase'in atadığı eşsiz ID'yi ödeme sayfasına yolluyoruz
            serviceName: widget.serviceName,
            price: widget.price,
            date: _selectedDate!,
            time: _selectedTime!,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Rezervasyon hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Rezervasyon Oluştur'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: _isLoadingPets
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hizmet Özeti Kartı
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.serviceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hizmet Özeti',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            widget.price,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Evcil Hayvan Seçimi (Artık Firestore'dan çekiliyor)
                  const Text(
                    'Hangi evcil hayvanınız için?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.pets),
                    ),
                    hint: const Text('Seçiniz'),
                    value: _selectedPet,
                    items: _myPets.isEmpty
                        ? [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Kayıtlı hayvan bulunamadı'),
                            ),
                          ]
                        : _myPets
                              .map(
                                (pet) => DropdownMenuItem(
                                  value: pet,
                                  child: Text(pet),
                                ),
                              )
                              .toList(),
                    onChanged: (val) => setState(() => _selectedPet = val),
                  ),
                  const SizedBox(height: 24),

                  // 2. Tarih Seçimi
                  const Text(
                    'Tarih Seçin',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppTheme.primaryGreen,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate =
                              "${picked.day}/${picked.month}/${picked.year}";
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate ?? 'Gün / Ay / Yıl',
                            style: TextStyle(
                              color: _selectedDate == null
                                  ? Colors.grey[600]
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Saat Seçimi
                  const Text(
                    'Saat Seçin',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTimes.map((time) {
                      final isSelected = _selectedTime == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(
                            () => _selectedTime = selected ? time : null,
                          );
                        },
                        selectedColor: AppTheme.primaryGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 4. Ek Notlar
                  const Text(
                    'Ek Notlar (İsteğe Bağlı)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          'Hizmet verene iletmek istediğiniz özel bir durum var mı?',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 5. Onay Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isBooking ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isBooking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Rezervasyonu Onayla',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
