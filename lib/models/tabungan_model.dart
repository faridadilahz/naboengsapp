class Tabungan {
  String nama;
  int target;
  int perHari;
  String tipe;
  String? imagePath;
  bool isDone;
  int terkumpul;
  List<Map<String, dynamic>> riwayat;
  final DateTime tanggalDibuat;
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
  }) : riwayat = riwayat ?? [];

  // --- TAMBAH DARI SINI: Fungsi dari/ke JSON ---

  // 1. Fungsi buat ngubah JSON ke Objek Tabungan (Buat nge-Load Data)
  factory Tabungan.fromJson(Map<String, dynamic> json) {
    return Tabungan(
      nama: json['nama'],
      target: json['target'],
      perHari: json['perHari'],
      tipe: json['tipe'],
      imagePath: json['imagePath'],
      isDone: json['isDone'] ?? false,
      terkumpul: json['terkumpul'] ?? 0,
      // Ubah dynamic list dari JSON jadi List<Map<String, dynamic>>
      riwayat: List<Map<String, dynamic>>.from(json['riwayat'] ?? []),
      // Ubah teks ke DateTime
      tanggalDibuat: DateTime.parse(json['tanggalDibuat']),
      estimasiSelesai: DateTime.parse(json['estimasiSelesai']),
    );
  }

  // 2. Fungsi buat ngubah Objek Tabungan ke JSON (Buat nge-Save Data)
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'target': target,
      'perHari': perHari,
      'tipe': tipe,
      'imagePath': imagePath,
      'isDone': isDone,
      'terkumpul': terkumpul,
      'riwayat': riwayat,
      // Ubah DateTime ke teks biar bisa disimpen
      'tanggalDibuat': tanggalDibuat.toIso8601String(),
      'estimasiSelesai': estimasiSelesai.toIso8601String(),
    };
  }
}