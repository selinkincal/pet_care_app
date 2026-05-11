// owner_service_list_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// تأكد من مسار الاستدعاء الخاص بصفحة التفاصيل حسب هيكلتك الجديدة
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
  // قائمة المفضلات
  List<int> _favoriteIds = [];

  // متحكم نص البحث (لتحسين الأداء ومنع قفز المؤشر)
  late TextEditingController _searchController;

  // متغيرات الفلتر
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
    'Fatih',
    'Beyoğlu',
    'Ataşehir',
    'Sarıyer',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    
    // تعيين القيم الابتدائية
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

  // جلب المفضلات من الذاكرة
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favoriteIds = favorites.map((id) => int.parse(id)).toList();
    });
  }

  // تغيير حالة المفضلة
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
    await _loadFavorites(); // تحديث القائمة

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

                        // 1. KONUM
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
                                items: _districts.map((district) {
                                  return DropdownMenuItem(
                                    value: district,
                                    child: Text(district),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setStateBottomSheet(() {
                                    _selectedDistrict = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // 2. KATEGORİ
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
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateBottomSheet(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        const Divider(height: 32),

                        // 3. HAYVAN TÜRÜ
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
                              onSelected: (selected) {
                                setStateBottomSheet(() {
                                  _selectedAnimalType = selected ? type : 'Tümü';
                                });
                              },
                              selectedColor: AppTheme.lightGreen,
                              checkmarkColor: AppTheme.primaryGreen,
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),

                        // 4. FİYAT ARALIĞI
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
                          onChanged: (values) {
                            setStateBottomSheet(() {
                              _priceRange = values;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₺${_priceRange.start.round()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₺${_priceRange.end.round()}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // 5. PUAN
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
                                onPressed: () {
                                  setStateBottomSheet(() {
                                    _selectedRating = index + 1;
                                  });
                                },
                              );
                            }),
                            const SizedBox(width: 8),
                            if (_selectedRating > 0)
                              TextButton(
                                onPressed: () {
                                  setStateBottomSheet(() {
                                    _selectedRating = 0;
                                  });
                                },
                                child: const Text('Temizle'),
                              ),
                          ],
                        ),
                        if (_selectedRating > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${_selectedRating}+ yıldız ve üzeri',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const Divider(height: 32),

                        // 6. SIRALAMA
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
                              items: _sortOptions.map((sort) {
                                return DropdownMenuItem(
                                  value: sort,
                                  child: Text(sort),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateBottomSheet(() {
                                  _selectedSort = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // BUTONLAR
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Tümünü Temizle'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {});
                                  Navigator.pop(context);
                                  _applyFilters();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
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

  void _applyFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Filtreler uygulandı: $_selectedCategory | $_selectedAnimalType',
        ),
        duration: const Duration(seconds: 2),
      ),
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
          // Aktif filtre chip'leri
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
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => _buildServiceCard(context, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, int index) {
    // التحقق مما إذا كان العنصر الحالي في المفضلة
    final isFavorite = _favoriteIds.contains(index);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
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
                    const Text(
                      'Profesyonel Köpek Bakımı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 Kadıköy, İstanbul',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 4),
                        Text('4.8'),
                        SizedBox(width: 12),
                        Text(
                          '₺250/saat',
                          style: TextStyle(
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
                // تغيير الأيقونة واللون بناءً على حالة المفضلة
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey[400],
                ),
                onPressed: () => _toggleFavorite(index),
              ),
            ],
          ),
        ),
      ),
    );
  }
}