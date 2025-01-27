import 'dart:collection';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'shared_preferences_provider.dart';
import 'app_preferences.dart';
import '/route_generator.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'background_service.dart';
import 'traitement.dart';

void main() async {
  // Initialiser le logger
  final logger = AppLogger();
  logger.init();
  logger.info("Démarrage de l'application");

  // debugPrintRebuildDirtyWidgets = true;
  // debugPrintBuildScope = true;

  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des SharedPreferences
  await AppPreferences().init();

  // Charger les préférences par défaut
  // Initialisation des préférences
  _initPrefs();

  // Initialiser BackgroundServiceManager avec les instances partagées
  final backgroundService = BackgroundServiceManager();
  backgroundService.initialize();

  final backgroundSendPort = IsolateNameServer.lookupPortByName('messageStreamPort');
  final foregroundReceivePort = ReceivePort();
  print("envoie du sendPort");
  IsolateNameServer.registerPortWithName(foregroundReceivePort.sendPort, 'UIStreamPort');


  // Créer l'instance de MyappArgs
  final myappArgs = MyappArgs();
  myappArgs.backgroundService = backgroundService;

  // Personnaliser EasyLoading
  EasyLoading.instance
    ..indicatorSize = 60
    ..indicatorColor = Colors.grey
    ..maskType = EasyLoadingMaskType.black;

  // Démarrer l'application en utilisant ProviderScope
  runApp(
    Builder(
      builder: (BuildContext context) {
        return MyApp(args: myappArgs, foregroundReceivePort: foregroundReceivePort).build(context);
      },
    ),// Passez les arguments à l'app
  );
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
    AppPreferences().setString('queryInterval', '1');
  }
  if (!AppPreferences().containsKey('deviceId')) {
    AppPreferences().setString('deviceId', '1');
  }
  if (!AppPreferences().containsKey('sendInterval')) {
    AppPreferences().setString('sendInterval', '500');
  }
  if (!AppPreferences().containsKey('webApiKey')) {
    AppPreferences().setString('webApiKey', '');
  }
}

class MyApp {
  final MyappArgs args;
  final ReceivePort foregroundReceivePort;

  const MyApp({
    required this.args,
    required this.foregroundReceivePort,
  });

  // This widget is the root of your application.
  @override
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
    print("backgroudService null!!");
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
