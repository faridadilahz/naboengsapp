class Tabungan {
  String nama;
  int target;
  int perHari;
  String tipe;
  String? imagePath;
  bool isDone;

  Tabungan({
    required this.nama,
    required this.target,
    required this.perHari,
    required this.tipe,
    this.imagePath,
    this.isDone = false,
  });
}
