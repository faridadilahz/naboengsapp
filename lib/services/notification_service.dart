import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    _setLocalTimezone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/naboengslogo');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    if (!kIsWeb && await Permission.notification.isGranted) {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('nama_pengguna') ?? '';
      await scheduleDailyReminders(savedName);
    }
  }

  void _setLocalTimezone() {
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    String locationName = 'Asia/Jakarta'; // WIB
    if (offsetHours == 8) {
      locationName = 'Asia/Makassar'; // WITA
    } else if (offsetHours == 9) {
      locationName = 'Asia/Jayapura'; // WIT
    }
    tz.setLocalLocation(tz.getLocation(locationName));
  }

  Future<PermissionStatus> requestPermissionAndSchedule(
    String currentName,
  ) async {
    if (kIsWeb) return PermissionStatus.denied;

    final status = await Permission.notification.request();

    if (status.isGranted) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestExactAlarmsPermission();

      await scheduleDailyReminders(currentName);
    }

    return status;
  }

  /// Menampilkan notifikasi KHUSUS saat kartu tabungan pertama kali dibuat
  Future<void> showFirstTabunganNotification({
    required String namaUser,
    required String namaTabungan,
  }) async {
    if (kIsWeb) return;
    if (!await Permission.notification.isGranted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool sudahPernah =
        prefs.getBool('sudah_notif_tabungan_pertama') ?? false;
    if (sudahPernah) return;

    await prefs.setBool('sudah_notif_tabungan_pertama', true);

    final String sapaanNama =
        namaUser.trim().isEmpty ? 'Sobat' : namaUser.trim();
    final String bodyText =
        'Mantap $sapaanNama! Tabungan pertama "$namaTabungan" kamu berhasil dibuat. Yuk mulai rutin nabung!';

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'naboengs_channel_id',
      'Naboengs Notifications',
      channelDescription: 'Notifikasi aktivitas tabungan naboengs',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/naboengslogo',
      color: const Color(0xFF2EA98F),
      styleInformation: BigTextStyleInformation(bodyText),
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: 100,
      title: 'Tabungan Pertama Dimulai! 🎯',
      body: bodyText,
      notificationDetails: notificationDetails,
    );
  }

  /// Helper tanggal hari ini format YYYY-MM-DD
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Dipanggil saat user berhasil TAMBAH NOMINAL di dalam tabungan
  Future<void> onNominalTabunganDitambahkan(String rawName) async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tanggal_terakhir_nabung', _todayKey());

    // Hilangkan notifikasi pengingat jam 13:00 & 19:00 hari ini
    await flutterLocalNotificationsPlugin.cancel(id: 102);
    await flutterLocalNotificationsPlugin.cancel(id: 103);

    // Jadwalkan ulang mulai BESOK (hapus 3 baris di bawah jika ingin hilang permanen selamanya)
    if (await Permission.notification.isGranted) {
      await scheduleDailyReminders(rawName, mulaiBesok: true);
    }
  }

  /// Menjadwalkan 2 pengingat harian: 13:00 Siang & 19:00 Malam
  Future<void> scheduleDailyReminders(
    String rawName, {
    bool mulaiBesok = false,
  }) async {
    if (kIsWeb) return;
    if (!await Permission.notification.isGranted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool sudahNabungHariIni =
        prefs.getString('tanggal_terakhir_nabung') == _todayKey();

    // Bersihkan jadwal lama (termasuk ID 101 pagi jika masih tersisa)
    await flutterLocalNotificationsPlugin.cancel(id: 101);
    await flutterLocalNotificationsPlugin.cancel(id: 102);
    await flutterLocalNotificationsPlugin.cancel(id: 103);

    final bool paksaBesok = mulaiBesok || sudahNabungHariIni;
    final String nama = rawName.trim().isEmpty ? 'Sobat' : rawName.trim();
    final random = Random();

    // Variasi Siang (13:00)
    final daftarSiang = [
      (
        'Istirahat siang dulu ☕',
        'Siang $nama! Udah nambahin nominal tabungan hari ini belum?',
      ),
      (
        'Cek progres yuk 👀',
        'Hai $nama, selagi masih siang, yuk isi tabunganmu walau dikit!',
      ),
      (
        'Tetap konsisten! 🔥',
        'Siang $nama! Nabung sedikit demi sedikit, lama-lama jadi bukit!',
      ),
    ];

    // Variasi Malam (19:00)
    final daftarMalam = [
      (
        'Malam, $nama! 🌙',
        'Ada sisa jajan atau kembalian hari ini? Masukin ke naboengs yuk.',
      ),
      (
        'Tutup hari dengan bangga ✨',
        'Hai $nama, satu langkah lagi hari ini buat targetmu. Yuk nabung!',
      ),
      (
        'Sebelum rebahan... 🛏️',
        'Malam $nama, yuk selesaikan hari ini dengan menabung.',
      ),
    ];

    final pilihSiang = daftarSiang[random.nextInt(daftarSiang.length)];
    final pilihMalam = daftarMalam[random.nextInt(daftarMalam.length)];

    // 1. Jam 13:00 Siang
    await _scheduleSingleDaily(
      id: 102,
      hour: 13,
      minute: 0,
      title: pilihSiang.$1,
      body: pilihSiang.$2,
      paksaBesok: paksaBesok,
    );

    // 2. Jam 19:00 Malam
    await _scheduleSingleDaily(
      id: 103,
      hour: 19,
      minute: 0,
      title: pilihMalam.$1,
      body: pilihMalam.$2,
      paksaBesok: paksaBesok,
    );
  }

  Future<void> _scheduleSingleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    bool paksaBesok = false,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'naboengs_daily_channel_v3',
      'Pengingat Harian Naboengs',
      channelDescription: 'Pengingat menabung jam 1 siang dan 7 malam',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/naboengslogo',
      color: const Color(0xFF2EA98F),
      styleInformation: BigTextStyleInformation(body),
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool canExact =
        await androidPlugin?.canScheduleExactNotifications() ?? false;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute, paksaBesok: paksaBesok),
      notificationDetails: notificationDetails,
      androidScheduleMode: canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(
    int hour,
    int minute, {
    bool paksaBesok = false,
  }) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (paksaBesok) {
      final tz.TZDateTime besok = now.add(const Duration(days: 1));
      scheduledDate = tz.TZDateTime(
        tz.local,
        besok.year,
        besok.month,
        besok.day,
        hour,
        minute,
      );
    } else if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}