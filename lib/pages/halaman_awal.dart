import 'package:flutter/material.dart';

class HalamanAwal extends StatelessWidget {
  const HalamanAwal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Awal')),
      body: const Center(child: Text('Ini adalah halaman Halaman Awal')),
    );
  }
}
