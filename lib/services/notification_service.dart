import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
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
  }

  /// Meminta izin notifikasi (dipanggil setelah splash screen / input nama)
  Future<void> requestPermission() async {
    if (kIsWeb) return;
    await Permission.notification.request();
  }

  /// Menampilkan notifikasi instan saat user berhasil tambah tabungan baru
  Future<void> showTabunganBaruNotification({
    required String namaUser,
    required String namaTabungan,
  }) async {
    if (kIsWeb) return;
    if (!await Permission.notification.isGranted) return;

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
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Tabungan Baru Ditambahkan! 🎯',
      body: bodyText,
      notificationDetails: notificationDetails,
    );
  }
}