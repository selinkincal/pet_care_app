// provider_ads_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'provider_ad_detail_screen.dart';

class ProviderAdsScreen extends StatefulWidget {
  const ProviderAdsScreen({super.key});

  @override
  State<ProviderAdsScreen> createState() => _ProviderAdsScreenState();
}

class _ProviderAdsScreenState extends State<ProviderAdsScreen> {
  // Arama ve filtreleme değişkenleri
  String _searchQuery = '';
  String _selectedCategory = 'Tümü';
  String _selectedCity = 'İstanbul';
  String _selectedDistrict = 'Tümü';
  RangeValues _priceRange = const RangeValues(0, 5000);
  String _selectedDateRange = 'Tümü';
  String _selectedSort = 'Tarih (Yeni)';

  final List<String> _categories = ['Tümü', 'Köpek', 'Kedi', 'Kuş', 'Diğer'];
  final List<String> _dateRanges = [
    'Tümü',
    'Bu Hafta',
    'Bu Ay',
    'Gelecek 3 Ay',
  ];
  final List<String> _sortOptions = [
    'Tarih (Yeni)',
    'Tarih (Eski)',
    'Bütçe (Artan)',
    'Bütçe (Azalan)',
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

  final List<Map<String, String>> _allAds = [
    {
      'title': 'Hafta sonu için köpek gezdirici',
      'pet': 'Max (Golden Retriever)',
      'petType': 'Köpek',
      'location': 'Kadıköy, Moda',
      'date': '2026-05-09',
      'time': '10:00 - 11:30',
      'budget': '350 TL',
      'budgetValue': '350',
      'status': 'Acil',
    },
    {
      'title': '3 günlük tatil için kedi bakımı',
      'pet': 'Mia (Tekir)',
      'petType': 'Kedi',
      'location': 'Beşiktaş, Merkez',
      'date': '2026-05-12',
      'time': 'Günde 1 saat',
      'budget': '1200 TL',
      'budgetValue': '1200',
      'status': 'Yeni',
    },
    {
      'title': 'Veteriner ziyareti için refakatçi',
      'pet': 'Paşa (Papağan)',
      'petType': 'Kuş',
      'location': 'Üsküdar',
      'date': '2026-05-10',
      'time': '14:00 - 16:00',
      'budget': '400 TL',
      'budgetValue': '400',
      'status': 'Normal',
    },
    {
      'title': 'Enerjik köpeğim için günlük koşu arkadaşı',
      'pet': 'Rex (Husky)',
      'petType': 'Köpek',
      'location': 'Maltepe Sahil',
      'date': '2026-05-15',
      'time': '07:00 - 08:00',
      'budget': '4000 TL',
      'budgetValue': '4000',
      'status': 'Yeni',
    },
  ];

  List<dynamic> get _filteredAds {
    var filtered = List.from(_allAds);

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ad) {
        return ad['title']!.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            ad['pet']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ad['location']!.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Kategori filtresi
    if (_selectedCategory != 'Tümü') {
      filtered = filtered
          .where((ad) => ad['petType'] == _selectedCategory)
          .toList();
    }

    // Konum filtresi
    if (_selectedDistrict != 'Tümü') {
      filtered = filtered
          .where((ad) => ad['location']!.contains(_selectedDistrict))
          .toList();
    }

    // Fiyat aralığı filtresi
    filtered = filtered.where((ad) {
      double price = double.parse(ad['budgetValue']!);
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    // Tarih filtresi
    if (_selectedDateRange != 'Tümü') {
      final now = DateTime.now();
      filtered = filtered.where((ad) {
        try {
          final adDate = DateTime.parse(ad['date']!);
          if (_selectedDateRange == 'Bu Hafta') {
            final weekLater = now.add(const Duration(days: 7));
            return adDate.isAfter(now) && adDate.isBefore(weekLater);
          } else if (_selectedDateRange == 'Bu Ay') {
            final monthLater = now.add(const Duration(days: 30));
            return adDate.isAfter(now) && adDate.isBefore(monthLater);
          } else if (_selectedDateRange == 'Gelecek 3 Ay') {
            final threeMonthsLater = now.add(const Duration(days: 90));
            return adDate.isAfter(now) && adDate.isBefore(threeMonthsLater);
          }
        } catch (e) {
          return false;
        }
        return false;
      }).toList();
    }

    // Sıralama
    switch (_selectedSort) {
      case 'Bütçe (Artan)':
        filtered.sort(
          (a, b) => int.parse(
            a['budgetValue']!,
          ).compareTo(int.parse(b['budgetValue']!)),
        );
        break;
      case 'Bütçe (Azalan)':
        filtered.sort(
          (a, b) => int.parse(
            b['budgetValue']!,
          ).compareTo(int.parse(a['budgetValue']!)),
        );
        break;
      case 'Tarih (Yeni)':
        filtered.sort((a, b) => b['date']!.compareTo(a['date']!));
        break;
      case 'Tarih (Eski)':
        filtered.sort((a, b) => a['date']!.compareTo(b['date']!));
        break;
    }

    return filtered;
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
                          '🐾 Hayvan Türü',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _categories.map((category) {
                            return FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setStateBottomSheet(() {
                                  _selectedCategory = selected
                                      ? category
                                      : 'Tümü';
                                });
                              },
                              selectedColor: AppTheme.lightGreen,
                              checkmarkColor: AppTheme.primaryGreen,
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),

                        // 3. FİYAT ARALIĞI
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
                          max: 5000,
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

                        // 4. TARİH ARALIĞI
                        const Text(
                          '📅 Tarih Aralığı',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _dateRanges.map((dateRange) {
                            return FilterChip(
                              label: Text(dateRange),
                              selected: _selectedDateRange == dateRange,
                              onSelected: (selected) {
                                setStateBottomSheet(() {
                                  _selectedDateRange = selected
                                      ? dateRange
                                      : 'Tümü';
                                });
                              },
                              selectedColor: AppTheme.lightGreen,
                              checkmarkColor: AppTheme.primaryGreen,
                            );
                          }).toList(),
                        ),
                        const Divider(height: 32),

                        // 5. SIRALAMA
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
                                    _selectedCity = 'İstanbul';
                                    _selectedDistrict = 'Tümü';
                                    _priceRange = const RangeValues(0, 5000);
                                    _selectedDateRange = 'Tümü';
                                    _selectedSort = 'Tarih (Yeni)';
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
                                  setState(() {});
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
                                  'Uygula',
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
    final filteredAds = _filteredAds;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Müşteri İlanları'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama çubuğu
          Container(
            color: AppTheme.primaryGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Bölge, başlık veya hayvan adı ara...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Aktif filtre chip'leri
          if (_selectedCategory != 'Tümü' ||
              _selectedDistrict != 'Tümü' ||
              _priceRange.start != 0 ||
              _priceRange.end != 5000 ||
              _selectedDateRange != 'Tümü' ||
              _searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Aktif: ', style: TextStyle(fontSize: 12)),
                    if (_searchQuery.isNotEmpty)
                      Chip(
                        label: Text(_searchQuery),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(() => _searchQuery = ''),
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
                    if (_priceRange.start != 0 || _priceRange.end != 5000)
                      Chip(
                        label: Text(
                          '${_priceRange.start.round()}-${_priceRange.end.round()} TL',
                        ),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(
                          () => _priceRange = const RangeValues(0, 5000),
                        ),
                      ),
                    if (_selectedDateRange != 'Tümü')
                      Chip(
                        label: Text(_selectedDateRange),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () =>
                            setState(() => _selectedDateRange = 'Tümü'),
                      ),
                  ],
                ),
              ),
            ),

          // Sonuç sayısı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${filteredAds.length} ilan bulundu',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),

          // İlan listesi
          Expanded(
            child: filteredAds.isEmpty
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
                          'İlan bulunamadı',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAds.length,
                    itemBuilder: (context, index) {
                      return _buildAdCard(context, filteredAds[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, Map<String, String> ad) {
    Color badgeColor;
    if (ad['status'] == 'Acil') {
      badgeColor = Colors.red;
    } else if (ad['status'] == 'Yeni') {
      badgeColor = Colors.green;
    } else {
      badgeColor = Colors.blueGrey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ad['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    ad['status']!,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.pets, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  ad['pet']!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  ad['location']!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  _formatDate(ad['date']!),
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  ad['time']!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bütçe',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      ad['budget']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProviderAdDetailScreen(adData: ad),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Başvur',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }
}
