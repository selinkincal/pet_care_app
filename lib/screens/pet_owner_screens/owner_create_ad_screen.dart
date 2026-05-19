// owner_create_ad_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Firebase kütüphanelerini ekliyoruz
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';

class OwnerCreateAdScreen extends StatefulWidget {
  // Düzenleme (Edit) modu için opsiyonel veri parametresi
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

  // Yüklenme animasyonunu kontrol etmek için değişken
  bool _isLoading = false;
  bool _isLoadingPets = true; // Hayvanlar yüklenirken gösterilecek

  // Firebase'den gelecek evcil hayvanlar listesi
  List<Map<String, dynamic>> _myPetsList = [];

  // Sadece evcil hayvan isimlerini tutacak liste (Dropdown için)
  List<String> _petNames = [];

  final List<String> _serviceTypes = [
    'Köpek Yürüyüşü',
    'Evde Bakım',
    'Veteriner Ziyareti',
    'Eğitim',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserPets(); // Firebase'den hayvanları çek
  }

  // Kullanıcının evcil hayvanlarını Firebase'den çeken fonksiyon
  Future<void> _fetchUserPets() async {
    setState(() {
      _isLoadingPets = true;
    });

    try {
      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        debugPrint('Kullanıcı oturumu bulunamadı');
        setState(() {
          _isLoadingPets = false;
        });
        return;
      }

      // Firestore'dan kullanıcının evcil hayvanlarını çek
      QuerySnapshot petsSnapshot = await FirebaseFirestore.instance
          .collection('pets') // 'pets' koleksiyonunuzun adı
          .where('ownerId', isEqualTo: userId) // Sahip ID'sine göre filtrele
          .get();

      // Gelen verileri listeye dönüştür
      _myPetsList = petsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? 'İsimsiz Evcil Hayvan',
          'type': doc['type'] ?? '',
          'breed': doc['breed'] ?? '',
          'age': doc['age'] ?? '',
          // Diğer alanlarınız varsa ekleyin
        };
      }).toList();

      // Sadece isimleri al (Dropdown için)
      _petNames = _myPetsList.map((pet) => pet['name'] as String).toList();

      // Düzenleme modundaysak ve seçili bir evcil hayvan varsa
      if (widget.adData != null && widget.adData!['pet'] != null) {
        final savedPetName = widget.adData!['pet'];
        if (_petNames.contains(savedPetName)) {
          _selectedPet = savedPetName;
        }
      }
    } catch (e) {
      debugPrint('Evcil hayvanlar yüklenirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evcil hayvanlarınız yüklenemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
        });
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

  // Firestore'a Veri Kaydetme veya Güncelleme İşlemi
  Future<void> _submitAd() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final String? ownerId = FirebaseAuth.instance.currentUser?.uid;
        if (ownerId == null) throw Exception('Kullanıcı oturumu bulunamadı.');

        // Seçilen evcil hayvanın tam verilerini bul
        final selectedPetData = _myPetsList.firstWhere(
          (pet) => pet['name'] == _selectedPet,
          orElse: () => {},
        );

        // Firebase'e gönderilecek veriyi hazırlıyoruz
        final Map<String, dynamic> adDataMap = {
          'ownerId': ownerId,
          'title': _titleController.text,
          'petId': selectedPetData['id'], // Evcil hayvan ID'sini de kaydet
          'pet': _selectedPet, // Evcil hayvan ismi
          'petType':
              selectedPetData['type'], // Evcil hayvan türü (köpek, kedi vs.)
          'service': _selectedServiceType,
          'date': _dateController.text,
          'time': _timeController.text,
          'location': _locationController.text,
          'budget': double.tryParse(_budgetController.text) ?? 0.0,
          'details': _detailsController.text,
          'imagePath': _selectedImage?.path ?? '',
          'isActive': widget.adData != null ? widget.adData!['isActive'] : true,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (widget.adData != null && widget.adData!['id'] != null) {
          // DÜZENLEME MODU (Update)
          String docId = widget.adData!['id'];
          await FirebaseFirestore.instance
              .collection('ads')
              .doc(docId)
              .update(adDataMap);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('İlan başarıyla güncellendi!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // YENİ İLAN MODU (Create)
          adDataMap['createdAt'] = FieldValue.serverTimestamp();

          await FirebaseFirestore.instance.collection('ads').add(adDataMap);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yeni ilan yayınlandı!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        debugPrint('İlan kaydedilirken hata oluştu: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('İlan kaydedilemedi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

                // Resim seçme alanı
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

                // Başlık alanı
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

                // Evcil Hayvan Seçimi - Firebase'den çekilen verilerle
                _isLoadingPets
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _petNames.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.pets, color: Colors.orange),
                            const SizedBox(height: 8),
                            Text(
                              'Henüz kayıtlı evcil hayvanınız bulunmuyor.',
                              style: TextStyle(color: Colors.orange[800]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Evcil hayvan ekleme sayfasına yönlendirme
                                // Navigator.pushNamed(context, '/add-pet');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                              ),
                              child: const Text('Evcil Hayvan Ekle'),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Hangi Evcil Hayvanınız İçin?',
                          prefixIcon: Icon(Icons.pets),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        value: _selectedPet,
                        hint: const Text('Seçiniz'),
                        items: _petNames.map((String petName) {
                          // Evcil hayvanın türünü de göster (opsiyonel)
                          final petData = _myPetsList.firstWhere(
                            (pet) => pet['name'] == petName,
                          );
                          return DropdownMenuItem(
                            value: petName,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  petName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (petData['type'] != null)
                                  Text(
                                    petData['type'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) =>
                            setState(() => _selectedPet = newValue),
                        validator: (value) => value == null
                            ? 'Lütfen bir evcil hayvan seçin'
                            : null,
                      ),
                const SizedBox(height: 16),

                // Hizmet Türü Seçimi
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

                // Tarih ve Saat alanları
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

                // Konum alanı
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

                // Bütçe alanı
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

                // Detaylar alanı
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

                // Gönder butonu
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isLoadingPets)
                        ? null
                        : _submitAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
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
