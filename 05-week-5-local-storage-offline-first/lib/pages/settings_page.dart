import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _formatTimestamp(String? isoString) {
    if (isoString == null || isoString.isEmpty) {
      return 'Belum pernah dicatat';
    }
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Praktikum 1 — SharedPreferences',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Penyimpanan Key-Value di Perangkat',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // Dark Mode Switch
                  darkModeAsync.when(
                    data: (isDark) => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: isDark ? Colors.amber : Colors.orange,
                      ),
                      title: const Text('Tema Gelap (Dark Mode)'),
                      subtitle: Text(
                        isDark ? 'Mode gelap aktif' : 'Mode terang aktif',
                        style: theme.textTheme.bodySmall,
                      ),
                      value: isDark,
                      onChanged: (value) {
                        ref.read(darkModeProvider.notifier).setDarkMode(value);
                      },
                    ),
                    loading: () => const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircularProgressIndicator(),
                      title: Text('Memuat preferensi tema...'),
                    ),
                    error: (err, _) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.error_outline, color: Colors.red),
                      title: Text('Gagal memuat tema: $err'),
                    ),
                  ),
                  const Divider(height: 24),
                  // Last Opened Info
                  lastOpenedAsync.when(
                    data: (timestamp) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      title: const Text('Terakhir Dibuka (last_opened_at)'),
                      subtitle: Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    loading: () => const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircularProgressIndicator(),
                      title: Text('Membaca waktu terakhir dibuka...'),
                    ),
                    error: (err, _) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.error_outline, color: Colors.red),
                      title: Text('Gagal membaca: $err'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Catatan Arsitektur',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seluruh pemanggilan SharedPreferences dipusatkan pada PrefsRepository dan dibungkus oleh Riverpod Provider. Widget tidak pernah memanggil SharedPreferences.getInstance() secara langsung di dalam build().',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
