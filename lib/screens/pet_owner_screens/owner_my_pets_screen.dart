// owner_my_pets_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Firebase kütüphaneleri
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';

class MyPetsScreen extends StatefulWidget {
  const MyPetsScreen({super.key});

  @override
  State<MyPetsScreen> createState() => _MyPetsScreenState();
}

class _MyPetsScreenState extends State<MyPetsScreen> {
  // Firebase örnekleri
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Yeni Hayvan Ekleme İşlemi (Firestore)
  Future<void> _addPet() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddPetDialog(),
    );

    if (result != null) {
      try {
        final String? uid = _auth.currentUser?.uid;
        if (uid != null) {
          // Dialog'dan gelen sahte ID'yi siliyoruz, çünkü Firestore kendi eşsiz ID'sini üretecek
          result.remove('id');

          // Veriyi users -> [UID] -> pets -> [Otomatik_ID] yoluna ekliyoruz
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('pets')
              .add(result);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result['name']} başarıyla eklendi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Hayvan ekleme hatası: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bir hata oluştu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 2. Hayvan Düzenleme İşlemi (Firestore Update)
  void _editPet(String docId, Map<String, dynamic> currentPet) async {
    // Mevcut verileri Dialog'a gönderiyoruz
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddPetDialog(pet: currentPet),
    );

    if (result != null) {
      try {
        final String? uid = _auth.currentUser?.uid;
        if (uid != null) {
          result.remove('id'); // Belge ID'sini verinin içinde tutmaya gerek yok

          // Mevcut belgeyi güncelliyoruz
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('pets')
              .doc(docId)
              .update(result);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result['name']} güncellendi'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } catch (e) {
        debugPrint('Hayvan güncelleme hatası: $e');
      }
    }
  }

  // 3. Hayvan Silme İşlemi (Firestore Delete)
  void _deletePet(String docId, String petName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hayvanı Sil'),
        content: const Text('Bu hayvanı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final String? uid = _auth.currentUser?.uid;
        if (uid != null) {
          // Firestore'dan kalıcı olarak sil
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('pets')
              .doc(docId)
              .delete();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$petName silindi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Silme hatası: $e');
      }
    }
  }

  void _viewPetDetail(Map<String, dynamic> pet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PetDetailSheet(pet: pet),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evcil Hayvanlarım'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _addPet)],
      ),
      // 4. StreamBuilder ile Canlı Dinleme
      body: currentUserId == null
          ? const Center(child: Text('Lütfen giriş yapın.'))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(currentUserId)
                  .collection('pets')
                  .snapshots(),
              builder: (context, snapshot) {
                // Yüklenme durumu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                // Hata durumu
                if (snapshot.hasError) {
                  return Center(child: Text('Hata oluştu: ${snapshot.error}'));
                }

                // Veri yoksa
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz evcil hayvan eklemediniz',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _addPet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                          ),
                          child: const Text(
                            'Hayvan Ekle',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final pets = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final petDoc = pets[index];
                    final petData = petDoc.data() as Map<String, dynamic>;

                    return _buildPetCard(petData, petDoc.id);
                  },
                );
              },
            ),
    );
  }

  // Kartı oluştururken artık Firestore Belge ID'sini (docId) parametre olarak alıyoruz
  Widget _buildPetCard(Map<String, dynamic> pet, String docId) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _viewPetDetail(pet),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  shape: BoxShape.circle,
                  image:
                      pet['imagePath'] != null &&
                          pet['imagePath'].toString().isNotEmpty &&
                          File(pet['imagePath']).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(pet['imagePath'])),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    pet['imagePath'] == null ||
                        pet['imagePath'].toString().isEmpty ||
                        !File(pet['imagePath']).existsSync()
                    ? const Icon(
                        Icons.pets,
                        size: 35,
                        color: AppTheme.primaryGreen,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'] ?? 'İsimsiz',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getAnimalEmoji(pet['type'] ?? '')} ${pet['type'] ?? ''} • ${pet['breed'] ?? ''}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.cake, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          _getAge(pet['birthDate'] ?? ''),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pet['weight'] ?? '0'} kg',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: pet['gender'] == 'Erkek'
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.pink.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pet['gender'] == 'Erkek' ? '♂️ Erkek' : '♀️ Dişi',
                      style: TextStyle(
                        fontSize: 11,
                        color: pet['gender'] == 'Erkek'
                            ? Colors.blue
                            : Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.grey,
                        ),
                        // Düzenleme fonksiyonuna Belge ID'sini gönderiyoruz
                        onPressed: () => _editPet(docId, pet),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.red,
                        ),
                        // Silme fonksiyonuna Belge ID'sini gönderiyoruz
                        onPressed: () =>
                            _deletePet(docId, pet['name'] ?? 'Hayvan'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAnimalEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'köpek':
        return '🐕';
      case 'kedi':
        return '🐈';
      case 'kuş':
        return '🐦';
      case 'hamster':
        return '🐹';
      case 'tavşan':
        return '🐇';
      default:
        return '🐾';
    }
  }

  String _getAge(String birthDate) {
    if (birthDate.isEmpty) return 'Yaş bilgisi yok';
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return '$age yaşında';
    } catch (e) {
      return birthDate;
    }
  }
}

