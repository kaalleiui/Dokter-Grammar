import 'package:flutter/material.dart';

class HalamanProfilUser extends StatelessWidget {
  const HalamanProfilUser({super.key});

  @override
  Widget build(BuildContext context) {
    // ============================================================
    // HARD-CODED USER DATA (dummy / mockup)
    // Ganti nanti dengan data backend / Hive storage
    // ============================================================
    final Map<String, String> userData = {
      'name': 'Andra Kusuma',
      'username': 'andrakusuma',
      'age': '22',
      'language': 'English & Bahasa Indonesia',
      'country': 'Indonesia',
      'joined': 'January 2025',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFFFCF2),
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4E4E4E)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFCF2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4E4E4E)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // ============================================================
            // PROFILE HEADER SECTION
            // ============================================================
            Container(
              padding: const EdgeInsets.all(24),
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
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Avatar lingkaran
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF59D), Color(0xFFFFE57F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow.shade200.withOpacity(0.6),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Color(0xFF8C6C00),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData['name']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4E4E4E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '@${userData['username']}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ============================================================
            // USER INFO CARDS
            // ============================================================
            _InfoCard(
              icon: Icons.cake_rounded,
              label: 'Age',
              value: '${userData['age']} years old',
            ),
            _InfoCard(
              icon: Icons.language_rounded,
              label: 'Language',
              value: userData['language']!,
            ),
            _InfoCard(
              icon: Icons.flag_rounded,
              label: 'Country',
              value: userData['country']!,
            ),
            _InfoCard(
              icon: Icons.calendar_month_rounded,
              label: 'Joined',
              value: userData['joined']!,
            ),

            const SizedBox(height: 24),

            // ============================================================
            // EDIT BUTTON (future backend integration)
            // ============================================================
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4E4E4E),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: Color(0xFFFFF59D)),
                ),
                elevation: 5,
                shadowColor: Colors.yellow.shade100,
              ),
              onPressed: () {
                // TODO: Integrasi backend nanti di sini
                // Buka halaman edit profil user atau update Hive storage
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit feature will be available soon!'),
                    backgroundColor: Color(0xFFFFCA28),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// WIDGET UNTUK CARD INFORMASI USER
/// ============================================================
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade100.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF8C6C00), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4E4E4E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
