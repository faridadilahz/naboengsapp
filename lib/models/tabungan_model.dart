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
  DateTime updatedAt;

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
    DateTime? updatedAt,
  })  : riwayat = riwayat ?? [],
        updatedAt = updatedAt ?? tanggalDibuat;

  factory Tabungan.fromJson(Map<String, dynamic> json) {
    final dibuat = DateTime.parse(json['tanggalDibuat']);
    return Tabungan(
      nama: json['nama'],
      target: json['target'],
      perHari: json['perHari'],
      tipe: json['tipe'],
      imagePath: json['imagePath'],
      isDone: json['isDone'] ?? false,
      terkumpul: json['terkumpul'] ?? 0,
      riwayat: List<Map<String, dynamic>>.from(json['riwayat'] ?? []),
      tanggalDibuat: dibuat,
      estimasiSelesai: DateTime.parse(json['estimasiSelesai']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : dibuat,
    );
  }

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
      'tanggalDibuat': tanggalDibuat.toIso8601String(),
      'estimasiSelesai': estimasiSelesai.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}