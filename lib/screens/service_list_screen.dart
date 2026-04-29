import 'package:flutter/material.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hizmetler')),
      body: const Center(
        child: Text('Hizmet Listesi - Kartlar buraya gelecek'),
      ),
    );
  }
}
