import 'package:flutter/material.dart';

void main() => runApp(const ProfileApp());

/// Aplikasi latihan awal (warm-up) kartu profil sederhana.
class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: ProfileCard()),
      ),
    );
  }
}

/// Kartu Profil Mahasiswa menggunakan Container, Column, Row, dan Expanded.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nama Mahasiswa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Yanuar Ramadhani Kuswoko'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: Text('NIM')),
            Text('244107020176'),
          ]),
          const SizedBox(height: 8),
          const Row(children: [
            Expanded(child: Text('Kelas')),
            Text('TI-2D / 25'),
          ]),
          const SizedBox(height: 8),
          const Row(children: [
            Expanded(child: Text('Email')),
            Text('yanuar.kuswoko@student.polinema.ac.id'),
          ]),
        ],
      ),
    );
  }
}
