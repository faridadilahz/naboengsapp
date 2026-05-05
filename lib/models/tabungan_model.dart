class Tabungan {
  String nama;
  int target;
  int perHari;
  String tipe;
  String? imagePath;
  bool isDone;
  // 🔥 TAMBAHKAN INI
  int terkumpul; 
  List<Map<String, dynamic>> riwayat;

  Tabungan({
    required this.nama,
    required this.target,
    required this.perHari,
    required this.tipe,
    this.imagePath,
    this.isDone = false,
    this.terkumpul = 0, // 👈 Kasih default 0 biar gak null
    List<Map<String, dynamic>>? riwayat, // 👈 Terima input riwayat tapi boleh kosong
  }) : this.riwayat = riwayat ?? []; // 👈 Kalau kosong, kasih list []
}