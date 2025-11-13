/*
 *     Copyright (C) 2024 Dokter Grammar
 *     GPLv3 License
 */

import 'package:dokter_grammar/pages/halaman_latihan_harian.dart';
import 'package:dokter_grammar/pages/halaman_tes_utama.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dokter_grammar/pages/halaman_profil_user.dart';

void main() {
  runApp(const DokterGrammarApp());
}

/// ============================================================
/// ROOT APP
/// ============================================================
class DokterGrammarApp extends StatelessWidget {
  const DokterGrammarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'Dokter Grammar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFE57F),
            primary: const Color(0xFFFFE57F),
            secondary: const Color(0xFFFFD740),
            background: const Color(0xFFFFFCF2),
            surface: const Color(0xFFFFFBF0),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFCF2),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFFCF2),
            foregroundColor: Color(0xFF4E4E4E),
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/// ============================================================
/// SPLASH SCREEN
/// ============================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE57F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash Icon
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8E1), Color(0xFFFFE57F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.shade200,
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 60,
                color: Color(0xFF8C6C00),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dokter Grammar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4E4E4E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Master English Grammar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6E6E6E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// HOME SCREEN - redesigned logue style
/// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // buka bottom sheet menu
  void _showMainMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MainMenuSheet(),
    );
  }

   // 🔸 Fungsi navigasi antar halaman
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context), // ⬅️ kirim context biar bisa dipakai di Navigator
              const SizedBox(height: 24),
              _buildMainCard(context),
              const SizedBox(height: 24),
              _buildFeatureRow(context),
              const SizedBox(height: 24),
              const _RecentSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧭 HEADER: kiri profil, tengah judul, kanan settings
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 🔸 Tombol menuju halaman profil user
        _buildIconButton(
          icon: Icons.person_rounded,
          onPressed: () => _navigateTo(context, const HalamanProfilUser()),
        ),

        // 🔸 Judul aplikasi
        const Text(
          'Dokter Grammar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E4E4E),
          ),
        ),

        // 🔸 Tombol settings (belum aktif)
        _buildIconButton(
          icon: Icons.settings_rounded,
          onPressed: () {},
        ),
      ],
    );
  }

  /// 🍋 Tombol Icon reusable (dengan soft shadow & lemon tone)
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFF3C0)),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade100.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFFFCA28), size: 22),
      ),
    );
  }

  /// ✨ Kartu besar utama "Translate Everything"
  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7C2), Color(0xFFFFE88B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade100.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🟨 Teks kiri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Master Grammar\nEffortlessly',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Color(0xFF4E4E4E),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: Colors.yellow.shade100,
                  elevation: 5,
                ),
                onPressed: () => _showMainMenu(context),
                child: const Text('Start'),
              ),
            ],
          ),

          // 🟡 Elemen visual kanan (soft glow circle)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF59D), Color(0xFFFFE57F)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.shade200.withOpacity(0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: Color(0xFF8C6C00),
            ),
          ),
        ],
      ),
    );
  }

  /// 🟨 Dua kartu kecil di bawahnya
  Widget _buildFeatureRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FeatureCard(
            title: 'Daily Practice',
            icon: Icons.calendar_month_rounded,
            onTap: () => _navigateTo(context, const HalamanLatihanHarian()),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _FeatureCard(
            title: 'Main Test',
            icon: Icons.quiz_rounded,
            onTap: () => _navigateTo(context, const HalamanTesUtama()),
          ),
        ),
      ],
    );
  }
}

/// ============================================================
/// FEATURE CARD COMPONENT
/// ============================================================
class _FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFE57F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.shade100.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF8C6C00), size: 34),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF4E4E4E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// RECENT TRANSLATE SECTION (contoh data)
/// ============================================================
class _RecentSection extends StatelessWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Practice',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF4E4E4E)),
            ),
            Text('See All',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        _RecentItem(title: 'Tenses Review - 95%', subtitle: 'Completed'),
        _RecentItem(title: 'Conditional Clauses - 80%', subtitle: 'In Progress'),
      ],
    );
  }
}

class _RecentItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _RecentItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.book_rounded, color: Color(0xFFFFCA28), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Color(0xFFBDBDBD), size: 16),
        ],
      ),
    );
  }
}

/// ============================================================
/// MAIN MENU SHEET (tetap sama fungsinya)
/// ============================================================
class _MainMenuSheet extends StatelessWidget {
  const _MainMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Learning Modules',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4E4E4E),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: const [
                _MenuBar(
                    title: 'User Profile',
                    icon: Icons.account_circle_rounded,
                    page: ProfileScreen()),
                _MenuBar(
                    title: 'Daily Practice',
                    icon: Icons.calendar_month_rounded,
                    page: DailyPracticeScreen()),
                _MenuBar(
                    title: 'Custom Practice',
                    icon: Icons.tune_rounded,
                    page: CustomPracticeScreen()),
                _MenuBar(
                    title: 'Main Test',
                    icon: Icons.quiz_rounded,
                    page: MainTestScreen()),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// ============================================================
/// MENU BAR ITEM
/// ============================================================
class _MenuBar extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget page;

  const _MenuBar({
    required this.title,
    required this.icon,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFF3C0)),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.shade100.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFFC107), size: 26),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4E4E4E),
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF9E9E9E), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// PAGES TEMPLATE
/// ============================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _SimplePage(title: 'Profile', text: 'Profile Page');
}

class DailyPracticeScreen extends StatelessWidget {
  const DailyPracticeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _SimplePage(title: 'Daily Practice', text: 'Daily Practice Page');
}

class CustomPracticeScreen extends StatelessWidget {
  const CustomPracticeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _SimplePage(title: 'Custom Practice', text: 'Custom Practice Page');
}

class MainTestScreen extends StatelessWidget {
  const MainTestScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const _SimplePage(title: 'Main Test', text: 'Main Test Page');
}

/// ============================================================
/// SIMPLE PAGE TEMPLATE (untuk semua sub-page)
/// ============================================================
class _SimplePage extends StatelessWidget {
  final String title;
  final String text;

  const _SimplePage({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Color(0xFF6E6E6E)),
        ),
      ),
    );
  }
}
