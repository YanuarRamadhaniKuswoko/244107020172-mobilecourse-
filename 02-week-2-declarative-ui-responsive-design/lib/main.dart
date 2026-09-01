import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DashboardApp());

/// Breakpoint konstanta named untuk membedakan tata letak layar sempit dan layar lebar.
const double kWideBreakpoint = 700.0;

/// Aplikasi Utama Dashboard Akademik dengan dukungan Material 3,
/// tema terang & gelap, serta interaktivitas toggle CupertinoSwitch.
class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academic Overview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

/// Halaman Dashboard Akademik Responsif.
/// Menampilkan Header Profil dan Grid Kartu Informasi yang menyesuaikan
/// jumlah kolom (1 kolom di layar sempit, 2 kolom di layar lebar).
class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academic Overview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Semantics(
            label: isDark ? 'Beralih ke Tema Terang' : 'Beralih ke Tema Gelap',
            toggled: isDark,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                CupertinoSwitch(
                  value: isDark,
                  activeTrackColor: theme.colorScheme.primary,
                  onChanged: onDarkChanged,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= kWideBreakpoint;
          final columns = isWide ? 2 : 1;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: CustomScrollView(
                slivers: [
                  // Header Profil Mahasiswa & Judul Ringkasan
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const ProfileHeader(
                            nama: 'Yanuar Ramadhani Kuswoko',
                            nim: '244107020176',
                            kelas: 'TI-2D / 25',
                            prodi: 'D-IV Teknik Informatika',
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.dashboard_outlined,
                                  size: 20,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ringkasan Akademik',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Grid Kartu Informasi Akademik (1 kolom sempit / 2 kolom lebar)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 24.0),
                    sliver: SliverGrid.count(
                      crossAxisCount: columns,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWide ? 3.0 : 2.5,
                      children: const [
                        InfoCard(
                          title: 'Assignments',
                          value: '8',
                          subtitle: 'Semua tugas telah diselesaikan',
                          icon: Icons.assignment_turned_in,
                        ),
                        InfoCard(
                          title: 'Attendance',
                          value: '92%',
                          subtitle: 'Kehadiran perkuliahan sangat baik',
                          icon: Icons.fact_check,
                        ),
                        InfoCard(
                          title: 'Portfolio',
                          value: 'Ready',
                          subtitle: 'Dokumentasi & repository siap',
                          icon: Icons.folder_special,
                        ),
                        InfoCard(
                          title: 'Current week',
                          value: '02',
                          subtitle: 'Declarative UI & Responsive Design',
                          icon: Icons.date_range,
                        ),
                        InfoCard(
                          title: 'IPK Kumulatif',
                          value: '3.92',
                          subtitle: 'Semester aktif berjalan',
                          icon: Icons.school,
                        ),
                        InfoCard(
                          title: 'Total SKS',
                          value: '24 SKS',
                          subtitle: '8 Mata kuliah semester ini',
                          icon: Icons.auto_stories,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget Reusable Header Profil Mahasiswa.
/// Menggabungkan Container, Row, Column, Expanded, dan CircleAvatar
/// dengan warna dan gaya yang menyesuaikan Theme secara dinamis.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.nama,
    required this.nim,
    required this.kelas,
    required this.prodi,
    super.key,
  });

  final String nama;
  final String nim;
  final String kelas;
  final String prodi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      label: 'Informasi Profil Mahasiswa $nama, NIM $nim, Kelas $kelas, Program Studi $prodi',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer.withAlpha(120),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(100),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 36,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nama,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: $nim • $kelas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prodi,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget Reusable Kartu Informasi (InfoCard / DashboardCard).
/// Menggunakan Card, Padding, Row, Expanded, Icon, dan Typography
/// yang terikat penuh pada Theme (Material 3).
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    super.key,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$title: $value${subtitle != null ? ', $subtitle' : ''}',
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(60),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
