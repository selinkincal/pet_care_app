// owner_create_booking_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'owner_payment_screen.dart';

class OwnerCreateBookingScreen extends StatefulWidget {
  final String serviceName;
  final String price;

  // نمرر اسم الخدمة والسعر من الصفحة السابقة
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

  final List<String> _myPets = ['Max (Köpek)', 'Mia (Kedi)'];
  final List<String> _availableTimes = ['10:00', '13:30', '15:00', '17:00'];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _confirmBooking() {
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

    // الانتقال إلى صفحة الدفع
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerPaymentScreen(
          serviceName: widget.serviceName,
          price: widget.price,
          date: _selectedDate!,
          time: _selectedTime!,
        ),
      ),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة ملخص الخدمة
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

            // 1. اختيار الحيوان الأليف
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
              items: _myPets
                  .map((pet) => DropdownMenuItem(value: pet, child: Text(pet)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedPet = val),
            ),
            const SizedBox(height: 24),

            // 2. اختيار التاريخ
            const Text(
              'Tarih Seçin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                // فتح تقويم النظام لاختيار تاريخ
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
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

            // 3. اختيار الوقت
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
                    setState(() => _selectedTime = selected ? time : null);
                  },
                  selectedColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 4. ملاحظات إضافية
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

            // زر التأكيد
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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
