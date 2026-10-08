import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../providers/push_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isRefreshingToken = false;
  String? _interceptorLog;
  bool _showPayloadJson = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi service push & ambil token awal saat HomePage dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcmProvider.notifier).initPushService();
    });
  }

  Future<void> _handleManualRefresh() async {
    setState(() {
      _isRefreshingToken = true;
      _interceptorLog = null;
    });

    try {
      final newToken =
          await ref.read(authStateProvider.notifier).manualRefreshToken();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'JWT Access Token berhasil dirotasi!\nToken: ${newToken.substring(0, 15)}...',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal merotasi token: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingToken = false;
        });
      }
    }
  }

  Future<void> _handleTestInterceptor() async {
    setState(() {
      _interceptorLog = 'Mengirim request ke API dengan interceptor Dio...';
    });

    try {
      final tokenStore = ref.read(tokenStoreProvider);
      final currentAccess = await tokenStore.readAccess();
      final currentRefresh = await tokenStore.readRefresh();

      setState(() {
        _interceptorLog =
            '1. Access token aktif terdeteksi (${currentAccess != null && currentAccess.length >= 12 ? currentAccess.substring(0, 12) : currentAccess}...)\n'
            '2. Header "Authorization: Bearer <token>" siap disematkan oleh onRequest interceptor.\n'
            '3. Jika server merespons 401 Unauthorized, onError interceptor otomatis menukar refresh token (${currentRefresh != null && currentRefresh.length >= 12 ? currentRefresh.substring(0, 12) : currentRefresh}...) dan me-retry request 1 kali.';
      });
    } catch (e) {
      setState(() {
        _interceptorLog = 'Terjadi error: $e';
      });
    }
  }

  Future<void> _simulateForegroundPush() async {
    await PushService.triggerLocalNotification(
      title: 'Jadwal Kuliah Berubah',
      body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
      route: '/pengumuman/3',
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Simulasi Foreground: Banner lokal dipicu via flutter_local_notifications. Klik banner untuk membuka /pengumuman/3.',
        ),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _simulateBackgroundOpen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Simulasi Background: Mengarahkan rute dari onMessageOpenedApp ke /pengumuman/3...',
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.push('/pengumuman/3');
      }
    });
  }

  void _simulateTerminatedLaunch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Simulasi Terminated: Inisialisasi awal membaca getInitialMessage() dan bernavigasi ke /pengumuman/3...',
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.push('/pengumuman/3');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokenInfoAsync = ref.watch(maskedTokenInfoProvider);
    final fcmState = ref.watch(fcmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school_rounded, size: 24),
            SizedBox(width: 8),
            Text('Campus Notify'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar (Hapus Sesi & Token)',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Keluar'),
                  content: const Text(
                    'Seluruh token di Secure Storage akan dihapus dan Anda akan dialihkan ke halaman login.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authStateProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(maskedTokenInfoProvider);
          await ref.read(fcmProvider.notifier).initPushService();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner Selamat Datang
              Card(
                color: colorScheme.primaryContainer,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Praktikum 1, 2 & 3: Lengkap',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Auth Guard, Secure Storage, FCM Lifecycle & 3 App States Matriks.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // CARD PRAKTIKUM 3: PENGUJIAN 3 APP STATES & PAYLOAD
              // ==========================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.touch_app_rounded, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Praktikum 3: Pengujian 3 State Aplikasi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uji alur payload gabungan notification + data { route: /pengumuman/3 } pada ketiga state aplikasi:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Divider(height: 20),

                      // Tombol Pengujian 3 State
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _simulateForegroundPush,
                            icon: const Icon(Icons.notifications_active_rounded, size: 18),
                            label: const Text('1. Foreground (Banner Lokal)'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _simulateBackgroundOpen,
                            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                            label: const Text('2. Background (onMessageOpenedApp)'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _simulateTerminatedLaunch,
                            icon: const Icon(Icons.power_settings_new_rounded, size: 18),
                            label: const Text('3. Terminated (getInitialMessage)'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Inspektor JSON Payload FCM HTTP v1
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showPayloadJson = !_showPayloadJson;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                _showPayloadJson
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _showPayloadJson
                                    ? 'Sembunyikan Contoh Payload FCM HTTP v1'
                                    : 'Lihat Struktur Payload FCM HTTP v1 (Backend)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showPayloadJson) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '{\n'
                            '  "message": {\n'
                            '    "topic": "pengumuman-kampus",\n'
                            '    "notification": {\n'
                            '      "title": "Jadwal kuliah berubah",\n'
                            '      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"\n'
                            '    },\n'
                            '    "data": {\n'
                            '      "route": "/pengumuman/3",\n'
                            '      "id": "3"\n'
                            '    }\n'
                            '  }\n'
                            '}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF4EC9B0),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // CARD PRAKTIKUM 2: FCM & TOKEN LIFECYCLE
              // ==========================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cloud_sync_rounded, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Praktikum 2: FCM & Token Lifecycle',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Status Izin Notifikasi (Android 13+ / iOS)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                fcmState.permissionStatus ==
                                        NotificationPermissionStatus.granted
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_amber_rounded,
                                color: fcmState.permissionStatus ==
                                        NotificationPermissionStatus.granted
                                    ? Colors.green.shade700
                                    : Colors.orange.shade800,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Izin Notifikasi: ${fcmState.permissionStatus == NotificationPermissionStatus.granted ? 'Diizinkan (Granted)' : 'Belum Diizinkan'}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          if (fcmState.permissionStatus != NotificationPermissionStatus.granted)
                            TextButton.icon(
                              onPressed: () =>
                                  ref.read(fcmProvider.notifier).requestPermission(),
                              icon: const Icon(Icons.notifications_active, size: 16),
                              label: const Text('Minta Izin'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Registration Token Terpotong (Masked)
                      _buildTokenRow(
                        context,
                        label: 'FCM Registration Token (Terpotong / Masked)',
                        value: fcmState.maskedToken,
                        icon: Icons.tag_rounded,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(height: 12),

                      // Langganan Topik
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(
                          Icons.campaign_rounded,
                          color: fcmState.isSubscribedTopic
                              ? colorScheme.primary
                              : Colors.grey,
                        ),
                        title: const Text(
                          'Topik Broadcast: pengumuman-kampus',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        subtitle: Text(
                          fcmState.isSubscribedTopic
                              ? 'Aktif menerima siaran massal kampus'
                              : 'Tidak aktif (Unsubscribed)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: fcmState.isSubscribedTopic,
                        onChanged: (_) {
                          ref.read(fcmProvider.notifier).toggleTopicSubscription();
                        },
                      ),
                      const SizedBox(height: 8),

                      // Tombol Aksi Lifecycle
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: fcmState.isSyncing
                                ? null
                                : () => ref
                                    .read(fcmProvider.notifier)
                                    .simulateTokenRefresh(),
                            icon: fcmState.isSyncing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.autorenew_rounded, size: 18),
                            label: const Text('Simulasi onTokenRefresh'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Live Log Sinkronisasi Backend POST /devices
                      Text(
                        'Log Sinkronisasi ke Backend (POST /devices):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: fcmState.syncLogs.isEmpty
                            ? const Text(
                                'Belum ada log pengiriman token.',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: fcmState.syncLogs.take(3).map((log) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Text(
                                      '• [${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}] ${log.endpoint} -> ${log.status}\n'
                                      '  Token: ${PushService.maskToken(log.payload['fcm_token'] as String?)} (Platform: ${log.payload['platform']})',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // CARD PRAKTIKUM 1: AUTH TOKEN & SECURE STORAGE
              // ==========================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield_outlined, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Praktikum 1: Auth Token di Secure Storage',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      tokenInfoAsync.when(
                        data: (info) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTokenRow(
                              context,
                              label: 'Access Token (Umur Pendek)',
                              value: info['access'] ?? '-',
                              icon: Icons.key_rounded,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 12),
                            _buildTokenRow(
                              context,
                              label: 'Refresh Token (Umur Panjang)',
                              value: info['refresh'] ?? '-',
                              icon: Icons.refresh_rounded,
                              color: Colors.orange.shade800,
                            ),
                          ],
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (err, _) => Text('Gagal memuat token: $err'),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: _isRefreshingToken
                                ? null
                                : _handleManualRefresh,
                            icon: _isRefreshingToken
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Rotasi Auth Token'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _handleTestInterceptor,
                            icon: const Icon(Icons.bolt_rounded, size: 18),
                            label: const Text('Uji Dio Interceptor'),
                          ),
                        ],
                      ),
                      if (_interceptorLog != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            _interceptorLog!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // CARD DAFTAR PENGUMUMAN (DEEP LINK DESTINATION)
              // ==========================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.campaign_outlined, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Daftar Pengumuman Kampus',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih pengumuman untuk menguji deep linking rute /pengumuman/:id',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Divider(height: 20),
                      _buildAnnouncementTile(
                        context,
                        id: '1',
                        title: 'Jadwal Kuliah Pemrograman Mobile Berubah',
                        category: 'Akademik',
                        date: 'Hari ini, 08:30',
                      ),
                      _buildAnnouncementTile(
                        context,
                        id: '2',
                        title: 'Persiapan Ujian Tengah Semester Ganjil',
                        category: 'Jurusan',
                        date: 'Kemarin, 14:00',
                      ),
                      _buildAnnouncementTile(
                        context,
                        id: '3',
                        title: 'Kelas Mobile Pindah ke Ruang A2 Jam 13.00',
                        category: 'FCM Push Payload Demo',
                        date: 'Hari ini, 10:15',
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

  Widget _buildTokenRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementTile(
    BuildContext context, {
    required String id,
    required String title,
    required String category,
    required String date,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          id,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text('$category • $date', style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        context.push(AppRoutes.announcementPath(id));
      },
    );
  }
}
