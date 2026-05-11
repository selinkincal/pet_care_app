// edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 👈 ضروري لـ Factory
import 'package:flutter/gestures.dart';   // 👈 ضروري لـ EagerGestureRecognizer
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(41.0082, 28.9784);
  Set<Marker> _markers = {};
  bool _isMapVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('userName') ?? '';
    _emailController.text = prefs.getString('userEmail') ?? '';
    _phoneController.text = prefs.getString('userPhone') ?? '';
    _addressController.text = prefs.getString('userAddress') ?? '';
    _profileImagePath = prefs.getString('profileImagePath');

    if (_addressController.text.isNotEmpty) {
      await _getCoordinatesFromAddress(_addressController.text);
    }
    setState(() {});
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _profileImagePath = pickedFile.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', pickedFile.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil resmi güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _selectedLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _updateMarker();
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation, 15),
        );
      }
    } catch (e) {
      debugPrint('Adres dönüştürme hatası: $e');
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address = '';
        if (place.street != null) address += place.street!;
        if (place.subLocality != null) address += ', ${place.subLocality}';
        if (place.locality != null) address += ', ${place.locality}';
        if (place.postalCode != null) address += ' ${place.postalCode}';
        if (place.country != null) address += ', ${place.country}';

        setState(() => _addressController.text = address);
      }
    } catch (e) {
      debugPrint('Koordinat dönüştürme hatası: $e');
    }
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: const InfoWindow(title: 'Konumum'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      };
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen konum servislerini açın')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum izni gerekli'))
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
      _updateMarker();
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation, 15),
      );
    });
    await _getAddressFromCoordinates(_selectedLocation);
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setString('userPhone', _phoneController.text);
      await prefs.setString('userAddress', _addressController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilgileriniz güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Bilgilerim'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGreen,
                    shape: BoxShape.circle,
                    image: _profileImagePath != null &&
                            File(_profileImagePath!).existsSync()
                        ? DecorationImage(
                            image: FileImage(File(_profileImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(color: AppTheme.primaryGreen, width: 2),
                  ),
                  child: _profileImagePath == null ||
                          !File(_profileImagePath!).existsSync()
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: AppTheme.primaryGreen,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickProfileImage,
                child: const Text(
                  'Profil resmini değiştir',
                  style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Ad soyad giriniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty || !v.contains('@')
                    ? 'Geçerli e-posta giriniz'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adres',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.map, color: AppTheme.primaryGreen),
                    onPressed: () =>
                        setState(() => _isMapVisible = !_isMapVisible),
                  ),
                ],
              ),

              if (_isMapVisible) ...[
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Mevcut Konumumu Kullan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GoogleMap(
                      onMapCreated: (controller) => _mapController = controller,
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation,
                        zoom: 14,
                      ),
                      markers: _markers,
                      // 🔥 الحل السحري: يجبر الخريطة على استقبال الإيماءات واللمسات بدلاً من ScrollView
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      onTap: (LatLng position) async {
                        setState(() {
                          _selectedLocation = position;
                          _updateMarker();
                        });
                        await _getAddressFromCoordinates(position);
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true, 
                      rotateGesturesEnabled: true, 
                      tiltGesturesEnabled: true, 
                      mapToolbarEnabled: true,
                      compassEnabled: true,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Haritayı parmağınızla kaydırıp yakınlaştırabilirsiniz',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveUserData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}