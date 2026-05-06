class Tabungan {
  String nama;
  int target;
  int perHari;
  String tipe;
  String? imagePath;
  bool isDone;
  int terkumpul;
  List<Map<String, dynamic>> riwayat;
  final DateTime tanggalDibuat; // Variabel penting buat track umur tabungan
  DateTime estimasiSelesai;

  Tabungan({
    required this.nama,
    required this.target,
    required this.perHari,
    required this.tipe,
    required this.tanggalDibuat,
    required this.estimasiSelesai,
    this.imagePath,
    this.isDone = false,
    this.terkumpul = 0,
    List<Map<String, dynamic>>? riwayat,
  }) : this.riwayat = riwayat ?? [];
}
