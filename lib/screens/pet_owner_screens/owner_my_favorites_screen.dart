// owner_my_favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Firestore kütüphanesini ekliyoruz
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/theme/app_theme.dart';
import 'owner_service_list_screen.dart';
import 'owner_service_detail_screen.dart';

class MyFavoritesScreen extends StatefulWidget {
  const MyFavoritesScreen({super.key});

  @override
  State<MyFavoritesScreen> createState() => _MyFavoritesScreenState();
}

class _MyFavoritesScreenState extends State<MyFavoritesScreen> {
  // Veritabanından çekilen gerçek favori hizmetleri tutacağımız liste
  List<Map<String, dynamic>> _favoritesData = [];
  bool _isLoading = true; // Yüklenme durumunu kontrol eden değişken

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Favori ID'lerini yerel bellekten alıp, Firestore'dan gerçek verilerini çekme işlemi
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesIds = prefs.getStringList('favorites') ?? [];

      if (favoritesIds.isEmpty) {
        if (mounted) {
          setState(() {
            _favoritesData = [];
            _isLoading = false;
          });
        }
        return;
      }

      List<Map<String, dynamic>> loadedFavorites = [];

      for (String id in favoritesIds) {
        final doc = await FirebaseFirestore.instance
            .collection('services')
            .doc(id)
            .get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Belge ID'sini ekleyelim
          loadedFavorites.add(data);
        }
      }

      if (mounted) {
        setState(() {
          _favoritesData = loadedFavorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Favoriler yüklenirken hata oluştu: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Favorilerden Çıkarma İşlemi
  Future<void> _removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesIds = prefs.getStringList('favorites') ?? [];

    favoritesIds.remove(id);
    await prefs.setStringList('favorites', favoritesIds);

    setState(() {
      _favoritesData.removeWhere((service) => service['id'] == id);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Beğenilerden kaldırıldı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beğendiklerim'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : _favoritesData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz beğendiğiniz hizmet yok',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OwnerServiceListScreen(),
                        ),
                      ).then((_) {
                        _loadFavorites();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Hizmetlere Göz At',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoritesData.length,
              itemBuilder: (context, index) {
                final service = _favoritesData[index];

                final String title = service['title'] ?? 'İsimsiz Hizmet';
                final String location =
                    service['location'] ?? 'Konum Bilinmiyor';
                final String price = service['price']?.toString() ?? '0';
                final String rating = service['rating']?.toString() ?? '0.0';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // 👈 BURASI GÜNCELLENDİ: Gerçek verileri Detay Sayfasına iletiyoruz
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OwnerServiceDetailScreen(
                            serviceData: service, // Çekilen Map verisi
                            serviceId: service['id'], // Firestore doküman ID'si
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
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.lightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pets,
                              size: 30,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📍 $location',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$price TL',
                                      style: const TextStyle(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFavorite(service['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
