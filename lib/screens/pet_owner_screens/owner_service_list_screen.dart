// owner_service_list_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<int> _favoriteIds = [];
  late TextEditingController _searchController;

  // Filter Variables
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

  // 1. إضافة قائمة البيانات الوهمية (Mock Data)
  final List<Map<String, dynamic>> _allServices = [
    {
      'id': 1,
      'title': 'Profesyonel Köpek Yürüyüşü',
      'category': 'Yürüyüş',
      'animalType': '🐕 Köpek',
      'location': 'Kadıköy, İstanbul',
      'district': 'Kadıköy',
      'price': 250,
      'rating': 4.8,
    },
    {
      'id': 2,
      'title': 'Evde Kedi Bakımı (Günlük)',
      'category': 'Bakım',
      'animalType': '🐈 Kedi',
      'location': 'Beşiktaş, İstanbul',
      'district': 'Beşiktaş',
      'price': 300,
      'rating': 4.9,
    },
    {
      'id': 3,
      'title': 'Veteriner Refakati',
      'category': 'Veteriner',
      'animalType': 'Tümü', // يناسب الجميع
      'location': 'Üsküdar, İstanbul',
      'district': 'Üsküdar',
      'price': 400,
      'rating': 4.5,
    },
    {
      'id': 4,
      'title': 'Köpek Pansiyonu (Haftalık)',
      'category': 'Pansiyon',
      'animalType': '🐕 Köpek',
      'location': 'Maltepe, İstanbul',
      'district': 'Maltepe',
      'price': 900,
      'rating': 3.8,
    },
    {
      'id': 5,
      'title': 'Kuş Kafes Temizliği ve Bakım',
      'category': 'Bakım',
      'animalType': '🐦 Kuş',
      'location': 'Kadıköy, İstanbul',
      'district': 'Kadıköy',
      'price': 150,
      'rating': 4.2,
    },
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
      _favoriteIds = favorites.map((id) => int.parse(id)).toList();
    });
  }

  Future<void> _toggleFavorite(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList('favorites') ?? [];
    final serviceIdStr = serviceId.toString();

    setState(() {
      if (favorites.contains(serviceIdStr)) {
        favorites.remove(serviceIdStr);
      } else {
        favorites.add(serviceIdStr);
      }
    });

    await prefs.setStringList('favorites', favorites);
    await _loadFavorites(); 

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          favorites.contains(serviceIdStr)
              ? 'Beğenilere eklendi'
              : 'Beğenilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: favorites.contains(serviceIdStr) ? AppTheme.primaryGreen : Colors.grey[700],
      ),
    );
  }

  // 2. دالة الفلترة الذكية (نفس منطقك في provider_ads_screen)
  List<Map<String, dynamic>> get _filteredServices {
    var filtered = List.from(_allServices);

    // Search Query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((service) {
        return service['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               service['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Category
    if (_selectedCategory != 'Tümü') {
      filtered = filtered.where((service) => service['category'] == _selectedCategory).toList();
    }

    // Animal Type (مع السماح للخدمات العامة 'Tümü' بالظهور دائماً)
    if (_selectedAnimalType != 'Tümü') {
      filtered = filtered.where((service) => 
        service['animalType'] == _selectedAnimalType || service['animalType'] == 'Tümü'
      ).toList();
    }

    // District
    if (_selectedDistrict != 'Tümü') {
      filtered = filtered.where((service) => service['district'] == _selectedDistrict).toList();
    }

    // Price Range
    filtered = filtered.where((service) {
      double price = (service['price'] as num).toDouble();
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Rating
    if (_selectedRating > 0) {
      filtered = filtered.where((service) {
        double rating = (service['rating'] as num).toDouble();
        return rating >= _selectedRating;
      }).toList();
    }

    // Sorting
    switch (_selectedSort) {
      case 'Fiyat (Artan)':
        filtered.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        break;
      case 'Fiyat (Azalan)':
        filtered.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        break;
      case 'Puan (Yüksek)':
        filtered.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
        break;
      case 'Önerilen':
      case 'En Yakın':
        // يمكنك لاحقاً تطبيق خوارزمية جغرافية هنا
        break;
    }

    return List<Map<String, dynamic>>.from(filtered);
  }

  void _showFilterSheet() {
    // ... [لا تغيير في كود BottomSheet الذي أرسلته، فهو ممتاز كما هو] ...
    // لقد تركت دالة _showFilterSheet كما هي تماماً لأنها مصممة بشكل رائع
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
                            const Text('Filtrele ve Sırala', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('📍 Konum', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCity,
                                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                items: const [DropdownMenuItem(value: 'İstanbul', child: Text('İstanbul'))],
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
                                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                items: _districts.map((district) => DropdownMenuItem(value: district, child: Text(district))).toList(),
                                onChanged: (value) => setStateBottomSheet(() => _selectedDistrict = value!),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text('📂 Kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                              onChanged: (value) => setStateBottomSheet(() => _selectedCategory = value!),
                            ),
                          ),
                        ),
                        const Divider(height: 32),
                        const Text('🐾 Hayvan Türü', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _animalTypes.map((type) {
                            return FilterChip(
                              label: Text(type),
                              selected: _selectedAnimalType == type,
                              onSelected: (selected) => setStateBottomSheet(() => _selectedAnimalType = selected ? type : 'Tümü'),
                              selectedColor: AppTheme.lightGreen,
                              checkmarkColor: AppTheme.primaryGreen,
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),
                        const Text('💰 Fiyat Aralığı (TL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          activeColor: AppTheme.primaryGreen,
                          inactiveColor: Colors.grey[300],
                          labels: RangeLabels('${_priceRange.start.round()} TL', '${_priceRange.end.round()} TL'),
                          onChanged: (values) => setStateBottomSheet(() => _priceRange = values),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₺${_priceRange.start.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('₺${_priceRange.end.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text('⭐ Minimum Puan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(index < _selectedRating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                                onPressed: () => setStateBottomSheet(() => _selectedRating = index + 1.toDouble()),
                              );
                            }),
                            const SizedBox(width: 8),
                            if (_selectedRating > 0)
                              TextButton(onPressed: () => setStateBottomSheet(() => _selectedRating = 0), child: const Text('Temizle')),
                          ],
                        ),
                        const Divider(height: 32),
                        const Text('📊 Sıralama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSort,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: _sortOptions.map((sort) => DropdownMenuItem(value: sort, child: Text(sort))).toList(),
                              onChanged: (value) => setStateBottomSheet(() => _selectedSort = value!),
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
                                  side: const BorderSide(color: AppTheme.primaryGreen),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Tümünü Temizle'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {}); // تحديث الشاشة الرئيسية بالقيم الجديدة
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Sonuçları Göster', style: TextStyle(color: Colors.white)),
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
    // 3. جلب القائمة المفلترة في دالة البناء
    final filteredServices = _filteredServices;

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
                        onDeleted: () => setState(() => _selectedCategory = 'Tümü'),
                      ),
                    if (_selectedDistrict != 'Tümü')
                      Chip(
                        label: Text(_selectedDistrict),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _selectedDistrict = 'Tümü'),
                      ),
                    if (_selectedAnimalType != 'Tümü')
                      Chip(
                        label: Text(_selectedAnimalType),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _selectedAnimalType = 'Tümü'),
                      ),
                    if (_priceRange.start != 0 || _priceRange.end != 1000)
                      Chip(
                        label: Text('${_priceRange.start.round()}-${_priceRange.end.round()} TL'),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _priceRange = const RangeValues(0, 1000)),
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
          
          // إظهار عدد النتائج
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${filteredServices.length} hizmet bulundu',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ),

          Expanded(
            child: filteredServices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Sonuç bulunamadı', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredServices.length, // 4. استخدام طول القائمة المفلترة
                    itemBuilder: (context, index) => _buildServiceCard(context, filteredServices[index]), // 5. تمرير بيانات الخدمة للكرت
                  ),
          ),
        ],
      ),
    );
  }

  // 6. تعديل الكرت ليستقبل بيانات الخدمة الديناميكية
  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final int serviceId = service['id'];
    final bool isFavorite = _favoriteIds.contains(serviceId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // لاحقاً ستقوم بتمرير id الخدمة هنا لجلب تفاصيلها
              builder: (context) => const OwnerServiceDetailScreen(),
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
                      service['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 ${service['location']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(service['rating'].toString()),
                        const SizedBox(width: 12),
                        Text(
                          '₺${service['price']}',
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