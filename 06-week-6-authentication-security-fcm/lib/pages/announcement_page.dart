import 'package:flutter/material.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Data simulasi konten berdasarkan ID pengumuman
    final announcementData = _getAnnouncementDetail(id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Badge ID & Kategori
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ID: $id',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    announcementData['category']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Judul Pengumuman
            Text(
              announcementData['title']!,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Tanggal Terbit
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  announcementData['date']!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // Isi Pengumuman
            Text(
              announcementData['body']!,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Info Deep Link FCM
            Card(
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.4),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.tertiary.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 20,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Deep Link FCM Route Handler',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Halaman ini terbuka via path /pengumuman/$id yang diparsing dari remote message payload { "route": "/pengumuman/$id" } pada state Foreground, Background, maupun Terminated.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String> _getAnnouncementDetail(String id) {
    switch (id) {
      case '1':
        return {
          'title': 'Jadwal Kuliah Pemrograman Mobile Berubah',
          'category': 'Akademik',
          'date': 'Kamis, 08:30 WIB',
          'body':
              'Diberitahukan kepada seluruh mahasiswa TI-2D bahwa perkuliahan Pemrograman Mobile minggu ini akan fokus pada topik Authentication, Security, Token Refresh, dan Firebase Cloud Messaging (FCM).\n\nSilakan memastikan Flutter SDK dan dependensi telah terinstal dengan baik.',
        };
      case '2':
        return {
          'title': 'Persiapan Ujian Tengah Semester Ganjil',
          'category': 'Jurusan',
          'date': 'Rabu, 14:00 WIB',
          'body':
              'Ujian Tengah Semester (UTS) akan dilaksanakan sesuai dengan jadwal yang tertera di SIAKAD. Harap seluruh mahasiswa menyelesaikan tugas mingguan dan repository portfolio tepat waktu.',
        };
      case '3':
        return {
          'title': 'Kelas Mobile Pindah ke Ruang A2 Jam 13.00',
          'category': 'FCM Push Payload Demo',
          'date': 'Hari ini, 10:15 WIB',
          'body':
              'Pengumuman darurat: Perkuliahan tatap muka untuk praktikum FCM dipindahkan ke Ruang Laboratorium Komputer A2 pada pukul 13.00 WIB.\n\nNotifikasi ini dikirim via FCM broadcast topic "pengumuman-kampus".',
        };
      default:
        return {
          'title': 'Pengumuman Kampus #$id',
          'category': 'Informasi Umum',
          'date': 'Baru saja',
          'body':
              'Detail pengumuman dengan identifier ID $id berhasil dimuat melalui sistem routing GoRouter.',
        };
    }
  }
}
