import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math';

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Lista de mensajes motivacionales
  static const List<String> motivationalMessages = [
    "¡No te rindas! Cada paso cuenta en tu camino hacia el éxito.",
    "Un pequeño progreso hoy es un gran resultado mañana. ¡Sigue así!",
    "La disciplina es el puente entre tus metas y tus logros. ¡Puedes hacerlo!",
    "Recuerda por qué empezaste. Tu futuro yo te lo agradecerá.",
    "¡Es hora de brillar! Completa tus hábitos y siéntete increíble.",
  ];

  Future<void> init() async {
    // 1. Configuración de inicialización para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Usa el ícono de la app

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // 2. Inicializar el plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse notificationResponse,
      ) async {
        // Manejar el toque en la notificación
      },
    );

    // 3. Solicitar permisos en Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();

    // 4. Configurar la zona horaria
    tz.initializeTimeZones();
  }

  // Método para programar la notificación diaria
  Future<void> scheduleDailyMiddayReminder() async {
    // Selecciona un mensaje aleatorio
    final String randomMessage =
        motivationalMessages[Random().nextInt(motivationalMessages.length)];

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID de la notificación
      '👋 ¡Hey! Es hora de un chequeo', // Título
      randomMessage, // Cuerpo del mensaje
      _nextInstanceOfTwelvePm(), // Calcula la próxima vez que serán las 12:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id', // ID del canal
          'Recordatorios Diarios', // Nombre del canal
          channelDescription: 'Canal para recordatorios de hábitos diarios.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Repetir diariamente a la misma hora
    );
  }

  // Función de ayuda para obtener la próxima instancia de las 12:00 PM
  tz.TZDateTime _nextInstanceOfTwelvePm() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      12,
    ); // Hoy a las 12:00 PM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      ); // Si ya pasaron las 12, programar para mañana
    }
    return scheduledDate;
  }

  // Opcional: Método para cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
