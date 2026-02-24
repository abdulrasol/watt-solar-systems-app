import 'package:flutter/material.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  final String title;
  const FeaturePlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('$title Module', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Coming Soon in next update.'),
          ],
        ),
      ),
    );
  }
}
