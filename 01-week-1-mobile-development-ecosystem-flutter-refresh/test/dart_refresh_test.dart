import 'package:flutter_test/flutter_test.dart';
import 'package:week1_mobile_refresh/dart_refresh.dart';

void main() {
  group('Latihan Mandiri Dart Refresh Tests', () {
    test('sapa returns correct string format', () {
      final result = sapa('Yanuar', 4);
      expect(result, 'Halo Yanuar, semester 4');
    });

    test('Mahasiswa status handles active and inactive correctly', () {
      final mhsAktif = Mahasiswa(nama: 'Yanuar', aktif: true);
      expect(mhsAktif.status(), 'Yanuar aktif');

      final mhsNonAktif = Mahasiswa(nama: 'Budi', aktif: false);
      expect(mhsNonAktif.status(), 'Budi tidak aktif');
    });

    test('hitungLuasPersegiPanjang calculates area accurately', () {
      expect(hitungLuasPersegiPanjang(10.0, 5.0), 50.0);
      expect(hitungLuasPersegiPanjang(12.5, 8.0), 100.0);
      expect(hitungLuasPersegiPanjang(0.0, 5.0), 0.0);
    });

    test('Profil handles null safety for email correctly', () {
      final profilWithEmail = Profil(
        nama: 'Yanuar Ramadhani Kuswoko',
        nim: '244107020176',
        email: 'yanuar@example.com',
      );
      expect(profilWithEmail.email?.toUpperCase() ?? 'BELUM DIISI', 'YANUAR@EXAMPLE.COM');
      expect(profilWithEmail.getInfo(), contains('yanuar@example.com'));

      final profilWithoutEmail = Profil(
        nama: 'Alya Putri',
        nim: '244107020999',
        email: null,
      );
      expect(profilWithoutEmail.email?.toUpperCase() ?? 'BELUM DIISI', 'BELUM DIISI');
      expect(profilWithoutEmail.getInfo(), contains('(email belum diisi)'));
    });
  });
}
