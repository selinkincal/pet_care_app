// owner_service_list_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firebase kütüphanelerini ekliyoruz
import 'package:cloud_firestore/cloud_firestore.dart';

import 'owner_service_detail_screen.dart';
import '../../core/theme/app_theme.dart';

class OwnerServiceListScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialSearchQuery;

  const OwnerServiceListScreen({
    super.key,
    this.initialCategory,
    this.initialSearchQuery,
  });

  @override
  State<OwnerServiceListScreen> createState() => _OwnerServiceListScreenState();
}

class _OwnerServiceListScreenState extends State<OwnerServiceListScreen> {
  // 🔥 Firebase ID'leri String (Metin) olduğu için List<String> kullanıyoruz
  List<String> _favoriteIds = [];
  late TextEditingController _searchController;

  // Filtre Değişkenleri
  String _selectedCategory = 'Tümü';
  String _selectedAnimalType = 'Tümü';
  String _selectedCity = 'İstanbul';
  String _selectedDistrict = 'Tümü';
  RangeValues _priceRange = const RangeValues(0, 1000);
  double _selectedRating = 0;
  String _selectedSort = 'Önerilen';
  String _searchQuery = '';

  final List<String> _categories = [
    'Tümü',
    'Bakım',
    'Yürüyüş',
    'Veteriner',
    'Pansiyon',
  ];
  final List<String> _animalTypes = [
    'Tümü',
    '🐕 Köpek',
    '🐈 Kedi',
    '🐦 Kuş',
    '🐹 Hamster',
    '🐇 Tavşan',
    'Diğer',
  ];
  final List<String> _sortOptions = [
    'Önerilen',
    'Fiyat (Artan)',
    'Fiyat (Azalan)',
    'Puan (Yüksek)',
    'En Yakın',
  ];

