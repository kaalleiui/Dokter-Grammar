import 'package:flutter/material.dart';

class HalamanTesUtama extends StatelessWidget {
  const HalamanTesUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tes Utama')),
      body: const Center(child: Text('Ini adalah halaman Halaman Tes Utama')),
    );
  }
}