// PET DETAIL SHEET
class PetDetailSheet extends StatelessWidget {
  final Map<String, dynamic> pet;
  const PetDetailSheet({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  shape: BoxShape.circle,
                  image:
                      pet['imagePath'] != null &&
                          pet['imagePath'].toString().isNotEmpty &&
                          File(pet['imagePath']).existsSync()
                      ? DecorationImage(
                          image: FileImage(File(pet['imagePath'])),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    pet['imagePath'] == null ||
                        pet['imagePath'].toString().isEmpty ||
                        !File(pet['imagePath']).existsSync()
                    ? const Icon(
                        Icons.pets,
                        size: 50,
                        color: AppTheme.primaryGreen,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                pet['name'] ?? 'İsimsiz',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Tür',
              '${_getAnimalEmoji(pet['type'] ?? '')} ${pet['type'] ?? ''}',
            ),
            _buildDetailRow('Cins', pet['breed'] ?? ''),
            _buildDetailRow(
              'Cinsiyet',
              pet['gender'] == 'Erkek' ? '♂️ Erkek' : '♀️ Dişi',
            ),
            _buildDetailRow('Doğum Tarihi', pet['birthDate'] ?? ''),
            _buildDetailRow('Kilo', '${pet['weight'] ?? '0'} kg'),
            _buildDetailRow('Renk', pet['color'] ?? ''),
            if (pet['microchip'] != null &&
                pet['microchip'].toString().isNotEmpty)
              _buildDetailRow('Mikroçip No', pet['microchip']),
            if (pet['allergies'] != null &&
                pet['allergies'].toString().isNotEmpty)
              _buildDetailRow('Alerjiler', pet['allergies']),
            if (pet['notes'] != null && pet['notes'].toString().isNotEmpty)
              _buildDetailRow('Notlar', pet['notes']),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kapat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getAnimalEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'köpek':
        return '🐕';
      case 'kedi':
        return '🐈';
      case 'kuş':
        return '🐦';
      case 'hamster':
        return '🐹';
      case 'tavşan':
        return '🐇';
      default:
        return '🐾';
    }
  }
}

// ADD/EDIT PET DIALOG
class AddPetDialog extends StatefulWidget {
  final Map<String, dynamic>? pet;
  const AddPetDialog({super.key, this.pet});

  @override
  State<AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();
  final _microchipController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _notesController = TextEditingController();

  String _gender = 'Erkek';
  DateTime _selectedDate = DateTime.now();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!['name'] ?? '';
      _typeController.text = widget.pet!['type'] ?? '';
      _breedController.text = widget.pet!['breed'] ?? '';
      _gender = widget.pet!['gender'] ?? 'Erkek';
      _weightController.text = widget.pet!['weight'] ?? '';
      _colorController.text = widget.pet!['color'] ?? '';
      _microchipController.text = widget.pet!['microchip'] ?? '';
      _allergiesController.text = widget.pet!['allergies'] ?? '';
      _notesController.text = widget.pet!['notes'] ?? '';
      _imagePath = widget.pet!['imagePath'] ?? '';
      if (widget.pet!['birthDate'] != null &&
          widget.pet!['birthDate'].isNotEmpty) {
        _selectedDate =
            DateTime.tryParse(widget.pet!['birthDate']) ?? DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _colorController.dispose();
    _microchipController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Resim seçme hatası: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pet == null ? 'Hayvan Ekle' : 'Hayvan Düzenle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    shape: BoxShape.circle,
                    image:
                        _imagePath != null &&
                            _imagePath!.isNotEmpty &&
                            File(_imagePath!).existsSync()
                        ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      _imagePath == null ||
                          _imagePath!.isEmpty ||
                          !File(_imagePath!).existsSync()
                      ? const Icon(
                          Icons.camera_alt,
                          size: 30,
                          color: AppTheme.primaryGreen,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Resim eklemek için tıklayın\n(Not: Şu an cihaz hafızasına kaydeder)', // 👈 İleride Firebase Storage'a geçirilecek
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hayvan Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Tür (Köpek, Kedi, Kuş vs.)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Cins',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kilo (kg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(
                        labelText: 'Renk',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Cinsiyet',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Erkek',
                          child: Text('♂️ Erkek'),
                        ),
                        DropdownMenuItem(value: 'Dişi', child: Text('♀️ Dişi')),
                      ],
                      onChanged: (value) => setState(() => _gender = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                            text:
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Doğum Tarihi',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _microchipController,
                decoration: const InputDecoration(
                  labelText: 'Mikroçip No (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'Alerjiler (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notlar (Opsiyonel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Dialog'dan sadece girilen verileri Map olarak döndürüyoruz.
              // Firestore'a kaydetme işlemini asıl sayfadaki _addPet veya _editPet fonksiyonu hallediyor.
              Navigator.pop(context, {
                'name': _nameController.text,
                'type': _typeController.text,
                'breed': _breedController.text,
                'gender': _gender,
                'birthDate': _selectedDate.toIso8601String().split('T')[0],
                'weight': _weightController.text,
                'color': _colorController.text,
                'microchip': _microchipController.text,
                'allergies': _allergiesController.text,
                'notes': _notesController.text,
                'imagePath': _imagePath ?? '',
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
          ),
          child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
