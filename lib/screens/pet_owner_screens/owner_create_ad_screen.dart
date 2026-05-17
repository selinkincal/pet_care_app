// owner_create_ad_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class OwnerCreateAdScreen extends StatefulWidget {
  // إضافة متغير اختياري لاستقبال بيانات الإعلان في حال التعديل
  final Map<String, dynamic>? adData;

  const OwnerCreateAdScreen({super.key, this.adData});

  @override
  State<OwnerCreateAdScreen> createState() => _OwnerCreateAdScreenState();
}

class _OwnerCreateAdScreenState extends State<OwnerCreateAdScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? _selectedServiceType;
  String? _selectedPet;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _serviceTypes = [
    'Köpek Yürüyüşü',
    'Evde Bakım',
    'Veteriner Ziyareti',
    'Eğitim',
  ];
  final List<String> _myPets = ['Max (Köpek)', 'Mia (Kedi)', 'Paşa (Kuş)'];

  // دالة التهيئة: هنا نتحقق مما إذا كان هناك بيانات للتعديل ونقوم بتعبئتها
  @override
  void initState() {
    super.initState();
    if (widget.adData != null) {
      final ad = widget.adData!;
      _titleController.text = ad['title'] ?? '';
      _locationController.text = ad['location'] ?? '';
      _budgetController.text = ad['budget']?.toString() ?? '';
      _detailsController.text = ad['details'] ?? '';

      // تفكيك التاريخ والوقت إذا كانا مدمجين
      if (ad['date'] != null) {
        _dateController.text = ad['date'];
      }
      if (ad['time'] != null) {
        _timeController.text = ad['time'];
      }

      // التحقق من القوائم المنسدلة لتجنب الأخطاء
      if (_myPets.contains(ad['pet'])) {
        _selectedPet = ad['pet'];
      }
      if (_serviceTypes.contains(ad['service'])) {
        _selectedServiceType = ad['service'];
      }

      if (ad['imagePath'] != null && ad['imagePath'].toString().isNotEmpty) {
        final imgFile = File(ad['imagePath']);
        if (imgFile.existsSync()) {
          _selectedImage = imgFile;
        }
      }
    }
  }

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

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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

  void _submitAd() {
    if (_formKey.currentState!.validate()) {
      // تجهيز البيانات المحدثة أو الجديدة
      final updatedAdData = {
        'id': widget.adData != null
            ? widget.adData!['id']
            : DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'pet': _selectedPet,
        'service': _selectedServiceType,
        'date': _dateController.text,
        'time': _timeController.text,
        'location': _locationController.text,
        'budget': _budgetController.text,
        'details': _detailsController.text,
        'imagePath': _selectedImage?.path ?? '',
        'isActive': widget.adData != null ? widget.adData!['isActive'] : true,
      };

      // إذا كنا في وضع التعديل، نرجع البيانات مباشرة ونغلق الصفحة
      if (widget.adData != null) {
        Navigator.pop(context, updatedAdData);
      } else {
        // إذا كان إنشاء إعلان جديد، نظهر رسالة النجاح
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('İlan Yayınlandı!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 8),
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
                  Navigator.pop(context); // إغلاق الـ Dialog
                  Navigator.pop(
                    context,
                    updatedAdData,
                  ); // إغلاق الصفحة والعودة للإعلانات
                },
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👈 هذا السطر يكتشف ما إذا كنا في وضع التعديل أم الإنشاء
    final isEditing = widget.adData != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'İlanı Düzenle' : 'Yeni İlan Ver'),
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
                Text(
                  isEditing
                      ? 'İlan Bilgilerini Güncelleyin'
                      : 'Hizmet İhtiyacınızı Belirtin',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Evcil hayvanınız için ihtiyacınız olan hizmetin detaylarını aşağıya giriniz.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Evcil Hayvan Resmi Ekle',
                                style: TextStyle(color: AppTheme.primaryGreen),
                              ),
                              Text(
                                'Resim eklemek için tıklayın',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

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
                    return DropdownMenuItem(value: pet, child: Text(pet));
                  }).toList(),
                  onChanged: (String? newValue) =>
                      setState(() => _selectedPet = newValue),
                  validator: (value) =>
                      value == null ? 'Lütfen bir evcil hayvan seçin' : null,
                ),
                const SizedBox(height: 16),

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
                    return DropdownMenuItem(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                  onChanged: (String? newValue) =>
                      setState(() => _selectedServiceType = newValue),
                  validator: (value) =>
                      value == null ? 'Lütfen bir hizmet türü seçin' : null,
                ),
                const SizedBox(height: 16),

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

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // 👈 التعديل هنا: نستخدم المتغير لتغيير النص ديناميكياً
                    child: Text(
                      isEditing ? 'İlanı Güncelle' : 'İlanı Yayınla',
                      style: const TextStyle(
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
}
