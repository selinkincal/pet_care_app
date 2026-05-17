// provider_create_service_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class ProviderCreateServiceScreen extends StatefulWidget {
  // 👈 إضافة متغير لاستقبال بيانات الخدمة للتعديل
  final Map<String, dynamic>? serviceData;

  const ProviderCreateServiceScreen({super.key, this.serviceData});

  @override
  State<ProviderCreateServiceScreen> createState() =>
      _ProviderCreateServiceScreenState();
}

class _ProviderCreateServiceScreenState
    extends State<ProviderCreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _categories = [
    'Köpek Yürüyüşü',
    'Evde Bakım',
    'Veteriner Ziyareti',
    'Eğitim',
    'Kuaför/Temizlik',
  ];

  @override
  void initState() {
    super.initState();
    // 👈 تعبئة الحقول إذا كنا في وضع التعديل
    if (widget.serviceData != null) {
      final s = widget.serviceData!;
      _titleController.text = s['title'] ?? '';
      _priceController.text = s['price']?.toString() ?? '';
      _durationController.text = s['duration'] ?? '';
      _locationController.text = s['location'] ?? '';
      _descriptionController.text = s['description'] ?? '';
      
      if (_categories.contains(s['category'])) {
        _selectedCategory = s['category'];
      }

      if (s['imagePath'] != null && s['imagePath'].toString().isNotEmpty) {
        final imgFile = File(s['imagePath']);
        if (imgFile.existsSync()) {
          _selectedImage = imgFile;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
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

  void _submitService() {
    if (_formKey.currentState!.validate()) {
      // تجهيز البيانات
      final updatedService = {
        'id': widget.serviceData != null ? widget.serviceData!['id'] : DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'category': _selectedCategory,
        'price': _priceController.text,
        'duration': _durationController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'imagePath': _selectedImage?.path ?? '',
        'isActive': widget.serviceData != null ? widget.serviceData!['isActive'] : true,
      };

      if (widget.serviceData != null) {
        // إذا كنا نعدل، نرجع البيانات مباشرة ونغلق النافذة
        Navigator.pop(context, updatedService);
      } else {
        // إنشاء جديد
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hizmet Yayınlandı!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 8),
                Text('Hizmet: ${_titleController.text}'),
                Text('Kategori: $_selectedCategory'),
                Text('Fiyat: ${_priceController.text} TL / ${_durationController.text}'),
                Text('Konum: ${_locationController.text}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق الـ Dialog
                  Navigator.pop(context, updatedService); // إغلاق الصفحة
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
    final isEditing = widget.serviceData != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isEditing ? 'Hizmeti Düzenle' : 'Yeni Hizmet Ekle'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen,
                        shape: BoxShape.circle,
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        border: Border.all(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                      child: _selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Resim Ekle',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Hizmet Başlığı',
                    hintText: 'Örn: Profesyonel Köpek Yürüyüşü',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Hizmet başlığı giriniz'
                      : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _selectedCategory,
                  hint: const Text('Kategori seçiniz'),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  validator: (value) =>
                      value == null ? 'Kategori seçiniz' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Fiyat (TL)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Fiyat giriniz'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: 'Süre',
                          hintText: '1 saat / günlük',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Süre giriniz'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Hizmet Bölgesi',
                    hintText: 'Örn: Kadıköy, İstanbul',
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
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Hizmet Açıklaması',
                    hintText: 'Hizmetiniz hakkında detaylı bilgi verin...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Açıklama giriniz'
                      : null,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Hizmeti Güncelle' : 'Hizmeti Yayınla',
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