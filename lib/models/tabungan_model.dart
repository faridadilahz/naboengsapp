class Tabungan {
  String nama;
  int target;
  int perHari;
  String? imagePath;
  bool isDone; // 🔥 TAMBAH INI

  Tabungan({
    required this.nama,
    required this.target,
    required this.perHari,
    this.imagePath,
    this.isDone = false, // default masih proses
  });
}
