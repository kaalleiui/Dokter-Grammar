import 'package:flutter/material.dart';

class ExplanationBox extends StatelessWidget {
  const ExplanationBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explanation Box')),
      body: const Center(child: Text('Ini adalah halaman Explanation Box')),
    );
  }
}
