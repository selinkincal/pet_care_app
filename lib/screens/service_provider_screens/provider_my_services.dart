// provider_my_services.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ProviderMyServicesScreen extends StatelessWidget {
  const ProviderMyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmetlerim'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.lightGreen,
                child: const Icon(Icons.pets, color: AppTheme.primaryGreen),
              ),
              title: const Text('Profesyonel Köpek Bakımı'),
              subtitle: const Text('250 TL • 4.8⭐'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {},
                  ),
                ],
              ),
              onTap: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
