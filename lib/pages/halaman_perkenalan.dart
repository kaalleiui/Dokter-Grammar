import 'package:flutter/material.dart';

class HalamanPerkenalan extends StatelessWidget {
  const HalamanPerkenalan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Perkenalan')),
      body: const Center(child: Text('Ini adalah halaman Halaman Perkenalan')),
    );
  }
}
