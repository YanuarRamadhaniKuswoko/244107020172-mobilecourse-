// ignore_for_file: avoid_print

// Latihan Mandiri Dart Refresh - Minggu 1
// Pemrograman Mobile

void main() {
  print('=== 1. DASAR DART & FUNGSI SAPA ===');
  String nama = 'Yanuar Ramadhani Kuswoko';
  int semester = 4;
  final bool aktif = true;

  print(sapa(nama, semester));

  final mahasiswa = Mahasiswa(nama: nama, aktif: aktif);
  print('Status Mahasiswa: ${mahasiswa.status()}');

  print('\n=== 2. LATIHAN MANDIRI: HITUNG LUAS PERSEGI PANJANG ===');
  double panjang = 12.5;
  double lebar = 8.0;
  double luas = hitungLuasPersegiPanjang(panjang, lebar);
  print('Panjang: $panjang, Lebar: $lebar');
  print('Luas Persegi Panjang: $luas');

  print('\n=== 3. LATIHAN MANDIRI: CLASS PROFIL & NULL SAFETY ===');
  // Profil dengan email terisi
  final profil1 = Profil(
    nama: 'Yanuar Ramadhani Kuswoko',
    nim: '244107020176',
    email: 'yanuar@example.com',
  );
  print('Profil 1:');
  print('  Nama : ${profil1.nama}');
  print('  NIM  : ${profil1.nim}');
  print('  Email: ${profil1.email?.toUpperCase() ?? 'BELUM DIISI'}');

  // Profil dengan email kosong (null)
  final profil2 = Profil(
    nama: 'Alya Putri',
    nim: '244107020999',
    email: null,
  );
  print('\nProfil 2 (Email null):');
  print('  Nama : ${profil2.nama}');
  print('  NIM  : ${profil2.nim}');
  print('  Email: ${profil2.email?.toUpperCase() ?? 'BELUM DIISI'}');
}

/// Fungsi sapa dari modul materi
String sapa(String nama, int semester) => 'Halo $nama, semester $semester';

/// Latihan 1: Fungsi hitungLuasPersegiPanjang yang menerima panjang dan lebar bertipe double
double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

/// Class Mahasiswa dari modul materi
class Mahasiswa {
  final String nama;
  final bool aktif;

  Mahasiswa({required this.nama, required this.aktif});

  String status() => aktif ? '$nama aktif' : '$nama tidak aktif';
}

/// Latihan 2: Class Profil dengan properti nama, nim, dan email (nullable/boleh kosong)
class Profil {
  final String nama;
  final String nim;
  final String? email;

  Profil({
    required this.nama,
    required this.nim,
    this.email,
  });

  /// Helper method untuk mendapatkan representasi profil dengan email handling aman
  String getInfo() {
    final emailDisplay = email?.toLowerCase() ?? '(email belum diisi)';
    return 'Mahasiswa: $nama | NIM: $nim | Email: $emailDisplay';
  }
}