  final List<String> _districts = [
    'Tümü',
    'Kadıköy',
    'Beşiktaş',
    'Üsküdar',
    'Maltepe',
    'Kartal',
    'Pendik',
    'Bakırköy',
    'Şişli',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();

    if (widget.initialCategory != null && widget.initialCategory != 'Tümü') {
      _selectedCategory = widget.initialCategory!;
    }
    if (widget.initialSearchQuery != null) {
      _searchQuery = widget.initialSearchQuery!;
    }

    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favoriteIds = favorites; // Artık String kullanıyoruz
    });
  }

  Future<void> _toggleFavorite(String serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      if (favorites.contains(serviceId)) {
        favorites.remove(serviceId);
      } else {
        favorites.add(serviceId);
      }
    });

    await prefs.setStringList('favorites', favorites);
    await _loadFavorites();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          favorites.contains(serviceId)
              ? 'Beğenilere eklendi'
              : 'Beğenilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: favorites.contains(serviceId)
            ? AppTheme.primaryGreen
            : Colors.grey[700],
      ),
    );
  }

  // 🔥 Firestore'dan gelen verileri yerel filtrelerimizden geçiren fonksiyon
  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> allServices,
  ) {
    var filtered = List.from(allServices);

    // Arama Kelimesi Filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((service) {
        final title = (service['title'] ?? '').toString().toLowerCase();
        final location = (service['location'] ?? '').toString().toLowerCase();
        return title.contains(_searchQuery.toLowerCase()) ||
            location.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Kategori Filtresi
    if (_selectedCategory != 'Tümü') {
      filtered = filtered
          .where((service) => service['category'] == _selectedCategory)
          .toList();
    }

    // Hayvan Türü Filtresi (Tümü'ne veya seçilen türe izin ver)
    if (_selectedAnimalType != 'Tümü') {
      filtered = filtered
          .where(
            (service) =>
                service['animalType'] == _selectedAnimalType ||
                service['animalType'] == 'Tümü',
          )
          .toList();
    }

    // İlçe Filtresi
    if (_selectedDistrict != 'Tümü') {
      // Veritabanındaki 'location' veya 'district' alanına göre arama (şimdilik location içinde arayalım)
      filtered = filtered.where((service) {
        final loc = (service['location'] ?? '').toString().toLowerCase();
        return loc.contains(_selectedDistrict.toLowerCase());
      }).toList();
    }

    // Fiyat Aralığı Filtresi (Firebase'den String gelebileceği için güvenli dönüştürme yapıyoruz)
    filtered = filtered.where((service) {
      double price =
          double.tryParse(service['price']?.toString() ?? '0') ?? 0.0;
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Puan Filtresi
    if (_selectedRating > 0) {
      filtered = filtered.where((service) {
        double rating =
            double.tryParse(service['rating']?.toString() ?? '0') ?? 0.0;
        return rating >= _selectedRating;
      }).toList();
    }

    // Sıralama (Sorting)
    switch (_selectedSort) {
      case 'Fiyat (Artan)':
        filtered.sort((a, b) {
          double priceA = double.tryParse(a['price']?.toString() ?? '0') ?? 0.0;
          double priceB = double.tryParse(b['price']?.toString() ?? '0') ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Fiyat (Azalan)':
        filtered.sort((a, b) {
          double priceA = double.tryParse(a['price']?.toString() ?? '0') ?? 0.0;
          double priceB = double.tryParse(b['price']?.toString() ?? '0') ?? 0.0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'Puan (Yüksek)':
        filtered.sort((a, b) {
          double ratingA =
              double.tryParse(a['rating']?.toString() ?? '0') ?? 0.0;
          double ratingB =
              double.tryParse(b['rating']?.toString() ?? '0') ?? 0.0;
          return ratingB.compareTo(ratingA);
        });
        break;
      case 'Önerilen':
      case 'En Yakın':
        // Özel algoritma buraya eklenebilir
        break;
    }

    return List<Map<String, dynamic>>.from(filtered);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return DraggableScrollableSheet(
              initialChildSize: 0.95,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Filtrele ve Sırala',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '📍 Konum',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCity,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'İstanbul',
                                    child: Text('İstanbul'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setStateBottomSheet(() {
                                    _selectedCity = value!;
                                    _selectedDistrict = 'Tümü';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedDistrict,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items: _districts
                                    .map(
                                      (district) => DropdownMenuItem(
                                        value: district,
                                        child: Text(district),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => setStateBottomSheet(
                                  () => _selectedDistrict = value!,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text(
                          '📂 Kategori',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: _categories
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(category),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setStateBottomSheet(
                                () => _selectedCategory = value!,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        const Text(
                          '🐾 Hayvan Türü',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _animalTypes.map((type) {
                            return FilterChip(
                              label: Text(type),
                              selected: _selectedAnimalType == type,
                              onSelected: (selected) => setStateBottomSheet(
                                () => _selectedAnimalType = selected
                                    ? type
                                    : 'Tümü',
                              ),
                              selectedColor: AppTheme.lightGreen,
                              checkmarkColor: AppTheme.primaryGreen,
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        const Text(
                          '💰 Fiyat Aralığı (TL)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          activeColor: AppTheme.primaryGreen,
                          inactiveColor: Colors.grey[300],
                          labels: RangeLabels(
                            '${_priceRange.start.round()} TL',
                            '${_priceRange.end.round()} TL',
                          ),
                          onChanged: (values) =>
                              setStateBottomSheet(() => _priceRange = values),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₺${_priceRange.start.round()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₺${_priceRange.end.round()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text(
                          '⭐ Minimum Puan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                onPressed: () => setStateBottomSheet(
                                  () => _selectedRating = index + 1.toDouble(),
                                ),
                              );
                            }),
                            const SizedBox(width: 8),
                            if (_selectedRating > 0)
                              TextButton(
                                onPressed: () => setStateBottomSheet(
                                  () => _selectedRating = 0,
                                ),
                                child: const Text('Temizle'),
                              ),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text(
                          '📊 Sıralama',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSort,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: _sortOptions
                                  .map(
                                    (sort) => DropdownMenuItem(
                                      value: sort,
                                      child: Text(sort),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) => setStateBottomSheet(
                                () => _selectedSort = value!,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setStateBottomSheet(() {
                                    _selectedCategory = 'Tümü';
                                    _selectedAnimalType = 'Tümü';
                                    _selectedCity = 'İstanbul';
                                    _selectedDistrict = 'Tümü';
                                    _priceRange = const RangeValues(0, 1000);
                                    _selectedRating = 0;
                                    _selectedSort = 'Önerilen';
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppTheme.primaryGreen,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text('Tümünü Temizle'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // Ana ekranı güncelle
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  'Sonuçları Göster',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
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
        title: const Text('Hizmetler'),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Hizmet ara...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          if (_selectedCategory != 'Tümü' ||
              _selectedAnimalType != 'Tümü' ||
              _selectedDistrict != 'Tümü' ||
              _priceRange.start != 0 ||
              _priceRange.end != 1000 ||
              _selectedRating > 0 ||
              _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Aktif: ', style: TextStyle(fontSize: 12)),
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Text(_searchQuery),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      ),
                    if (_selectedCategory != 'Tümü')
                      Chip(
                        label: Text(_selectedCategory),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedCategory = 'Tümü'),
                      ),
                    if (_selectedDistrict != 'Tümü')
                      Chip(
                        label: Text(_selectedDistrict),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedDistrict = 'Tümü'),
                      ),
                    if (_selectedAnimalType != 'Tümü')
                      Chip(
                        label: Text(_selectedAnimalType),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedAnimalType = 'Tümü'),
                      ),
                    if (_priceRange.start != 0 || _priceRange.end != 1000)
                      Chip(
                        label: Text(
                          '${_priceRange.start.round()}-${_priceRange.end.round()} TL',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(
                          () => _priceRange = const RangeValues(0, 1000),
                        ),
                      ),
                    if (_selectedRating > 0)
                      Chip(
                        label: Text('$_selectedRating+⭐'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _selectedRating = 0),
                      ),
                  ],
                ),
              ),
            ),

          // 🔥 Firestore'dan Veri Çeken ve Yerel Olarak Filtreleyen Yapı
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('services')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Hata oluştu: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Hiç hizmet bulunamadı.'));
                }

                // 1. Gelen dokümanları (documents) Map listesine çevir
                List<Map<String, dynamic>> rawServices = snapshot.data!.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id; // Belge ID'sini ekliyoruz
                      return data;
                    })
                    .toList();

                // 2. Kendi yazdığımız akıllı filtreleme fonksiyonundan geçir
                final filteredServices = _applyFilters(rawServices);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${filteredServices.length} hizmet bulundu',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: filteredServices.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Sonuç bulunamadı',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredServices.length,
                              itemBuilder: (context, index) =>
                                  _buildServiceCard(
                                    context,
                                    filteredServices[index],
                                  ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Kart Bileşeni
  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    // Firestore'da ID'ler String olduğu için dönüşüm yaptık
    final String serviceId = service['id'];
    final bool isFavorite = _favoriteIds.contains(serviceId);

    // Boş olabilecek değerleri koruma altına alıyoruz
    final String title = service['title'] ?? 'İsimsiz Hizmet';
    final String location = service['location'] ?? 'Konum Belirtilmemiş';
    final String price = service['price']?.toString() ?? '0';
    final String rating = service['rating']?.toString() ?? '5.0';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // 🔥 Tıklanan hizmetin GERÇEK bilgilerini Detay Sayfasına yolluyoruz
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OwnerServiceDetailScreen(
                serviceData: service,
                serviceId: serviceId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 40,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 $location',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(rating),
                        const SizedBox(width: 12),
                        Text(
                          '₺$price',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey[400],
                ),
                onPressed: () => _toggleFavorite(serviceId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
