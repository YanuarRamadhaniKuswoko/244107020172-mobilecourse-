import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Header Utama sesuai praktikum
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  size: 72,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),

              // Nama Mahasiswa
              const Text(
                'Yanuar Ramadhani Kuswoko',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle Mata Kuliah & Minggu Praktikum
              Text(
                'Pemrograman Mobile — Minggu 1',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.indigo.shade700,
                ),
              ),
              const SizedBox(height: 24),

              // Card Informasi Tambahan (NIM, Kelas, Jurusan, Kampus)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.badge,
                        label: 'NIM',
                        value: '244107020176',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.class_,
                        label: 'Kelas / Absen',
                        value: 'TI-2D / 25',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.computer,
                        label: 'Program Studi',
                        value: 'D-IV Teknik Informatika',
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.apartment,
                        label: 'Institusi',
                        value: 'Politeknik Negeri Malang',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.indigo.shade600),
        const SizedBox(width: 14),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
