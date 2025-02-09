import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:permission_handler/permission_handler.dart';
import 'app_preferences.dart';
import 'route_generator.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:another_telephony/telephony.dart' as telephony;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  bool _permissionAllowed = false;
  // Initialiser le logger
  final logger = AppLogger();
  logger.init();
  logger.info("Démarrage de l'application");

  // debugPrintRebuildDirtyWidgets = true;
  // debugPrintBuildScope = true;

  WidgetsFlutterBinding.ensureInitialized();

  _permissionAllowed =
      await requestNotificationPermission(); // Demander les permissions

  bool? permissionsGranted = await telephony.Telephony.instance.requestPhoneAndSmsPermissions;

  // Initialisation des SharedPreferences
  await AppPreferences().init();

  // Charger les préférences par défaut
  // Initialisation des préférences
  _initPrefs();

  // Initialiser BackgroundServiceManager avec les instances partagées
  final backgroundService = BackgroundServiceManager();
  backgroundService.initialize();

  final backgroundSendPort =
      IsolateNameServer.lookupPortByName('messageStreamPort');
  final foregroundStreamReceivePort = ReceivePort();
  debugPrint("envoie du sendPort");
  IsolateNameServer.registerPortWithName(
      foregroundStreamReceivePort.sendPort, 'UIStreamPort');

  final foregroundReceivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(
      foregroundReceivePort.sendPort, 'UIPort');

  // Créer l'instance de MyappArgs
  final myappArgs = MyappArgs();
  myappArgs.backgroundService = backgroundService;

  // Personnaliser EasyLoading
  EasyLoading.instance
    ..indicatorSize = 60
    ..indicatorColor = Colors.grey
    ..maskType = EasyLoadingMaskType.black;

  // Initialisation des paramètres de notification
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Icône par défaut

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings);
  await initializeNotificationChannel();

  // Ecoute les messages envoyés par Traitements ou BackgroundService
  foregroundReceivePort.listen((message) async {
    debugPrint("Message reçu dans main: $message");
    switch (message['command']) {
      case 'logMessage':
        AppLogger.talker.log(message['message'],
            logLevel: LogLevel.values.byName(message['level']));
        break;
      case 'notification':
        if (!_permissionAllowed) {
          return;
        }
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'channel_id', // ID unique du canal
          'channel_name', // Nom du canal visible par l'utilisateur
          channelDescription: 'Description du canal', // Description
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
          android: androidPlatformChannelSpecifics,
        );
        await flutterLocalNotificationsPlugin.show(
          1, // ID de la notification (doit être unique)
          message['title'],
          message['body'],
          platformChannelSpecifics,
        );
        break;
      default:
        AppLogger.talker.log(message.toString(), logLevel: LogLevel.error);
    }
  });

  runApp(
    Builder(
      builder: (BuildContext context) {
        return MyApp(
                args: myappArgs,
                foregroundStreamReceivePort: foregroundStreamReceivePort)
            .build(context);
      },
    ),
  );
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'channel_id', // ID unique
  'channel_name', // Nom visible par l'utilisateur
  description: 'Description du canal', // Description optionnelle
  importance: Importance.high, // Importance de la notification
);

Future<void> initializeNotificationChannel() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannelGroup channelGroup =
  AndroidNotificationChannelGroup(
    'group_id', // ID unique du groupe
    'Group Name', // Nom du groupe visible par l'utilisateur
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<bool> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.notification.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint("L'utilisateur a refusé les notifications.");
      return false;
    } else {
      debugPrint("L'utilisateur a accepté les notifications.");
      return true;
    }
  } else {
    debugPrint("L'application n'est pas exécutée sur Android.");
    return true;
  }
}

void _initPrefs() {
  debugPrint("Initialisation des préférences");
  if (!AppPreferences().containsKey('sendUrl')) {
    AppPreferences().setString(
        'sendUrl', 'http://dev10.mcm65.famh.fr/civicrm/smshub/send_test');
  }
  if (!AppPreferences().containsKey('receiveUrl')) {
    AppPreferences().setString(
        'receiveUrl', 'http://dev10.mcm65.famh.fr/civicrm/smshub/receive');
  }
  if (!AppPreferences().containsKey('statusUrl')) {
    AppPreferences().setString(
        'statusUrl', 'http://dev10.mcm65.famh.fr/civicrm/smshub/status');
  }
  if (!AppPreferences().containsKey('queryInterval')) {
    AppPreferences().setDuration('queryInterval', Duration(minutes: 1));
  }
  if (!AppPreferences().containsKey('deviceId')) {
    AppPreferences().setString('deviceId', '1');
  }
  if (!AppPreferences().containsKey('sendInterval')) {
    AppPreferences().setDuration('sendInterval', Duration(seconds: 1, milliseconds: 200));
  }
  if (!AppPreferences().containsKey('webApiKey')) {
    AppPreferences().setString('webApiKey', '');
  }
}

class MyApp {
  final MyappArgs args;
  final ReceivePort foregroundStreamReceivePort;

  const MyApp({
    required this.args,
    required this.foregroundStreamReceivePort,
  });

  // This widget is the root of your application.
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          return RouteGenerator.generateRoute(
              RouteSettings(name: settings.name, arguments: settings.arguments),
              args,
              this);
        });
  }
}

class MyappArgs extends MapBase<String, dynamic> {
  final Map<String, dynamic> _map = HashMap.identity();

  @override
  Object? operator [](Object? key) => _map[key];

  @override
  void operator []=(String key, dynamic value) {
    _map[key] = value;
  }

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  dynamic remove(Object? key) => _map.remove(key);

  BackgroundServiceManager? get backgroundService {
    final value = _map['backgroundService'];
    if (value is BackgroundServiceManager) {
      return value;
    }
    debugPrint("backgroudService null!!");
    return null;
  }

  set backgroundService(BackgroundServiceManager? value) =>
      this['backgroundService'] = value;
}

class AppLogger extends Talker {
  // Constructeur privé
  static final Talker _talker = TalkerFlutter.init(
    settings: TalkerSettings(
      enabled: true,
      useHistory: true,
      maxHistoryItems: 100,
      colors: {
        TalkerLogType.critical.key: AnsiPen()..red(bold: true),
        TalkerLogType.error.key: AnsiPen()..red(),
        TalkerLogType.warning.key: AnsiPen()..magenta(),
        TalkerLogType.verbose.key: AnsiPen()..green(bold: true),
        TalkerLogType.debug.key: AnsiPen()..gray(),
        // Other colors...
      },
    ),
  );

  // Méthode pour accéder à l'instance Talker
  static Talker get talker => _talker;

  // Méthode pour initialiser Talker si nécessaire
  void init() {
    _talker.info("Logger initialisé");
  }
}
