// owner_create_ad_screen.dart - DÜZELTİLMİŞ VERSİYON
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OwnerCreateAdScreen extends StatefulWidget {
  const OwnerCreateAdScreen({super.key});

  @override
  State<OwnerCreateAdScreen> createState() => _OwnerCreateAdScreenState();
}

class _OwnerCreateAdScreenState extends State<OwnerCreateAdScreen> {
  final _formKey = GlobalKey<FormState>();

  // Değişkenler - initialValue için controller kullanıyoruz
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? _selectedServiceType;
  String? _selectedPet;

  final List<String> _serviceTypes = [
    'Köpek Yürüyüşü',
    'Evde Bakım',
    'Veteriner Ziyareti',
    'Eğitim',
  ];
  final List<String> _myPets = ['Max (Köpek)', 'Mia (Kedi)', 'Paşa (Kuş)'];

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Ver'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hizmet İhtiyacınızı Belirtin',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Evcil hayvanınız için ihtiyacınız olan hizmetin detaylarını aşağıya giriniz.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // İlan Başlığı
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'İlan Başlığı',
                    hintText: 'Örn: Hafta sonu için köpek gezdirici aranıyor',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Bu alan zorunludur'
                      : null,
                ),
                const SizedBox(height: 16),

                // Evcil Hayvan Seçimi - initialValue kullanıldı
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Hangi Evcil Hayvanınız İçin?',
                    prefixIcon: Icon(Icons.pets),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedPet,
                  hint: const Text('Seçiniz'),
                  items: _myPets.map((String pet) {
                    return DropdownMenuItem<String>(
                      value: pet,
                      child: Text(pet),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPet = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Lütfen bir evcil hayvan seçin' : null,
                ),
                const SizedBox(height: 16),

                // Hizmet Türü Seçimi - initialValue kullanıldı
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Hizmet Türü',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedServiceType,
                  hint: const Text('Seçiniz'),
                  items: _serviceTypes.map((String service) {
                    return DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedServiceType = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Lütfen bir hizmet türü seçin' : null,
                ),
                const SizedBox(height: 16),

                // Tarih ve Saat
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          labelText: 'Tarih',
                          hintText: 'GG/AA/YYYY',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Tarih seçiniz'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        onTap: () => _selectTime(context),
                        decoration: const InputDecoration(
                          labelText: 'Saat',
                          hintText: '14:30',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Saat seçiniz'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Konum
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Konum',
                    hintText: 'Örn: Kadıköy, Moda',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Konum giriniz' : null,
                ),
                const SizedBox(height: 16),

                // Bütçe
                TextFormField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bütçe (TL)',
                    hintText: 'Örn: 300',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Bütçe giriniz' : null,
                ),
                const SizedBox(height: 16),

                // Detaylar
                TextFormField(
                  controller: _detailsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Detaylar ve Özel İstekler',
                    hintText:
                        'Köpeğim çok enerjiktir, parkta oyun oynamayı sever...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Yayınla Butonu
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitAd();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İlanı Yayınla',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitAd() {
    // İlan verilerini göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlan Yayınlandı!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Başlık: ${_titleController.text}'),
            Text('Evcil Hayvan: $_selectedPet'),
            Text('Hizmet: $_selectedServiceType'),
            Text('Tarih: ${_dateController.text} ${_timeController.text}'),
            Text('Konum: ${_locationController.text}'),
            Text('Bütçe: ${_budgetController.text} TL'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _dateController.clear();
    _timeController.clear();
    _locationController.clear();
    _budgetController.clear();
    _detailsController.clear();
    setState(() {
      _selectedPet = null;
      _selectedServiceType = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İlanınız başarıyla yayınlandı!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
