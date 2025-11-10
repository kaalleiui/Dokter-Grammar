import 'package:flutter/material.dart';

class HalamanDashboard extends StatelessWidget {
  const HalamanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Dashboard')),
      body: const Center(child: Text('Ini adalah halaman Halaman Dashboard')),
    );
  }
}
